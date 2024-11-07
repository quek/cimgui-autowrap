(in-package :ig-wrap)

(defconstant +flt-min+ (get-flt-min))
(defconstant +flt-max+ (get-flt-max))

(defmacro with-bool ((var value) &body body)
  `(autowrap:with-alloc (,var :unsigned-char)
     (setf (autowrap:c-aref ,var 0 :unsigned-char)
           (if ,value 1 0))
     (prog1 (ensure-to-bool (progn ,@body))
       (setf ,value (ensure-to-bool (autowrap:c-aref ,var 0 :unsigned-char))))))

(defmacro with-begin ((name &key open-p (flags 0)) &body body)
  `(unwind-protect
        (when (ig:begin ,name :open-p ,open-p :flags ,flags)
          ,@body)
     (ig:end)))

(defmacro with-child ((str-id &key (size ''(0.0 0.0)) (child-flags 0) (window-flags 0)) &body body)
  `(unwind-protect
        (when (ig:begin-child ,str-id :size ,size :child-flags ,child-flags :window-flags ,window-flags)
          ,@body)
     (ig:end-child)))

(defmacro with-color4 ((var color) &body body)
  (let (($color (gensym)))
    `(let ((,$color ,color))
       (autowrap:with-alloc (,var :float 4)
         (setf (c-ref ,var :float 0) (/ (ldb (byte 8 0) ,$color) 255.0))
         (setf (c-ref ,var :float 1) (/ (ldb (byte 8 8) ,$color) 255.0))
         (setf (c-ref ,var :float 2) (/ (ldb (byte 8 16) ,$color) 255.0))
         (setf (c-ref ,var :float 3) (/ (ldb (byte 8 24) ,$color) 255.0))
         ,@body))))

(defmacro with-color4* ((&rest vars) &body body)
  (let* ((var (car vars)))
    (if (null (cadr vars))
        `(with-color4 ,var
           ,@body)
        `(with-color4 ,var
           (with-color4* (,@(cdr vars))
             ,@body)))))

(defmacro with-vec2 ((var &optional x-y-list) &body body)
  (let ((x-y (gensym)))
    `(let ((,x-y ,(or x-y-list var)))
       (autowrap:with-alloc (,var 'im-vec2)
         (setf (c-ref ,var im-vec2 :x) (coerce (car ,x-y) 'single-float))
         (setf (c-ref ,var im-vec2 :y) (coerce (cadr ,x-y) 'single-float))
         ,@body))))

(defmacro with-vec2* ((&rest vars) &body body)
  (let* ((var (car vars))
         (var (if (atom var)
                  (list var)
                  var)))
    (if (null (cadr vars))
        `(with-vec2 ,var
           ,@body)
        `(with-vec2 ,var
           (with-vec2* (,@(cdr vars))
             ,@body)))))

(defun ensure-to-bool (x)
  (not (zerop x)))

(defun ensure-from-bool (x)
  (if x 1 0))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun accept-drag-drop-payload (type &optional (flags 0))
  (let ((payload (%accept-drag-drop-payload type flags)))
    (if (autowrap:wrapper-null-p payload)
        nil
        payload)))

(defmethod add-line ((draw-list im-draw-list) (p1 list) (p2 list) col &key (thickness 1.0))
  (with-vec2* (p1 p2)
    (im-draw-list-add-line draw-list p1 p2 col thickness)))

(defmethod add-rect ((draw-list im-draw-list) (p-min list) (p-max list) col
                     &key (rounding .0) (flags 0) (thickness 1.0))
  (with-vec2* (p-min p-max)
    (im-draw-list-add-rect draw-list p-min p-max col rounding flags thickness)))

(defmethod add-rect-filled ((draw-list im-draw-list) (p-min list) (p-max list) col
                            &key (rounding .0) (flags 0))
  (with-vec2* (p-min p-max)
    (im-draw-list-add-rect-filled draw-list p-min p-max col rounding flags)))

(defun add-text (draw-list pos col text)
  (with-vec2 (pos)
    (im-draw-list-add-text-vec2 draw-list pos col text (cffi:null-pointer))))

(defmacro begin (name &key open-p (flags 0))
  (if open-p
      `(with-bool (var-open-p ,open-p)
         (%begin ,name var-open-p ,flags))
      `(ensure-to-bool (%begin ,name (cffi:null-pointer) ,flags))))

(defun begin-child (str-id &key (size '(0.0 0.0)) (child-flags 0) (window-flags 0))
  (with-vec2 (size)
    (ensure-to-bool (begin-child-str str-id size child-flags window-flags))))

(defun begin-popup-context-item (&key str-id
                                   (popup-flags +im-gui-popup-flags-mouse-button-right+))
  (ensure-to-bool
   (%begin-popup-context-item (or str-id (cffi:null-pointer))
                              popup-flags)))

(defmacro begin-popup-modal (name &key open-p (flags 0))
  (if open-p
      `(with-bool (var-open-p ,open-p)
         (%begin-popup-modal ,name var-open-p ,flags))
      `(ensure-to-bool (%begin-popup-modal ,name (cffi:null-pointer) ,flags))))

(defun button (label &optional (size '(0.0 0.0)))
  (ensure-to-bool (%%button label size)))

(defmethod %%button (label (size im-vec2))
  (%button label size))

(defmethod %%button (label (size list))
  (with-vec2 (size)
    (%button label size)))

(defun calc-text-size (text &key hide-text-after-double-hash (wrap-width -.0))
  (autowrap:with-alloc (size 'im-vec2)
    (%calc-text-size size text (cffi:null-pointer)
                     (ensure-from-bool hide-text-after-double-hash) wrap-width)
    (list (c-ref size im-vec2 :x)
          (c-ref size im-vec2 :y))))

(defmacro color-picker4 (label color &key (flags 0) ref-col)
  (let ((ret (gensym "RET")))
    `(with-color4* ((color ,color)
                    ,@(when ref-col
                        `((ref-col ,ref-col))))
       (let* (,@(unless ref-col `((ref-col (cffi:null-pointer))))
              (,ret (ensure-to-bool (%color-picker4 ,label color ,flags ref-col))))
         (when ,ret
           (setf (ldb (byte 8 0) ,color) (floor (* (c-ref color :float 0) 255.0)))
           (setf (ldb (byte 8 8) ,color) (floor (* (c-ref color :float 1) 255.0)))
           (setf (ldb (byte 8 16) ,color) (floor (* (c-ref color :float 2) 255.0)))
           (setf (ldb (byte 8 24) ,color) (floor (* (c-ref color :float 3) 255.0))))
         ,ret))))

(defmacro combo (label current-item items
                 &key (popup-max-height-in-items -1)
                   (item-display-function ''princ-to-string))
  (let ((%items (gensym)))
    `(let ((,%items ,items))
       (cffi:with-foreign-string (foreign-items
                                  (with-output-to-string (s)
                                    (loop for item in ,%items
                                          do (format s "~a~c" (funcall ,item-display-function item) #\nul)
                                          finally (write-char #\nul s))))
         (cffi:with-foreign-object (current :int)
           (setf (cffi:mem-ref current :int) (or (position ,current-item ,%items :test #'equal) 0))
           (prog1 (ensure-to-bool (ig:combo-str ,label current foreign-items ,popup-max-height-in-items))
             (setf ,current-item (nth (cffi:mem-ref current :int)
                                      ,%items))))))))

;;; 引数に size_t があると定義できないみたい
(eval-when (:compile-toplevel :load-toplevel :execute)
  (AUTOWRAP:DEFINE-FOREIGN-FUNCTION
      '(IG::%SET-DRAG-DROP-PAYLOAD "igSetDragDropPayload") ':UNSIGNED-CHAR
    '((IG::|type| (:STRING)) (IG::|data| (:POINTER :VOID))
      (IG::|sz| :unsigned-long-long) (IG::|cond| IG:IM-GUI-COND)))
  (AUTOWRAP:DEFINE-CFUN IG::%SET-DRAG-DROP-PAYLOAD :ig))
(defun set-drag-drop-payload (type &key (data (cffi:null-pointer)) (data-size 0) (cond 0))
  (ensure-to-bool (IG::%SET-DRAG-DROP-PAYLOAD type data data-size cond)))

(defmacro drag-double (label value &key (speed 1.0) (min 0.0d0) (max 0.0d0) (format "%.3f") (flags 0))
  `(drag-scalar ,label +im-gui-data-type-double+ ,value
                :speed ,speed :min ,min :max ,max
                :format ,format :flags ,flags))

(defmacro drag-float (lable v &key (speed 1.0) (min 0.0) (max 0.0) (format "%.3f") (flags 0))
  (let ((ptr (gensym)))
    `(autowrap:with-alloc (,ptr :float)
       (setf (autowrap:c-aref ,ptr 0 :float) ,v)
       (prog1
           (ensure-to-bool (%drag-float ,lable ,ptr ,speed ,min ,max ,format ,flags))
         (setf ,v (autowrap:c-aref ,ptr 0 :float))))))

(defmacro drag-scalar (lable data-type data
                       &key (speed 1.0)
                         min max
                         (format (cffi:null-pointer))
                         (flags 0))
  (let ((ptr (gensym "PTR"))
        (p-min (gensym "MIN"))
        (p-max (gensym "MAX"))
        (ptr-type (ecase data-type
                     (+im-gui-data-type-s8+ :int8)
                     (+im-gui-data-type-u8+ :uint8)
                     (+im-gui-data-type-s16+ :int16)
                     (+im-gui-data-type-u16+ :uint16)
                     (+im-gui-data-type-s32+ :int32)
                     (+im-gui-data-type-u32+ :uint32)
                     (+im-gui-data-type-s64+ :int64)
                     (+im-gui-data-type-u64+ :uint64)
                     (+im-gui-data-type-float+ :float)
                     (+im-gui-data-type-double+ :double))))
    `(autowrap:with-many-alloc ((,ptr ,ptr-type)
                                ,@(when min
                                    `((,p-min ,ptr-type)))
                                ,@(when max
                                    `((,p-max ,ptr-type))))
       (setf (autowrap:c-aref ,ptr 0 ,ptr-type) ,data)
       ,@(when min `((setf (autowrap:c-aref ,p-min 0 ,ptr-type) ,min)))
       ,@(when max `((setf (autowrap:c-aref ,p-max 0 ,ptr-type) ,max)))
       (prog1
           (ensure-to-bool (%drag-scalar ,lable ,data-type ,ptr ,speed ,p-min ,p-max ,format ,flags))
         (setf ,data (autowrap:c-aref ,ptr 0 ,ptr-type))))))

(defun dummy (size)
  (with-vec2 (size)
    (%dummy size)))

(defun get-cursor-pos ()
  (autowrap:with-alloc (pos 'im-vec2)
    (%get-cursor-pos pos)
    (list (c-ref pos im-vec2 :x)
          (c-ref pos im-vec2 :y))))

(defun get-drag-drop-payload ()
  (let ((payload (%get-drag-drop-payload)))
    (if (autowrap:wrapper-null-p payload)
        nil
        payload)))

(defun get-item-rect-max ()
  (autowrap:with-alloc (max 'im-vec2)
    (%get-item-rect-max max)
    (list (c-ref max im-vec2 :x)
          (c-ref max im-vec2 :y))))

(defun get-item-rect-min ()
  (autowrap:with-alloc (min 'im-vec2)
    (%get-item-rect-min min)
    (list (c-ref min im-vec2 :x)
          (c-ref min im-vec2 :y))))

(defun get-item-rect-size ()
  (autowrap:with-alloc (size 'im-vec2)
    (%get-item-rect-size size)
    (list (c-ref size im-vec2 :x)
          (c-ref size im-vec2 :y))))

(defun get-mouse-pos ()
  (autowrap:with-alloc (pos 'im-vec2)
    (%get-mouse-pos pos)
    (list (c-ref pos im-vec2 :x)
          (c-ref pos im-vec2 :y))))

(defun get-window-pos ()
  (autowrap:with-alloc (pos 'im-vec2)
    (%get-window-pos pos)
    (list (c-ref pos im-vec2 :x)
          (c-ref pos im-vec2 :y))))

(defun get-window-size ()
  (autowrap:with-alloc (size 'im-vec2)
    (%get-window-size size)
    (list (c-ref size im-vec2 :x)
          (c-ref size im-vec2 :y))))

(defmethod data-type-p ((payload null) data-type)
  nil)

(defmethod data-type-p (payload data-type)
  (ensure-to-bool
   (im-gui-payload-is-data-type payload data-type)))

(defmacro input-text (label var &key (flags 0)
                                  (callback (cffi:null-pointer))
                                  (user-data (cffi:null-pointer)))
  (let ((octets (gensym))
        (buf (gensym))
        (buf-size (gensym))
        (size-arg (gensym)))
    `(let* ((,octets (sb-ext:string-to-octets ,var))
            (,buf-size (max 80 (1+ (length ,octets)))))
       (cffi:with-foreign-object (,buf :uchar ,buf-size)
         (loop for c across ,octets
               for i from 0
               do (setf (cffi:mem-aref ,buf :uchar i) c))
         (setf (cffi:mem-aref ,buf :char (length ,octets)) 0)
         (prog1 (ensure-to-bool (with-vec2 (,size-arg '(0.0 0.0))
                                  (input-text-ex ,label (cffi:null-pointer)
                                                 ,buf ,buf-size ,size-arg ,flags
                                                 ,callback ,user-data)))
           (setf ,var (cffi:foreign-string-to-lisp ,buf)))))))

(defmacro input-double (label v &key (step .0d0) (step-fast .0d0) (format "%.6f") (flags 0))
  (let ((value (gensym "VALUE")))
    `(autowrap:with-alloc (,value :double)
       (setf (cffi:mem-ref ,value :double) ,v)
       (if (ensure-to-bool
            (%input-double ,label ,value ,step
                           ,step-fast ,format ,flags))
           (progn
             (setf ,v (cffi:mem-ref ,value :double))
             t)
           nil))))

(defun invisible-button (label size &optional (flags 0))
  (ensure-to-bool (%%invisible-button label size flags)))

(defmethod %%invisible-button (label (size im-vec2) flags)
  (%invisible-button label size flags))

(defmethod %%invisible-button (label (size list) flags)
  (with-vec2 (size)
    (%invisible-button label size flags)))

(defun is-data-type (payload data-type)
  (ensure-to-bool (ig:im-gui-payload-is-data-type payload data-type)))

(defun is-item-active ()
  (ensure-to-bool (%is-item-active)))

(defun is-item-hovered (&optional (flag 0))
  (ensure-to-bool (%is-item-hovered flag)))

(defun is-mouse-clicked (button &optional repeat)
  (ensure-to-bool (is-mouse-clicked-bool button (ensure-from-bool repeat))))

(defun is-mouse-dragging (button &optional (lock-threshold -1.0))
  "if lock_threshold < 0.0f, uses io.MouseDraggingThreshold"
  (ensure-to-bool (%is-mouse-dragging button lock-threshold)))

(defun is-mouse-down (button)
  (ensure-to-bool (is-mouse-down-nil button)))

(defun is-mouse-released (button)
  (ensure-to-bool (is-mouse-released-nil button)))

(defun is-window-appearing ()
  (ensure-to-bool (%is-window-appearing)))

(defun is-window-hovered (&optional (flags 0))
  (ensure-to-bool (%is-window-hovered flags)))

(defun is-key-pressed (key &key (repeat t))
  (ensure-to-bool (is-key-pressed-bool key (ensure-from-bool repeat))))

(defun is-mouse-double-clicked (button)
  (ensure-to-bool (is-mouse-double-clicked-nil button)))

(defmacro menu-item (label &key (shortcut (cffi:null-pointer))
                             selected ptr-selected
                             (enabled t))
  (if ptr-selected
      `(with-bool (var-selected ,ptr-selected)
         (menu-item-bool-ptr ,label ,shortcut var-selected ,(ensure-from-bool enabled)))
      `(ensure-to-bool
        (menu-item-bool ,label ,shortcut
                        ,(ensure-from-bool selected)
                        ,(ensure-from-bool enabled)))))

(defun open-popup (str-id &optional (popup-flags 0))
  (open-popup-str str-id popup-flags))

(defun path-arc-to (draw-list center radius min max num-segments)
  (with-vec2 (center)
    (im-draw-list-path-arc-to draw-list center radius
                              (coerce min 'single-float)
                              (coerce max 'single-float)
                              num-segments)))

(defun path-arc-to-fast (draw-list center radius min-of-12 max-of-12)
  (with-vec2 (center)
    (im-draw-list-path-arc-to-fast draw-list center radius
                                   min-of-12 max-of-12)))

(defun path-fill-concave (draw-list color)
  (im-draw-list-path-fill-concave draw-list color))

(defun path-fill-convex (draw-list color)
  (im-draw-list-path-fill-convex draw-list color))

(defun path-line-to (draw-list pos)
  (with-vec2 (pos)
    (im-draw-list-path-line-to draw-list pos)))

(defun path-stroke (draw-list color &key (flags 0) (thickness 1.0))
  (im-draw-list-path-stroke draw-list color flags thickness))

(defmethod pop-style (var (val integer))
  (ig:pop-style-color 1))

(defmethod pop-style (var (val list))
  (ig:pop-style-var 1))

(defmethod pop-style (var (val float))
  (ig:pop-style-var 1))

(defun push-clip-rect (clip-rect-min clip-rect-max &optional intersect-with-current-clip-rect)
  (with-vec2* (clip-rect-min clip-rect-max)
    (%push-clip-rect clip-rect-min clip-rect-max
                     (if intersect-with-current-clip-rect 1 0))))

(defmethod push-id ((str string))
  (push-id-str str))

(defmethod push-id ((int integer))
  (push-id-int int))

(defmethod push-style (var (val integer))
  (ig:push-style-color-u32 var val))

(defmethod push-style (var (val integer))
  (ig:push-style-color-u32 var val))

(defmethod push-style (var (val float))
  (ig:push-style-var-float var val))

(defmethod push-style (var (val list))
  (with-vec2 (val)
    (ig:push-style-var-vec2 var val)))


(defun same-line (&optional (offset-from-start-x 0.0) (spacing -1.0))
  (%same-line offset-from-start-x spacing))

(defmethod set-cursor-pos ((pos list))
  (with-vec2 (pos)
    (%set-cursor-pos pos)))

(defmethod set-cursor-pos ((pos im-vec2))
  (%set-cursor-pos pos))

(defun set-keyboard-focus-here (&optional (offset 0))
  (%set-keyboard-focus-here offset))

(defun set-next-item-shortcut (key-chord &optional (flags 0))
  (%set-next-item-shortcut key-chord flags))

(defun set-next-window-size-constraints
    (size-min size-max &key (custom-callback (cffi:null-pointer))
                         (custom-callback-data (cffi:null-pointer)))
  (with-vec2* (size-min size-max)
    (%set-next-window-size-constraints size-min size-max custom-callback custom-callback-data)))

(defun shortcut (key-chord &optional (flags 0))
  (ensure-to-bool (shortcut-nil key-chord flags)))

(defmacro slider-float (label v v-min v-max &key (format "%.3f") (flags 0))
  (let ((ret (gensym "ret"))
        (value (gensym "VALUE")))
   `(cffi:with-foreign-object (,value :float)
      (setf (cffi:mem-ref ,value :float) ,v)
      (let ((,ret (ensure-to-bool (%slider-float ,label ,value ,v-min ,v-max ,format ,flags))))
        (when ,ret
          (setf ,v (cffi:mem-ref ,value :float)))
        ,ret))))

(defmacro v-slider-float (label size v v-min v-max &key (format "%.3f") (flags 0))
  (let ((ret (gensym "ret"))
        (value (gensym "VALUE"))
        ($size (gensym "SIZE")))
    `(with-vec2 (,$size ,size)
       (cffi:with-foreign-object (,value :float)
         (setf (cffi:mem-ref ,value :float) ,v)
         (let ((,ret (ensure-to-bool (%v-slider-float ,label ,$size ,value ,v-min ,v-max ,format ,flags))))
           (when ,ret
             (setf ,v (cffi:mem-ref ,value :float)))
           ,ret)))))

(defmacro v-slider-scalar (lable size data-type data min max
                           &key (format (cffi:null-pointer)) (flags 0))
  (let (($size (gensym "SIZE"))
        (p-data (gensym "DATA"))
        (p-min (gensym "MIN"))
        (p-max (gensym "MAX"))
        (ret (gensym "RET"))
        (ptr-type (ecase data-type
                    (+im-gui-data-type-s8+ :int8)
                    (+im-gui-data-type-u8+ :uint8)
                    (+im-gui-data-type-s16+ :int16)
                    (+im-gui-data-type-u16+ :uint16)
                    (+im-gui-data-type-s32+ :int32)
                    (+im-gui-data-type-u32+ :uint32)
                    (+im-gui-data-type-s64+ :int64)
                    (+im-gui-data-type-u64+ :uint64)
                    (+im-gui-data-type-float+ :float)
                    (+im-gui-data-type-double+ :double))))
    `(with-vec2 (,$size ,size)
       (autowrap:with-many-alloc ((,p-data ,ptr-type)
                                  (,p-min ,ptr-type)
                                  (,p-max ,ptr-type))
         (setf (autowrap:c-aref ,p-data 0 ,ptr-type) ,data)
         (setf (autowrap:c-aref ,p-min  0 ,ptr-type) ,min)
         (setf (autowrap:c-aref ,p-max  0 ,ptr-type) ,max)
         (let ((,ret (ensure-to-bool (%v-slider-scalar ,lable
                                                       ,$size
                                                       ,data-type
                                                       ,p-data
                                                       ,p-min
                                                       ,p-max
                                                       ,format
                                                       ,flags))))
           (when ,ret
             (setf ,data (autowrap:c-aref ,p-data 0 ,ptr-type)))
           ,ret)))))

(defmacro with-drag-drop-source ((&optional (flag 0)) &body body)
  `(when (ensure-to-bool (ig:begin-drag-drop-source ,flag))
     (unwind-protect
          (progn ,@body)
       (ig:end-drag-drop-source))))

(defmacro with-drag-drop-target (&body body)
  `(when (ensure-to-bool (ig:begin-drag-drop-target))
     (unwind-protect
          (progn ,@body)
       (ig:end-drag-drop-target))))

(defmacro with-group (&body body)
  `(progn
     (ig:begin-group)
     (unwind-protect
          (progn ,@body)
       (ig:end-group))))

(defmacro with-disabled ((&optional (disabled t)) &body body)
  `(progn
     (begin-disabled (ensure-from-bool ,disabled))
     (unwind-protect (progn ,@body)
       (end-disabled))))

(defmacro with-popup-context-item ((&key
                                      str-id
                                      (popup-flags +im-gui-popup-flags-mouse-button-right+))
                                   &body body)
  `(when (begin-popup-context-item :str-id ,str-id :popup-flags ,popup-flags)
     ,@body
     (end-popup)))

(defmacro with-popup-modal ((name &key open-p (flags 0)) &body body)
  `(when (ig:begin-popup-modal ,name :open-p ,open-p :flags ,flags)
     ,@body
     (ig:end-popup)))

(defmacro with-style ((var val) &body body)
  (let (($var (gensym "VAR"))
        ($val (gensym "VAL")))
    `(let ((,$var ,var)
           (,$val ,val))
       (push-style ,$var ,$val)
       (unwind-protect (progn ,@body)
         (pop-style ,$var ,$val)))))

(defmacro with-styles ((&rest var-val-list) &body body)
  (if (endp var-val-list)
      `(progn ,@body)
      `(with-style ,(car var-val-list)
         (with-styles ,(cdr var-val-list) ,@body))))

(defmacro with-tooltip (&body body)
  `(progn
     (ig:begin-tooltip)
     (unwind-protect (progn ,@body)
       (ig:end-tooltip))))

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

(defmacro with-begin-child ((str-id &key (size ''(0.0 0.0)) (child-flags 0) (window-flags 0)) &body body)
  `(unwind-protect
        (when (ig:begin-child ,str-id :size ,size :child-flags ,child-flags :window-flags ,window-flags)
          ,@body)
     (ig:end-child)))

(defmacro with-vec2 ((var &optional x-y-list) &body body)
  (let ((x-y (gensym)))
    `(let ((,x-y ,(or x-y-list var)))
       (autowrap:with-alloc (,var 'im-vec2)
         (setf (c-ref ,var im-vec2 :x) (car ,x-y))
         (setf (c-ref ,var im-vec2 :y) (cadr ,x-y))
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

(defmacro begin-popup-modal (name &key (open-p nil open-p-p) (flags 0))
  (if open-p-p
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
           (setf (cffi:mem-ref current :int) (or (position ,current-item ,%items) 0))
           (prog1 (ensure-to-bool (ig:combo-str ,label current foreign-items ,popup-max-height-in-items))
             (setf ,current-item (nth (cffi:mem-ref current :int)
                                      ,%items))))))))

(defmacro drag-float (lable v &key (v-speed 1.0) (v-min 0.0) (v-max 0.0) (format "%.3f") (flags 0))
  (let ((ptr (gensym)))
    `(autowrap:with-alloc (,ptr :float)
       (setf (autowrap:c-aref ,ptr 0 :float) ,v)
       (prog1
           (ensure-to-bool (%drag-float ,lable ,ptr ,v-speed ,v-min ,v-max ,format ,flags))
         (setf ,v (autowrap:c-aref ,ptr 0 :float))))))


(defun get-cursor-pos ()
  (autowrap:with-alloc (pos 'im-vec2)
    (%get-cursor-pos pos)
    (list (c-ref pos im-vec2 :x)
          (c-ref pos im-vec2 :y))))

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

(defmacro input-text (label var &key (flags 0)
                                  (callback (cffi:null-pointer))
                                  (user-data (cffi:null-pointer)))
  (let ((octets (gensym))
        (buf (gensym))
        (buf-size (gensym))
        (size-arg (gensym)))
    `(let* ((,octets (sb-ext:string-to-octets ,var))
            (,buf-size (max 80 (1+ (length ,octets)))))
       (cffi:with-foreign-object (,buf :char ,buf-size)
         (loop for c across ,octets
               for i from 0
               do (setf (cffi:mem-aref ,buf :char i) c))
         (setf (cffi:mem-aref ,buf :char (length ,octets)) 0)
         (prog1 (ensure-to-bool (with-vec2 (,size-arg '(0.0 0.0))
                                  (input-text-ex ,label (cffi:null-pointer)
                                                 ,buf ,buf-size ,size-arg ,flags
                                                 ,callback ,user-data)))
           (setf ,var (cffi:foreign-string-to-lisp ,buf)))))))

(defun invisible-button (label size &optional (flags 0))
  (ensure-to-bool (%%invisible-button label size flags)))

(defmethod %%invisible-button (label (size im-vec2) flags)
  (%invisible-button label size flags))

(defmethod %%invisible-button (label (size list) flags)
  (with-vec2 (size)
    (%invisible-button label size flags)))

(defun is-mouse-clicked (button &optional repeat)
  (ensure-to-bool (is-mouse-clicked-bool button (ensure-from-bool repeat))))

(defun is-mouse-dragging (button &optional (lock-threshold -1.0))
  "if lock_threshold < 0.0f, uses io.MouseDraggingThreshold"
  (ensure-to-bool (%is-mouse-dragging button lock-threshold)))

(defun is-mouse-released (button)
  (ensure-to-bool (is-mouse-released-nil button)))

(defun is-window-appearing ()
  (ensure-to-bool (%is-window-appearing)))

(defun is-window-hovered (flags)
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

(defmethod push-id ((str string))
  (push-id-str str))

(defmethod push-id ((int integer))
  (push-id-int int))

(defun push-clip-rect (clip-rect-min clip-rect-max &optional intersect-with-current-clip-rect)
  (with-vec2* (clip-rect-min clip-rect-max)
    (%push-clip-rect clip-rect-min clip-rect-max
                     (if intersect-with-current-clip-rect 1 0))))

(defun same-line (&optional (offset-from-start-x 0.0) (spacing -1.0))
  (%same-line offset-from-start-x spacing))

(defmethod set-cursor-pos ((pos list))
  (with-vec2 (pos)
    (%set-cursor-pos pos)))

(defmethod set-cursor-pos ((pos im-vec2))
  (%set-cursor-pos pos))

(defun set-keyboard-focus-here (&optional (offset 0))
  (%set-keyboard-focus-here offset))

(defun set-next-window-size-constraints
    (size-min size-max &key (custom-callback (cffi:null-pointer))
                         (custom-callback-data (cffi:null-pointer)))
  (with-vec2* (size-min size-max)
    (%set-next-window-size-constraints size-min size-max custom-callback custom-callback-data)))

(defmacro with-popup-context-item ((&key
                                      str-id
                                      (popup-flags +im-gui-popup-flags-mouse-button-right+))
                                   &body body)
  `(when (begin-popup-context-item :str-id ,str-id :popup-flags ,popup-flags)
     ,@body
     (end-popup)))

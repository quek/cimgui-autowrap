(in-package :ig-wrap)

(defconstant +flt-min+ (get-flt-min))
(defconstant +flt-max+ (get-flt-max))

(defmacro with-bool ((var value) &body body)
  `(autowrap:with-alloc (,var :unsigned-char)
     (setf (autowrap:c-aref ,var 0 :unsigned-char)
           (if ,value 1 0))
     (prog1 (ensure-to-bool (progn ,@body))
       (setf ,value (ensure-to-bool (autowrap:c-aref ,var 0 :unsigned-char))))))

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

(defmacro begin (name &key (open-p nil open-p-p) (flags 0))
  (if open-p-p
      `(with-bool (var-open-p ,open-p)
         (%begin ,name var-open-p ,flags))
      `(ensure-to-bool (%begin ,name (cffi:null-pointer) ,flags))))

(defun begin-child (str-id &key (size '(0.0 0.0)) (child-flags 0) (window-flags 0))
  (with-vec2 (size)
    (ensure-to-bool (begin-child-str str-id size child-flags window-flags))))

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
  `(let ((buf-size (max 80 (1+ (length ,var)))))
     (cffi:with-foreign-string (buf ,var)
       (prog1 (ensure-to-bool (with-vec2 (size-arg '(0.0 0.0))
                                (input-text-ex ,label (cffi:null-pointer)
                                               buf buf-size size-arg ,flags
                                               ,callback ,user-data)))
         (setf ,var (cffi:foreign-string-to-lisp buf))))))

(defun invisible-button (label size &optional (flags 0))
  (ensure-to-bool (%%invisible-button label size flags)))

(defmethod %%invisible-button (label (size im-vec2) flags)
  (%invisible-button label size flags))

(defmethod %%invisible-button (label (size list) flags)
  (with-vec2 (size)
    (%invisible-button label size flags)))

(defun is-window-appearing ()
  (ensure-to-bool (%is-window-appearing)))

(defun is-key-pressed (key &key (repeat t))
  (ensure-to-bool (is-key-pressed-bool key (ensure-from-bool repeat))))

(defun is-mouse-double-clicked (button)
  (ensure-to-bool (is-mouse-double-clicked-nil button)))

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

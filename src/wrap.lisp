(in-package :ig-wrap)

(defconstant ig:+flt-min+ (ig:get-flt-min))
(defconstant ig:+flt-max+ (ig:get-flt-max))

(defmacro with-bool ((var value) &body body)
  `(autowrap:with-alloc (,var :pointer)
     (setf (autowrap:c-aref ,var 0 :unsigned-char)
           (if ,value 1 0))
     (prog1 (not (zerop ,@body))
       (setf ,value (not (zerop (autowrap:c-aref ,var 0 :unsigned-char)))))))

(autowrap:find-function 'ig:begin-popup-modal)
(defmacro with-vec2 ((var &optional x-y-list) &body body)
  (let ((x-y (gensym)))
    `(let ((,x-y ,(or x-y-list var)))
       (autowrap:with-alloc (,var 'ig:im-vec2)
         (setf (c-ref ,var ig:im-vec2 :x) (car ,x-y))
         (setf (c-ref ,var ig:im-vec2 :y) (cadr ,x-y))
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

(defmethod ig:add-line ((self ig:im-draw-list) (p1 list) (p2 list) col &optional (thickness 1.0))
  (with-vec2* (p1 p2)
    (ig:%im-draw-list-add-line self p1 p2 col thickness)))

(defun ig:begin (name &optional (open-p (cffi:null-pointer)) (flags 0))
  (not (zerop (ig:%begin name open-p flags))))

(defun ig:begin-child (str-id &key (size '(0.0 0.0)) (child-flags 0) (window-flags 0))
  (with-vec2 (size)
    (not (zerop (ig:begin-child-str str-id size child-flags window-flags)))))

(defmacro ig:begin-popup-modal (name &key (open-p nil open-p-p) (flags 0))
  (if open-p-p
      `(with-bool (var-open-p ,open-p)
         (ig:%begin-popup-modal ,name var-open-p ,flags))
      `(not (zerop (ig:%begin-popup-modal ,name (cffi:null-pointer) ,flags)))))

(defun ig:get-cursor-pos ()
  (autowrap:with-alloc (pos 'ig:im-vec2)
    (ig:%get-cursor-pos pos)
    (list (c-ref pos ig:im-vec2 :x)
          (c-ref pos ig:im-vec2 :y))))

(defun ig:get-window-pos ()
  (autowrap:with-alloc (pos 'ig:im-vec2)
    (ig:%get-window-pos pos)
    (list (c-ref pos ig:im-vec2 :x)
          (c-ref pos ig:im-vec2 :y))))

(defun ig:get-window-size ()
  (autowrap:with-alloc (size 'ig:im-vec2)
    (ig:%get-window-size size)
    (list (c-ref size ig:im-vec2 :x)
          (c-ref size ig:im-vec2 :y))))

(defun ig:button (label &optional (size '(0.0 0.0)))
  (not (zerop (%%button label size))))

(defmethod %%button (label (size ig:im-vec2))
  (ig:%button label size))

(defmethod %%button (label (size list))
  (with-vec2 (size)
    (ig:%button label size)))

(defmacro ig:drag-float (lable v &key (v-speed 1.0) (v-min 0.0) (v-max 0.0) (format "%.3f") (flags 0))
  (let ((ptr (gensym)))
    `(autowrap:with-alloc (,ptr :float)
       (setf (autowrap:c-aref ,ptr 0 :float) ,v)
       (prog1
           (not (zerop (ig:%drag-float ,lable ,ptr ,v-speed ,v-min ,v-max ,format ,flags)))
         (setf ,v (autowrap:c-aref ,ptr 0 :float))))))

(defmacro ig:input-text (label var &key (flags 0)
                                     (callback (cffi:null-pointer))
                                     (user-data (cffi:null-pointer)))
  `(let ((buf-size (max 80 (1+ (length ,var)))))
     (autowrap:with-alloc (buf :char buf-size)
       (loop for c across ,var
             for i from 0
             do (setf (autowrap:c-aref buf i :char) (char-code c))
             finally (setf (autowrap:c-aref buf (1+ i) :char) 0))
       (prog1 (not (zerop (with-vec2 (size-arg '(0.0 0.0))
                            (ig:input-text-ex ,label (cffi:null-pointer)
                                              buf buf-size size-arg ,flags
                                              ,callback ,user-data))))
         (setf ,var (cffi:foreign-string-to-lisp buf))))))

(defun ig:invisible-button (label size &optional (flags 0))
  (not (zerop (%%invisible-button label size flags))))

(defmethod %%invisible-button (label (size ig:im-vec2) flags)
  (ig:%invisible-button label size flags))

(defmethod %%invisible-button (label (size list) flags)
  (with-vec2 (size)
    (ig:%invisible-button label size flags)))

(defun ig:is-window-appearing ()
  (not (zerop (ig:%is-window-appearing))))

(defmacro ig:push-id ()
  `(ig:push-id-str ,(symbol-name (gensym))))

(defun ig:same-line (&optional (offset-from-start-x 0.0) (spacing -1.0))
  (ig:%same-line offset-from-start-x spacing))

(defmethod ig:set-cursor-pos ((pos list))
  (with-vec2 (pos)
    (ig:%set-cursor-pos pos)))

(defmethod ig:set-cursor-pos ((pos ig:im-vec2))
  (ig:%set-cursor-pos pos))

(defun ig:set-keyboard-focus-here (&optional (offset 0))
  (ig:%set-keyboard-focus-here offset))


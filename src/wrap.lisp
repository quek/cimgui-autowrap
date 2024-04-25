(in-package :ig-wrap)

(defmacro with-vec2 ((var &optional x-y-list) &body body)
  (let ((x-y (gensym)))
    `(let ((,x-y ,(or x-y-list var)))
       (autowrap:with-alloc (,var 'ig:im-vec2)
         (setf (c-ref ,var ig:im-vec2 :x) (car ,x-y))
         (setf (c-ref ,var ig:im-vec2 :y) (cadr ,x-y))
         ,@body))))

(defun ig:begin (name &optional (open-p (cffi:null-pointer)) (flags 0))
  (not (zerop (ig:%begin name open-p flags))))

(defun ig:begin-child (str-id &key (size '(0.0 0.0)) (child-flags 0) (window-flags 0))
  (with-vec2 (size)
    (not (zerop (ig:begin-child-str str-id size child-flags window-flags)))))


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

(defun ig:same-line (&optional (offset-from-start-x 0.0) (spacing -1.0))
  (ig:%same-line offset-from-start-x spacing))

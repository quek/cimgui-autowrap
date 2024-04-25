(in-package :ig-wrap)

(export (intern "BEGIN" :ig) :ig)
(defun ig::begin (name &optional (open-p (cffi:null-pointer)) (flags 0))
  (ig:%begin name open-p flags))

(export (intern "BUTTON" :ig) :ig)
(defun ig::button (label &optional (size '(0.0 0.0)))
  (not (zerop (%%button label size))))

(defmethod %%button (label (size ig:im-vec2))
  (ig:%button label size))

(defmethod %%button (label (size list))
  (autowrap:with-alloc (vec2 'ig:im-vec2)
    (setf (c-ref vec2 ig:im-vec2 :x) (car size))
    (setf (c-ref vec2 ig:im-vec2 :y) (cadr size))
    (ig:%button label vec2)))

(export (intern "DRAG-FLOAT" :ig) :ig)
(defmacro ig::drag-float (lable v &key (v-speed 1.0) (v-min 0.0) (v-max 0.0) (format "%.3f") (flags 0))
  (let ((ptr (gensym)))
    `(autowrap:with-alloc (,ptr :float)
       (setf (autowrap:c-aref ,ptr 0 :float) ,v)
       (if (zerop (ig:%drag-float ,lable ,ptr ,v-speed ,v-min ,v-max ,format ,flags))
           nil
           (progn
             (setf ,v (autowrap:c-aref ,ptr 0 :float))
             t)))))

(export (intern "SAME-LINE" :ig) :ig)
(defun ig::same-line (&optional (offset-from-start-x 0.0) (spacing -1.0))
  (ig:%same-line offset-from-start-x spacing))

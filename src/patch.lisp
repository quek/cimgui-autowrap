(in-package :autowrap)

(defmethod foreign-to-ffi ((type foreign-string) names params fields body)
  (let ((name (car names)))
    (with-gensyms (own-p)
      (let ((string-alloc
              `(progn
                 (setf ,name (cffi:foreign-string-alloc ,name))
                 (setf ,own-p t)))
            (constant-string-p
              (and (constantp (car params))
                   (stringp (car params)))))
        `(let ((,name (or ,(car params)
                          (cffi-sys:null-pointer)))
               (,own-p))
           (declare (ignorable ,own-p)) ;add this
           (unwind-protect
                (progn
                  ,(if constant-string-p
                       string-alloc
                       `(when (stringp ,name)
                          ,string-alloc))
                  ,(next-ffi))
             ,(if constant-string-p
                  `(when ,name (cffi:foreign-string-free ,name))
                  `(when (and ,own-p ,name)
                     (cffi:foreign-string-free ,name)))))))))

(in-package :ig-wrap)

(defmacro with-button-color ((color &key (hovered-color color) (active-color color))
                             &body body)
  `(progn
     (push-style-color-u32 +im-gui-col-button+ ,color)
     (push-style-color-u32 +im-gui-col-button-hovered+ ,hovered-color)
     (push-style-color-u32 +im-gui-col-button-active+ ,active-color)
     (unwind-protect (progn ,@body)
       (pop-style-color 3))))

(defmacro with-clip-rect ((min-pos max-pos &optional intersect-with-current-clip-rect)
                          &body body)
  `(progn
     (push-clip-rect ,min-pos ,max-pos ,intersect-with-current-clip-rect)
     (unwind-protect (progn ,@body)
       (pop-clip-rect))))

(defmacro with-id ((id) &body body)
  `(progn
     (push-id ,id)
     (unwind-protect (progn ,@body)
       (pop-id))))

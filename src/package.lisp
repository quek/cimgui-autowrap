(defpackage :ig
  (:export #:+flt-min+
           #:+flt-max+
           #:add-line
           #:begin
           #:begin-child
           #:button
           #:drag-float
           #:get-cursor-pos
           #:get-window-pos
           #:get-window-size
           #:invisible-button
           #:push-id
           #:same-line
           #:set-cursor-pos))

(defpackage :ig-wrap
  (:use :cl :plus-c))

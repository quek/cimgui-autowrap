(defpackage :ig
  (:export #:+flt-min+
           #:+flt-max+
           #:add-line
           #:begin
           #:begin-child
           #:button
           #:get-cursor-pos
           #:get-window-pos
           #:get-window-size
           #:drag-float
           #:push-id
           #:same-line
           #:set-cursor-pos))

(defpackage :ig-wrap
  (:use :cl :plus-c))

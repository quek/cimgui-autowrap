(defpackage :ig
  (:export #:add-line
           #:begin
           #:begin-child
           #:button
           #:get-window-pos
           #:get-window-size
           #:drag-float
           #:push-id
           #:same-line
           #:set-cursor-pos))

(defpackage :ig-wrap
  (:use :cl :plus-c))

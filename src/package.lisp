(defpackage :ig
  (:export #:+flt-min+
           #:+flt-max+
           #:add-line
           #:begin
           #:begin-child
           #:begin-popup-modal
           #:button
           #:drag-float
           #:get-cursor-pos
           #:get-window-pos
           #:get-window-size
           #:invisible-button
           #:is-window-appearing
           #:push-id
           #:same-line
           #:set-cursor-pos
           #:set-keyboard-focus-here))

(defpackage :ig-wrap
  (:use :cl :plus-c))

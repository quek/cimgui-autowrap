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
           #:is-key-pressed
           #:is-window-appearing
           #:open-popup
           #:push-id
           #:same-line
           #:set-cursor-pos
           #:set-keyboard-focus-here
           #:set-next-window-size-constraints))

(defpackage :ig-wrap
  (:use :cl :plus-c))

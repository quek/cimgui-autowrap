(defpackage :ig
  (:export #:+flt-min+
           #:+flt-max+
           #:add-line
           #:add-rect
           #:add-rect-filled
           #:add-text
           #:begin
           #:begin-child
           #:begin-popup-modal
           #:button
           #:drag-float
           #:ensure-from-bool
           #:ensure-to-bool
           #:get-cursor-pos
           #:get-mouse-pos
           #:get-window-pos
           #:get-window-size
           #:invisible-button
           #:is-key-pressed
           #:is-mouse-double-clicked
           #:is-window-appearing
           #:open-popup
           #:push-clip-rect
           #:push-id
           #:same-line
           #:set-cursor-pos
           #:set-keyboard-focus-here
           #:set-next-window-size-constraints

           #:with-begin
           #:with-begin-child
           #:with-button-color
           #:with-clip-rect
           #:with-id))

(defpackage :ig-wrap
  (:use :cl :plus-c :ig))

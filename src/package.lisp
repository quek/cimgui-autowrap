(defpackage :ig
  (:export #:+flt-min+
           #:+flt-max+
           #:add-line
           #:add-rect
           #:add-rect-filled
           #:add-text
           #:begin
           #:begin-child
           #:begin-popup-context-item
           #:begin-popup-modal
           #:button
           #:combo
           #:drag-float
           #:ensure-from-bool
           #:ensure-to-bool
           #:get-cursor-pos
           #:get-mouse-pos
           #:get-window-pos
           #:get-window-size
           #:invisible-button
           #:is-item-active
           #:is-key-pressed
           #:is-mouse-clicked
           #:is-mouse-double-clicked
           #:is-mouse-dragging
           #:is-mouse-released
           #:is-window-appearing
           #:is-window-hovered
           #:menu-item
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
           #:with-group
           #:with-id
           #:with-popup-context-item
           #:with-styles))

(defpackage :ig-wrap
  (:use :cl :plus-c :ig))

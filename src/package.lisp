(defpackage :ig
  (:export #:+flt-min+
           #:+flt-max+
           #:accept-drag-drop-payload
           #:add-line
           #:add-rect
           #:add-rect-filled
           #:add-text
           #:begin
           #:begin-child
           #:begin-popup-context-item
           #:begin-popup-modal
           #:button
           #:color-picker4
           #:combo
           #:drag-float
           #:drag-scalar
           #:ensure-from-bool
           #:ensure-to-bool
           #:get-cursor-pos
           #:get-drag-drop-payload
           #:get-mouse-pos
           #:get-window-pos
           #:get-window-size
           #:invisible-button
           #:is-data-type
           #:is-item-active
           #:is-item-hovered
           #:is-key-pressed
           #:is-mouse-clicked
           #:is-mouse-double-clicked
           #:is-mouse-down
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
           #:set-drag-drop-payload
           #:set-keyboard-focus-here
           #:set-next-window-size-constraints

           #:with-begin
           #:with-child
           #:with-button-color
           #:with-clip-rect
           #:with-disabled
           #:with-drag-drop-source
           #:with-drag-drop-target
           #:with-group
           #:with-id
           #:with-popup-context-item
           #:with-popup-modal
           #:with-styles
           #:with-tooltip))

(defpackage :ig-wrap
  (:use :cl :plus-c :ig))

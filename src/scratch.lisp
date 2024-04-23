(ql:quickload "cimgui-autowrap")

(ql:quickload "cl-plus-c")

(cffi:define-foreign-library libcimgui
  (:windows "cimgui_sdl.dll"))
(cffi:use-foreign-library libcimgui)

(ig:create-context (cffi:null-pointer))
;;⇒ #<IG:IM-GUI-CONTEXT {#X02A6ABC0}>

(ig:get-io)
;;⇒ #<IG:IM-GUI-IO {#X02A6ABC8}>


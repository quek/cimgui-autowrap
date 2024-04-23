(ql:quickload "cimgui-autowrap")

(ql:quickload "cl-plus-c")

(cffi:define-foreign-library libcimgui
  (:windows "cimgui_sdl.dll"))
(cffi:use-foreign-library libcimgui)

(cimgui-autowrap:ig-create-context (cffi:null-pointer))
(plus-c:c-fun cimgui-autowrap:ig-create-context (cffi:null-pointer))
;;⇒ #<CIMGUI-AUTOWRAP:IM-GUI-CONTEXT {#X001D6FD0}>

(plus-c:c-fun cimgui-autowrap:ig-im-file-get-size "/Users/ancient/.emacs")

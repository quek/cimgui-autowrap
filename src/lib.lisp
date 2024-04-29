(in-package :ig-wrap)

(cffi:define-foreign-library libcimgui
  (:windows "cimgui_win32.dll"))

(cffi:use-foreign-library libcimgui)

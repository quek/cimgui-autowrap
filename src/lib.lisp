(in-package :ig-wrap)

(cffi:define-foreign-library libcimgui
  (:windows "cimgui.dll"))

(cffi:use-foreign-library libcimgui)

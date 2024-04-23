(asdf:defsystem :cimgui-autowrap
  :licence "GPL3"
  :depends-on ("cl-autowrap/libffi")
  :serial t
  :pathname "src"
  :components
  ((:file "package")
   (:file "autowrap")
   (:static-file "cimgui-autowrap.h")
   (:module spec
    :pathname "spec")))

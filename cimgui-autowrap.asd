(asdf:defsystem :cimgui-autowrap
  :licence "GPL3"
  :depends-on ("cl-autowrap/libffi")
  :serial t
  :pathname "src"
  :components
  ((:file "package")
   (:file "patch")
   (:file "lib")
   (:file "autowrap")
   (:static-file "cimgui-autowrap.h")
   (:module spec
    :pathname "spec")
   (:file "wrap")))

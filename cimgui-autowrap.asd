(asdf:defsystem :cimgui-autowrap
  :licence "GPL3"
  :depends-on ("cl-autowrap/libffi")
  :serial t
  :pathname "src"
  :components
  ((:file "package")
   (:file "autowrap")
   (:module spec
     :pathname "spec")))

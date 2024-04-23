(cl:in-package :cimgui-autowrap)

#+nil
(cl:setf autowrap:*c2ffi-program* "/home/ancient/c2ffi/build/bin/c2ffi")

(autowrap:c-include (asdf:system-relative-pathname :cimgui-autowrap "src/spec/cimgui-autowrap.h")
                    :spec-path '(cimgui-autowrap spec))


#+nil
(setf autowrap:*c2ffi-program* "/home/ancient/c2ffi/build/bin/c2ffi")

(autowrap:c-include (asdf:system-relative-pathname :cimgui-autowrap "src/cimgui-autowrap.h")
                    :spec-path '(cimgui-autowrap spec)
                    :definition-package :ig
                    :c-to-lisp-function (lambda (s)
                                          (let ((s (autowrap:default-c-to-lisp s)))
                                            (ppcre:regex-replace "^IG-" s "")))
                    ;; nil だと autowrap がとおらない
                    :no-accessors t
                    :no-functions nil
                    :release-p t
                    :symbol-exceptions (("igBegin" . "%BEGIN")
                                        ("igButton" . "%BUTTON")
                                        ("igGetCursorPos" . "%GET-CURSOR-POS")
                                        ("igGetWindowPos" . "%GET-WINDOW-POS")
                                        ("igGetWindowSize" . "%GET-WINDOW-SIZE")
                                        ("igDragFloat" . "%DRAG-FLOAT")
                                        ("ImDrawList_AddLine" . "%IM-DRAW-LIST-ADD-LINE")
                                        ("igInvisibleButton" . "%INVISIBLE-BUTTON")
                                        ("igSameLine" . "%SAME-LINE")
                                        ("igSetCursorPos" . "%SET-CURSOR-POS")))


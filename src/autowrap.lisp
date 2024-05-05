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
                                        ("igBeginPopupModal" . "%BEGIN-POPUP-MODAL")
                                        ("igButton" . "%BUTTON")
                                        ("igGetCursorPos" . "%GET-CURSOR-POS")
                                        ("igGetMousePos" . "%GET-MOUSE-POS")
                                        ("igGetWindowPos" . "%GET-WINDOW-POS")
                                        ("igGetWindowSize" . "%GET-WINDOW-SIZE")
                                        ("igDragFloat" . "%DRAG-FLOAT")
                                        ("igInvisibleButton" . "%INVISIBLE-BUTTON")
                                        ("igIsWindowAppearing" . "%IS-WINDOW-APPEARING")
                                        ("igPushClipRect". "%PUSH-CLIP-RECT")
                                        ("igSameLine" . "%SAME-LINE")
                                        ("igSetCursorPos" . "%SET-CURSOR-POS")
                                        ("igSetKeyboardFocusHere" . "%SET-KEYBOARD-FOCUS-HERE")
                                        ("igSetNextWindowSizeConstraints" . "%SET-NEXT-WINDOW-SIZE-CONSTRAINTS")))


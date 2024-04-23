Debian 環境で c2ffi のコンパイルと spec ファイル (ql:quickload "cimgui-autowrap") の生成までを行う。

コンパイル時にメモリが足りなくなるので

~/.emacs
```
(setq inferior-lisp-program "sbcl --dynamic-space-size 128000")
```


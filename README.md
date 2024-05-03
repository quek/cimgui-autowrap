# コンパイル

Debian 環境で c2ffi のコンパイルと spec ファイル (ql:quickload "cimgui-autowrap") の生成までを行う。

コンパイル時にメモリが足りなくなるので

~/.emacs
```
(setq inferior-lisp-program "sbcl --dynamic-space-size 128000")
```

# ImGui バックエンド

## MSYS2 インストール

$ pacman -S mingw64/mingw-w64-x86_64-gcc
Windows の環境変数を編集から PATH に C:\msys64\mingw64\bin を追加

## Vulkan バックエンドの生成

/generator.sh

```
cd lib/cimgui/generator
vi generator.sh
```

追加

```
CFLAGS="sdl2 vulkan"
```

生成

```
./generator.sh
```


## DLL のコンパイル

```
pacman -S mingw64/mingw-w64-x86_64-cmake
pacman -S mingw64/mingw-w64-x86_64-SDL2
# vulkan バックエンド
pacman -S mingw-w64-x86_64-vulkan-headers mingw-w64-x86_64-vulkan-loader mingw-w64-x86_64-vulkan-utility-libraries mingw-w64-x86_64-vulkan-validation-layers
cd lib/cimgui/backend_test/example_sdl_vulkan
# コンパイルとおるようにちょっと修正
vi main.cpp
mkdir build

cd build
cmake -DSDL_PATH="" ..
cmake --build .
```

これでできた cimgui_sdl.dll をロードする。
この DLL は ImGui を含んでいるので cimgui.dll はいらない。

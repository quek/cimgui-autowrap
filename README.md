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

diff --git a/backend_test/example_sdl_vulkan/main.c b/backend_test/example_sdl_vulkan/main.c
index 020ad19..506d4dc 100644
--- a/backend_test/example_sdl_vulkan/main.c
+++ b/backend_test/example_sdl_vulkan/main.c
@@ -415,41 +415,42 @@ int main(int argc, char* argv[])
     .ImageCount = wd->ImageCount,
     .MSAASamples = VK_SAMPLE_COUNT_1_BIT,
     .Allocator = g_Allocator,
-    .CheckVkResultFn = check_vk_result
+    .CheckVkResultFn = check_vk_result,
+    .RenderPass = wd->RenderPass
   };
-  ImGui_ImplVulkan_Init(&init_info, wd->RenderPass);
+  ImGui_ImplVulkan_Init(&init_info);
 
   igStyleColorsDark(NULL);
 
   // Upload Fonts
   // Use any command queue
-  VkCommandPool command_pool = wd->Frames[wd->FrameIndex].CommandPool;
-  VkCommandBuffer command_buffer = wd->Frames[wd->FrameIndex].CommandBuffer;
-
-  err = vkResetCommandPool(g_Device, command_pool, 0);
-  check_vk_result(err);
-  VkCommandBufferBeginInfo begin_info = {
-    .sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO,
-    .flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT,
-  };
-  err = vkBeginCommandBuffer(command_buffer, &begin_info);
-  check_vk_result(err);
-
-  ImGui_ImplVulkan_CreateFontsTexture(command_buffer);
-
-  VkSubmitInfo end_info = {
-    .sType = VK_STRUCTURE_TYPE_SUBMIT_INFO,
-    .commandBufferCount = 1,
-    .pCommandBuffers = &command_buffer,
-  };
-  err = vkEndCommandBuffer(command_buffer);
-  check_vk_result(err);
-  err = vkQueueSubmit(g_Queue, 1, &end_info, VK_NULL_HANDLE);
-  check_vk_result(err);
-
-  err = vkDeviceWaitIdle(g_Device);
-  check_vk_result(err);
-  ImGui_ImplVulkan_DestroyFontUploadObjects();
+  /* VkCommandPool command_pool = wd->Frames[wd->FrameIndex].CommandPool; */
+  /* VkCommandBuffer command_buffer = wd->Frames[wd->FrameIndex].CommandBuffer; */
+
+  /* err = vkResetCommandPool(g_Device, command_pool, 0); */
+  /* check_vk_result(err); */
+  /* VkCommandBufferBeginInfo begin_info = { */
+  /*   .sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO, */
+  /*   .flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT, */
+  /* }; */
+  /* err = vkBeginCommandBuffer(command_buffer, &begin_info); */
+  /* check_vk_result(err); */
+
+  /* ImGui_ImplVulkan_CreateFontsTexture(command_buffer); */
+
+  /* VkSubmitInfo end_info = { */
+  /*   .sType = VK_STRUCTURE_TYPE_SUBMIT_INFO, */
+  /*   .commandBufferCount = 1, */
+  /*   .pCommandBuffers = &command_buffer, */
+  /* }; */
+  /* err = vkEndCommandBuffer(command_buffer); */
+  /* check_vk_result(err); */
+  /* err = vkQueueSubmit(g_Queue, 1, &end_info, VK_NULL_HANDLE); */
+  /* check_vk_result(err); */
+
+  /* err = vkDeviceWaitIdle(g_Device); */
+  /* check_vk_result(err); */
+  /* ImGui_ImplVulkan_DestroyFontUploadObjects(); */
 
   bool showDemoWindow = true;
   bool showAnotherWindow = false;


mkdir build

cd build
cmake -DSDL_PATH="" ..
cmake --build .
```

これでできた cimgui_sdl.dll をロードする。
この DLL は ImGui を含んでいるので cimgui.dll はいらない。

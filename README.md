# 小米 10S(代号 thyme)的 KernelSU 内核编译

对于内核的更多了解，可以阅读[让 Android 手机更省电流畅，你可以试试「刷内核」](https://sspai.com/post/56296)一文。

## 源码

这里选择了 Pixel Experience 项目下的 `thyme` 内核，可以进[仓库源地址](https://github.com/PixelExperience-Devices/kernel_xiaomi_thyme)进行查看，为了方便进行 `KernelSU` 的编译，可以进入本人的[分支](https://github.com/DogDayAndroid/kernel_xiaomi_thyme)进行查看。

此外和，还有一些其他的内核仓库可以查看，本人测试了一部分，但是可能由于编译链原因无法正常刷入：

- [小米官方仓库](https://github.com/MiCode/Xiaomi_Kernel_OpenSource/tree/alioth-r-oss)，您可以在[仓库的自述文件](https://github.com/MiCode/Xiaomi_Kernel_OpenSource)中查看更多系统仓库，但是版本较老，且不维护，因此不太适合直接进行编译，需要打补丁。
- [Official-Ayrton990/android_kernel_xiaomi_sm8250](https://github.com/Official-Ayrton990/android_kernel_xiaomi_sm8250) 是一个关于 `CAF` 的仓库，也许支持的功能更多且更有利于编译，可以一试。
- [EmanuelCN/kernel_xiaomi_sm8250](https://github.com/EmanuelCN/kernel_xiaomi_sm8250)是一个未知版本且没有介绍的仓库，因此本人没有测试，但是较官方源其代码较新，可以尝试一下。
- 待续……

## 上游分支

在 Pixel Experience 内核的基础上，合并了部分上游分支，合并分支如下：

- ACK code branch: [android-4.19-stable/4.19.274](https://android.googlesource.com/kernel/common/+/refs/heads/android-4.19-stable)
    + Linux Upstream: [4.19.y/4.19.274](https://android.googlesource.com/kernel/common/+/refs/heads/upstream-f2fs-stable-linux-4.19.y)
- CLO code tag: [LA.UM.9.12.r1-14900.01-SMxx50.0](https://git.codelinaro.org/clo/la/kernel/msm-4.19/-/tree/LA.UM.9.12.r1-14900.01-SMxx50.0)

## 驱动

- ~~[Millet in mihw](https://github.com/MiCode/Xiaomi_Kernel_OpenSource/tree/zeus-s-oss/drivers/mihw)~~

## 工具链

工具链的选择请参考文章[[内核向] 交叉编译器的选择](https://www.akr-developers.com/d/129)以及[[白话文版] ClangBuiltLinux Clang 的使用](https://www.akr-developers.com/d/121)，同时可以配合[neutron-clang 的说明文档](https://github.com/Neutron-Toolchains/clang-build-catalogue/blob/main/README.md)来进行编译参数配置。

### 推荐工具

- [neutron-clang](https://github.com/Neutron-Toolchains/clang-build-catalogue)：这是为内核开发构建的 LLVM 和 Clang 编译器工具链。构建始终是从最新的 LLVM 源代码而不是稳定版本构建的，~~因此无法保证完全的稳定性~~。
- [阿菌•未霜 Clang/LLVM Toolchain with Binutils](https://gitea.com/Mandi-Sa/clang)：这是一个预构建的工具链，构建始终来自最新的 LLVM 和 Binutils 源而不是稳定版本，因此无法保证完全的稳定性。它是用 Full LTO、PGO 和 BOLT 构建的，以尽可能减少编译时间。
- [ClangBuiltLinux/tc-build](https://github.com/ClangBuiltLinux/tc-build)：类似前两个工具，但是这个工具需要自己在本地从 LLVM 的源码进行构建，但编译时间较长。

### 其他工具

- 最好的选择是从预编译内核机器的 `/proc/config.gz` 提取`，需要 [COMPILE_CROSS](https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/+refs) 以及 [CLANG](https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+/refs/heads/master)，自行选择合适版本下载即可，通过这种方式编译出来的配合度是最好的。

## 打包

内核编译完成后的打包请参考文章[[内核向] 论如何优雅的刷入内核](https://www.akr-developers.com/d/125),目前最流行的方法是使用 [osm0sis/AnyKernel3](https://github.com/osm0sis/AnyKernel3) 来完成整个内核的打包刷入工作。

如果您更喜欢自己动手，那么请参考文章内的其他方法。

> 值得注意的是，不同版本的内核编译出来的内容并不相同，因此需要区分他们之间的打包，详情请参考文章：[关于 Image.xx-dtb 和 Image.xx + dtb 的区别](https://www.akr-developers.com/d/482)。
> 来自文章的评论区：_对应芯片组的。比如 865 只需要 kona-v2.1.dtb。如果弄不清楚，可以使用 cat 命令将多个 dtb 连接在一起，bootloader 会自动识别。_

## 常见编译错误

### 1. -Werror=implicit-int

```
/arch/arm64/kernel/smp.c:834:8: error: type defaults to ‘int’ in declaration of ‘in_long_press’ [-Werror=implicit-int]
```
您可以修改 `extern in_long_press` 为 `extern int in_long_press`;或者去除[MakeFile中对应错误限制](https://github.com/MiCode/Xiaomi_Kernel_OpenSource/blob/b286e90108628643abec72c90deefbd1c17c4f94/Makefile#L922)

## 其他

如果您想用手机或者 Docker 容器运行编译程序的花，请参考文章[手机端编译安卓内核](https://zixijian.github.io/2021/01/15/008.html)以及[使用 docker 简单编译 k20pro 内核](https://www.cnblogs.com/ink19/p/build_k20pro_kernel.html)。

## 参考

### 编译指南[基础]

- [小米官方内核编译维基文档](https://github.com/MiCode/Xiaomi_Kernel_OpenSource/wiki/How-to-compile-kernel-standalone)
- [如何自己编译自定义 Android ROM](https://www.akr-developers.com/d/107)
- [迅速入门 Android 内核编译 & 一加 5 DC 调光](https://makiras.org/archives/173)
- [獨立編譯 Android kernel(核心)，以小米手機為例](https://ivonblog.com/posts/how-to-compile-custom-android-kernel)
- [[GUIDE] How To Compile Kernel & DTBO For Redmi K20 Pro](https://forum.xda-developers.com/t/guide-how-to-compile-kernel-dtbo-for-redmi-k20-pro.3971443/)
- [红米 8A 内核编译过程记录](https://www.jianshu.com/p/af7b38001946)
- [从0开始编译安卓内核](https://blog.5ixf.cc/#/paper/18)
- [Guide to Compile an Android Kernel with Clang](https://gist.github.com/P1N2O/b9b2604c58aa4d7486e2fc0d327d23dc)
- [Compiling an Android kernel with Clang](https://github.com/nathanchance/android-kernel-clang)

### 编译指南[进阶]

- [从零开始的 git 实战之 CAF TAG 的合并](https://www.akr-developers.com/d/140)
- [合并上游部分参考（来自论坛问答）](https://www.akr-developers.com/d/166)
- [如何为非 GKI 内核集成 KernelSU](https://kernelsu.org/zh_CN/guide/how-to-integrate-for-non-gki.html)

## 致谢

- [weishu](https://github.com/tiann) : KernelSU 的开发者
- [Pixel Experience](https://wiki.pixelexperience.org/) ： 内核提供
- [Lynnrin-Studio](https://github.com/Lynnrin-Studio) ： 内核提供
- [AKR 安卓开发者社区](https://www.akr-developers.com/) ： 编译教程提供
- [xiaoleGun/KernelSU_Action](https://github.com/xiaoleGun/KernelSU_Action) ： 借鉴部分 Github Action
- [UtsavBalar1231/Drone-scripts](https://github.com/UtsavBalar1231/Drone-scripts) ： 借鉴部分 Github Action

#!/bin/bash

# TODO: 增加选择菜单

# 计时器
START_SEC=$(date +%s)

# 获取当前路径
CURRENT_DIR=$(pwd)

# 设置目标内核
TARGET_KERNEL="Lynnrin"

# 设置编译目录
THYME_KERNEL_DIR="$CURRENT_DIR/Kernel_Source/$TARGET_KERNEL"
# CLANG_DIR="$CURRENT_DIR/toolchains/neutron-clang"
CLANG_DIR="$CURRENT_DIR/toolchains/tc-build/install"
ANYKERNEL_DIR="$CURRENT_DIR/toolchains/AnyKernel3"

# 参数设定
CC="$CLANG_DIR/bin/clang"

THREAD=$(($(nproc --all) / 2))
ARCH=arm64
OUT_DIR="$CURRENT_DIR/out/${TARGET_KERNEL}"

# 使用 neutron-clang 无需使用 Triple
CROSS_COMPILE=aarch64-linux-gnu-
CROSS_COMPILE_COMPAT=arm-linux-gnueabi-
CC_ADDITION_FLAGS="AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip LLVM_IAS=1 LLVM=1"

# 编译参数
args="-j$THREAD \
	O=$OUT_DIR \
	ARCH=$ARCH \
	CROSS_COMPILE=$CROSS_COMPILE \
    CROSS_COMPILE_COMPAT=$CROSS_COMPILE_COMPAT \
    $CC_ADDITION_FLAGS \
	CC=$CC"

# 添加proton-clang到路径搜索目录中
export PATH="$CLANG_DIR/bin:$PATH"

#export DEFCONFIG_PATH=arch/arm64/configs
DEFCONFIG_NAME=thyme_defconfig

# 准备KernelSU
prepare() {
	echo "------------------------------"
	echo " Update the KernelSU drivers  "
	echo "------------------------------"

	cd $THYME_KERNEL_DIR

	rm -rf ./KernelSU
	rm -rf ./drivers/kernelsu
	curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -

	git submodule foreach --recursive git reset --hard
	git submodule update --init --recursive

	cd $CURRENT_DIR
}

# 构建默认配置
make_defconfig() {
	echo "------------------------------"
	echo "  Building Kernel Defconfig   "
	echo "------------------------------"

	cd $THYME_KERNEL_DIR

	make ${args} $DEFCONFIG_NAME

	cd ${THYME_KERNEL_DIR} || exit
}

# 内核构建
build_kernel() {
	echo "------------------------------"
	echo "       Building Kernel        "
	echo "------------------------------"

	#cd $THYME_KERNEL_DIR

	make ${args}

	END_SEC=$(date +%s)
	COST_SEC=$(($END_SEC - $START_SEC))
	echo "Kernel Build Costed $(($COST_SEC / 60))min $(($COST_SEC % 60))s"

	#find ${OUT_DIR}/$dts_source -name '*.dtb' -exec cat {} + >${OUT_DIR}/arch/arm64/boot/dtb

	cd $CURRENT_DIR
}

# 清除以往的构建
clean() {
	echo "------------------------------"
	echo "      Clean old builds        "
	echo "------------------------------"

	# 清楚以往的刷机包
	cd $CURRENT_DIR
	rm -rf $CURRENT_DIR/*.zip

	# 清楚以往的构建文件
	cd $THYME_KERNEL_DIR
	echo "Clean source tree and build files..."
	make mrproper -j$THREAD
	make clean -j$THREAD
	rm -rf $OUT_DIR
	cd $CURRENT_DIR
}

# 构建AnyKernel3包
buildAnyKernel() {
	echo "------------------------------"
	echo "    Build flashable zip       "
	echo "------------------------------"

	cd $CURRENT_DIR
	cp -rf $OUT_DIR/arch/arm64/boot/Image $ANYKERNEL_DIR/Image
	#cp -rf $OUT_DIR/arch/arm64/boot/dtb $ANYKERNEL_DIR/dtb;
	#cp -rf $OUT_DIR/arch/arm64/boot/dtbo.img $ANYKERNEL_DIR/dtbo.img;
	cd $ANYKERNEL_DIR
	OUTPUT_FILE=KSU_${TARGET_KERNEL}-Thyme-$(date +"%y.%m.%d").zip
	zip -r $OUTPUT_FILE *
	mv $OUTPUT_FILE $CURRENT_DIR/$OUTPUT_FILE
	rm -rf $OUTPUT_FILE

	echo "The output is $OUTPUT_FILE"
	cd $CURRENT_DIR
}

main() {
	clean && \
	prepare && \
	make_defconfig && \
	build_kernel && \
	buildAnyKernel
}

# 构建工具链
buildCBL(){
	cd toolchains/tc-build
	./build-llvm.py -I "$CURRENT_DIR/toolchains/CBL-Tools"
	cd $CURRENT_DIR
}

# 执行程序并输出日志
main 2>&1 | tee "$CURRENT_DIR/build_kernel.log"

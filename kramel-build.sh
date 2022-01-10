wget -O 64.zip https://github.com/mvaisakh/gcc-arm64/archive/85b79055a926ffa45ed7ce0005731d7bda4db137.zip;unzip 64.zip;mv gcc-arm64-85b79055a926ffa45ed7ce0005731d7bda4db137 gcc64
wget -O 32.zip https://github.com/mvaisakh/gcc-arm/archive/b9cada9f629b7b3f72b201c77d93042695de33fc.zip;unzip 32.zip;mv gcc-arm-b9cada9f629b7b3f72b201c77d93042695de33fc gcc32
git clone --depth=1 https://github.com/farizmaul/AnyKernel3.git

IMAGE=$(pwd)/out/arch/arm64/boot/Image
DTBO=$(pwd)/out/arch/arm64/boot/dtbo.img
DTB=$(pwd)/out/arch/arm64/boot/dtb
START=$(date +"%s")
BRANCH=$(git rev-parse --abbrev-ref HEAD)
VERSION=ZeeMoy
TANGGAL=${VERSION}-$(TZ=Asia/Jakarta date "+%Y%m%d-%H%M")
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_HOST="cyber"
export KBUILD_BUILD_USER="ricoayuba"
#main group
export chat_id="-1001726996867"
#channel
export chat_id2="-1001608547174"
export DEF="vendor/arrow_alioth_defconfig"
TC_DIR=${PWD}
GCC64_DIR="${PWD}/gcc64"
GCC32_DIR="${PWD}/gcc32"
export PATH=$GCC64_DIR/bin/:$GCC32_DIR/bin/:/usr/bin:$PATH

curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d text="Buckle up bois ${BRANCH} build has started" -d chat_id=${chat_id} -d parse_mode=HTML

# make defconfig
    make ARCH=arm64 \
        O=out \
        $DEF \
        -j"$(nproc --all)"

# make olddefconfig
cd out
make O=out \
	ARCH=arm64 \
	olddefconfig
cd ../

# compiling
    make -j$(nproc --all) O=out \
				ARCH=arm64 \
				LOCALVERSION=-${TANGGAL} \
				CROSS_COMPILE_ARM32=arm-eabi- \
				CROSS_COMPILE=aarch64-elf- \
				LD=aarch64-elf-ld.lld 2>&1 | tee build.log

END=$(date +"%s")
DIFF=$((END - START))

if [ -f $(pwd)/out/arch/arm64/boot/Image ]
	then
# Post to CI channel
curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d text="Branch: <code>$(git rev-parse --abbrev-ref HEAD)</code>
Compiler Used : <code>gcc version 12.0.0 20211104 LLD 14.0.0</code>
Latest Commit: <code>$(git log --pretty=format:'%h : %s' -1)</code>
<i>Build compiled successfully in $((DIFF / 60)) minute(s) and $((DIFF % 60)) seconds</i>" -d chat_id=${chat_id} -d parse_mode=HTML

cp ${IMAGE} $(pwd)/AnyKernel3
cp ${DTBO} $(pwd)/AnyKernel3
cp ${DTB} $(pwd)/AnyKernel3

        cd AnyKernel3
        zip -r9 HyperX-${TANGGAL}.zip * --exclude *.jar

        curl -F chat_id="${chat_id}"  \
                    -F caption="sha1sum: $(sha1sum Hyp*.zip | awk '{ print $1 }')" \
                    -F document=@"$(pwd)/HyperX-${TANGGAL}.zip" \
                    https://api.telegram.org/bot${TOKEN}/sendDocument

        curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendSticker" \
        -d sticker="CAACAgUAAxkBAAJi017AAw5j25_B3m8IP-iy98ffcGHZAAJAAgACeV4XIusNfRHZD3hnGQQ" \
        -d chat_id="$chat_id"
	
	curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d text="hi guys, the latest update is available on @HyperX_Archive !" -d chat_id=${chat_id2} -d parse_mode=HTML

cd ..
else
        curl -F chat_id="${chat_id}"  \
                    -F caption="Build ended with an error, F in the chat plox" \
                    -F document=@"build.log" \
                    https://api.telegram.org/bot${TOKEN}/sendDocument

        curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendSticker" \
        -d sticker="CAACAgUAAxkBAAK74mCvV3W62vmSIcqQo61RtBxEK0dVAALGAgACw2B4VehbCiKmZwTjHwQ" \
        -d chat_id="$chat_id"

fi

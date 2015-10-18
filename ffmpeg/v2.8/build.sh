#!/bin/sh

set -e

test -z "$NAME" && >&2 echo "Package NAME not set." && exit 1
test -z "$VERSION" && >&2 echo "Version for $NAME not set." && exit 1

OUT_DIR="$1"
BUILD_DIR=`mktemp -d`
VENDOR_DIR="/app/vendor"
PREFIX="${VENDOR_DIR}/${NAME}"
PACKAGE="${NAME}-${VERSION}"

cd $BUILD_DIR
tar -xf "${OUT_DIR}/deps/yasm.tar.gz"
export PATH="$PATH:${BUILD_DIR}/yasm/bin"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${BUILD_DIR}/yasm/lib"

curl "https://ffmpeg.org/releases/${PACKAGE}.tar.gz" | tar -xz

cd ${NAME}-*
./configure \
    --prefix="$PREFIX" \
    --enable-shared \
    --enable-ffprobe \
    --disable-static \
    --disable-ffplay \
    --disable-ffserver \
    --disable-doc \
    \
    --enable-decoder=nellymoser \
    --enable-decoder=flv \
    --enable-decoder=yuv4 \
    --enable-decoder=wmalossless \
    --enable-decoder=wmapro \
    --enable-decoder=wmav1 \
    --enable-decoder=wmav2 \
    --enable-decoder=wmavoice \
    --enable-decoder=wmv1 \
    --enable-decoder=wmv2 \
    --enable-decoder=wmv3 \
    --enable-decoder=wmv3_crystalhd \
    --enable-decoder=wmv3image \
    --enable-decoder=wmv3_vdpau \
    --enable-decoder=vp8 \
    --enable-decoder=vorbis \
    --enable-decoder=h264 \
    --enable-decoder=h264_crystalhd \
    --enable-decoder=h264_vda \
    --enable-decoder=h264_vdpau \
    --enable-decoder=flac \
    --enable-decoder=flashsv \
    --enable-decoder=flashsv2 \
    --enable-decoder=fraps \
    --enable-decoder=aac \
    --enable-decoder=aac_latm \
    --enable-decoder=ac3 \
    --enable-decoder=jpeg2000 \
    --enable-decoder=jpegls \
    --enable-decoder=libopenjpeg \
    --enable-decoder=mjpeg \
    --enable-decoder=mjpegb \
    --enable-decoder=smvjpeg \
    --enable-decoder=gif \
    --enable-decoder=png \
    --enable-decoder=tiff \
    --enable-decoder=theora \
    \
    --enable-encoder=aac \
    --enable-encoder=ac3 \
    --enable-encoder=ac3_fixed \
    --enable-encoder=ayuv \
    --enable-encoder=bmp \
    --enable-encoder=dvbsub \
    --enable-encoder=dvdsub \
    --enable-encoder=ffv1 \
    --enable-encoder=ffvhuff \
    --enable-encoder=flac \
    --enable-encoder=flashsv \
    --enable-encoder=flashsv2 \
    --enable-encoder=flv \
    --enable-encoder=gif \
    --enable-encoder=jpeg2000 \
    --enable-encoder=jpegls \
    --enable-encoder=libaacplus \
    --enable-encoder=libfaac \
    --enable-encoder=libfdk_aac \
    --enable-encoder=libgsm \
    --enable-encoder=libgsm_ms \
    --enable-encoder=libilbc \
    --enable-encoder=libmp3lame \
    --enable-encoder=libopencore_amrnb \
    --enable-encoder=libopenjpeg \
    --enable-encoder=libopus \
    --enable-encoder=libspeex \
    --enable-encoder=libtheora \
    --enable-encoder=libvorbis \
    --enable-encoder=libvpx_vp8 \
    --enable-encoder=libvpx_vp9 \
    --enable-encoder=libx264 \
    --enable-encoder=libx264rgb \
    --enable-encoder=libxavs \
    --enable-encoder=ljpeg \
    --enable-encoder=mjpeg \
    --enable-encoder=mpeg4 \
    --enable-encoder=nellymoser \
    --enable-encoder=png \
    --enable-encoder=tiff \
    --enable-encoder=vorbis \
    --enable-encoder=wmav1 \
    --enable-encoder=wmav2 \
    --enable-encoder=wmv1 \
    --enable-encoder=wmv2 \
    --enable-encoder=yuv4

make -j2
DESTDIR="${BUILD_DIR}" make install

cd "${BUILD_DIR}${PREFIX}"
rm -Rf share

cd "${BUILD_DIR}${VENDOR_DIR}"
tar -caf "${OUT_DIR}/${PACKAGE}.tar.gz" "$NAME"

cat > "${OUT_DIR}/$PACKAGE.sh" << EOF
#!/bin/sh

unpack "\$INSTALLER_DIR/$PACKAGE.tar.gz" `md5sum $OUT_DIR/$PACKAGE.tar.gz | cut -d" " -f1`
env_extend PATH "${PREFIX}/bin"
env_extend LD_LIBRARY_PATH "${PREFIX}/lib"
EOF

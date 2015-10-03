#!/bin/sh

set -e

OUT_DIR="$1"
BUILD_DIR=`mktemp -d`
PREFIX="/app/vendor/pcre"
VENDOR_DIR="`basename $PREFIX`"
NAME="pcre-8.37"

cd $BUILD_DIR

curl "ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/$NAME.tar.gz" | tar -xz
cd pcre-*
./configure --prefix="$PREFIX" \
	--enable-utf \
	--enable-unicode-properties
make
make install DESTDIR="$BUILD_DIR"

cd ${BUILD_DIR}${PREFIX}
rm -Rf share

cd ..
tar -caf "$OUT_DIR/$NAME.tar.gz" "$VENDOR_DIR"

cat > ${OUT_DIR}/$NAME.sh << EOF
#!/bin/sh

unpack "\$INSTALLER_DIR/$NAME.tar.gz" `md5sum $OUT_DIR/$NAME.tar.gz | cut -d" " -f1`
echo 'export LD_LIBRARY_PATH="\$LD_LIBRARY_PATH:${PREFIX}/lib"' >> \${BUILD_DIR}/boot.sh
export LD_LIBRARY_PATH="\$LD_LIBRARY_PATH:\${BUILD_DIR}/vendor/pcre/lib"
EOF

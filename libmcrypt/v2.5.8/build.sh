#!/bin/sh

set -e

OUT_DIR="$1"
BUILD_DIR=`mktemp -d`
PREFIX="/app/vendor/libmcrypt"
VENDOR_DIR="`basename $PREFIX`"
NAME="libmcrypt-2.5.8"

cd $BUILD_DIR

curl http://netcologne.dl.sourceforge.net/project/mcrypt/Libmcrypt/2.5.8/$NAME.tar.gz | tar -xz
cd libmcrypt-*
./configure --prefix="$PREFIX"
make
make install DESTDIR=$BUILD_DIR

cd ${BUILD_DIR}${PREFIX}
rm -Rf man
cd ..
tar -caf "$OUT_DIR"/$NAME.tar.gz "$VENDOR_DIR"

cat > ${OUT_DIR}/$NAME.sh << EOF
#!/bin/sh

unpack "\$INSTALLER_DIR/$NAME.tar.gz" `md5sum $OUT_DIR/$NAME.tar.gz | cut -d" " -f1`
echo 'export LD_LIBRARY_PATH="\$LD_LIBRARY_PATH:/app/vendor/libmcrypt/lib"' >> \${BUILD_DIR}/boot.sh
EOF
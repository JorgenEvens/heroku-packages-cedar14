#!/bin/sh

set -e

test -z "$NAME" && >&2 echo "Package NAME not set." && exit 1
test -z "$VERSION" && >&2 echo "Version for $NAME not set." && exit 1

OUT_DIR="$1"
BUILD_DIR=`mktemp -d`
PREFIX="/app/vendor/libmcrypt"
VENDOR_DIR="`basename $PREFIX`"
PACKAGE="${NAME}-${VERSION}"

cd $BUILD_DIR

curl "http://netcologne.dl.sourceforge.net/project/mcrypt/Libmcrypt/${VERSION}/$PACKAGE.tar.gz" | tar -xz
cd libmcrypt-*
./configure --prefix="$PREFIX"
make
make install DESTDIR=$BUILD_DIR

cd ${BUILD_DIR}${PREFIX}
rm -Rf man
cd ..
tar -caf "$OUT_DIR"/$PACKAGE.tar.gz "$VENDOR_DIR"

cat > ${OUT_DIR}/$PACKAGE.sh << EOF
#!/bin/sh

unpack "\$INSTALLER_DIR/$PACKAGE.tar.gz" `md5sum $OUT_DIR/$PACKAGE.tar.gz | cut -d" " -f1`
echo 'export LD_LIBRARY_PATH="\$LD_LIBRARY_PATH:/app/vendor/libmcrypt/lib"' >> \${BUILD_DIR}/boot.sh
EOF
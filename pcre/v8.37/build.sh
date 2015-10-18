#!/bin/sh

set -e

test -z "$NAME" && >&2 echo "Package NAME not set." && exit 1
test -z "$VERSION" && >&2 echo "Version for $NAME not set." && exit 1

OUT_DIR="$1"
BUILD_DIR=`mktemp -d`
PREFIX="/app/vendor/pcre"
VENDOR_DIR="`basename $PREFIX`"
PACKAGE="${NAME}-${VERSION}"

cd $BUILD_DIR

curl "ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/$PACKAGE.tar.gz" | tar -xz
cd pcre-*
./configure --prefix="$PREFIX" \
	--enable-utf \
	--enable-unicode-properties
make -j2
make install DESTDIR="$BUILD_DIR"

cd ${BUILD_DIR}${PREFIX}
rm -Rf share

cd ..
tar -caf "$OUT_DIR/$PACKAGE.tar.gz" "$VENDOR_DIR"

cat > ${OUT_DIR}/$PACKAGE.sh << EOF
#!/bin/sh

unpack "\$INSTALLER_DIR/$PACKAGE.tar.gz" `md5sum $OUT_DIR/$PACKAGE.tar.gz | cut -d" " -f1`
env_extend LD_LIBRARY_PATH "${PREFIX}/lib"
EOF

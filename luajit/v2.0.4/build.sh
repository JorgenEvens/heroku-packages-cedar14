#!/bin/sh

set -e

test -z "$NAME" && >&2 echo "Package NAME not set." && exit 1
test -z "$VERSION" && >&2 echo "Version for $NAME not set." && exit 1

OUT_DIR="$1"
BUILD_DIR=`mktemp -d`
PREFIX="/app/vendor/luajit"
VENDOR_DIR="`basename $PREFIX`"
PACKAGE="${NAME}-${VERSION}"

cd $BUILD_DIR
curl "http://luajit.org/download/LuaJIT-${VERSION}.tar.gz" | tar -xz

cd LuaJIT-*
make PREFIX="$PREFIX"
make install PREFIX="$PREFIX" DESTDIR=${BUILD_DIR}

cd ${BUILD_DIR}${PREFIX}
rm -Rf share/man

cd ..
tar -caf "${OUT_DIR}/$PACKAGE.tar.gz" luajit

cat > ${OUT_DIR}/$PACKAGE.sh << EOF
#!/bin/sh

unpack "\$INSTALLER_DIR/$PACKAGE.tar.gz" `md5sum $OUT_DIR/$PACKAGE.tar.gz | cut -d" " -f1`
echo 'export LD_LIBRARY_PATH="\$LD_LIBRARY_PATH:/app/vendor/luajit/lib"' >> \${BUILD_DIR}/boot.sh
echo 'export PATH="\$PATH:/app/vendor/luajit/bin"' >> \${BUILD_DIR}/boot.sh
EOF
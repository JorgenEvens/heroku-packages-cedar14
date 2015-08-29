#!/bin/sh

set -e

OUT_DIR="$1"
BUILD_DIR=`mktemp -d`
PREFIX="/app/vendor/luajit"
VENDOR_DIR="`basename $PREFIX`"
NAME="luajit-2.0.4"

cd $BUILD_DIR
curl http://luajit.org/download/LuaJIT-2.0.4.tar.gz | tar -xz

cd LuaJIT-*
./configure --prefix="$PREFIX"
make PREFIX="$PREFIX"
make install PREFIX="$PREFIX" DESTDIR=${BUILD_DIR}

cd ${BUILD_DIR}${PREFIX}
rm -Rf share/man

cd ..
tar -caf "${OUT_DIR}/$NAME.tar.gz" luajit

cat > ${OUT_DIR}/$NAME.sh << EOF
#!/bin/sh

unpack "\$INSTALLER_DIR/$NAME.tar.gz" `md5sum $OUT_DIR/$NAME.tar.gz | cut -d" " -f1`
echo 'export LD_LIBRARY_PATH="\$LD_LIBRARY_PATH:/app/vendor/luajit/lib"' >> \${BUILD_DIR}/boot.sh
echo 'export PATH="\$PATH:/app/vendor/luajit/bin"' >> \${BUILD_DIR}/boot.sh
EOF
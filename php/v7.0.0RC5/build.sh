#!/bin/sh

set -e

# Generates php-fpm and php-cli packages and php extension packages
# for use with the heroku modular buildpack
# https://github.com/JorgenEvens/heroku-modular-buildpack

### Configuration ###
OUTPUT_DIR="$1"
DIR_LIBS="$OUTPUT_DIR/deps"
BUILD_DIR=`mktemp -d`
VENDOR="/app/vendor"
PREFIX="$VENDOR/$NAME"
VENDOR_DIR="`basename $PREFIX`"

if [ -z "$PHP_VERSION" ]; then
    >&2 echo "Please specify the version to build"
    exit 1
fi

if [ -z "$PHP_API" ]; then
    PHP_API="20151012"
fi

if [ -z "$PHP_URL" ]; then
    PHP_URL="http://be2.php.net/distributions/php-${PHP_VERSION}.tar.bz2"
fi

if [ -z "$DIR_LIBS" ]; then
    >&2 echo "Location of libraries not set"
    exit 1
fi

if [ ! -d "$DIR_LIBS" ]; then
    mkdir -p "$DIR_LIBS"
fi

LIB_LIBMCRYPT="$DIR_LIBS/libmcrypt.tar.gz"
LIB_LIBPCRE="$DIR_LIBS/pcre.tar.gz"

### SCRIPT ###
### Do not edit below ###

error() {
    >&2 echo $@
    exit 1
}

cd $BUILD_DIR

# Download required libraries
mkdir -p ${BUILD_DIR}${PREFIX}
cd ${BUILD_DIR}${PREFIX}/..

if [ ! -f "$LIB_LIBMCRYPT" ]; then
    error "libmcrypt is missing."
fi
tar -xf "$LIB_LIBMCRYPT"

if [ ! -f "$LIB_LIBPCRE" ]; then
    error "libpcre is missing."
fi
tar -xf "$LIB_LIBPCRE"

# Set environment variables for LD
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${BUILD_DIR}/vendor/libmcrypt/lib:${BUILD_DIR}/vendor/pcre/lib"

# Download PHP Source
cd ${BUILD_DIR}
curl $PHP_URL | tar -xj
cd php-*

# Configure PHP Source
./configure --prefix="${PREFIX}" \
    --enable-fpm \
    --enable-cli \
    --disable-cgi \
    --disable-debug \
    --with-regex=php \
    --disable-rpath \
    --disable-static \
    --with-pic \
    --with-layout=GNU \
    --without-pear \
    --enable-calendar \
    --enable-sysvsem \
    --enable-sysvshm \
    --enable-sysvmsg \
    --enable-bcmath \
    --with-bz2 \
    --with-curl=shared,/usr \
    --enable-ctype \
    --with-iconv=shared \
    --with-jpeg-dir=/usr \
    --with-png-dir=/usr \
    --with-freetype-dir=/usr \
    --with-gd=shared \
    --enable-exif \
    --enable-ftp \
    --with-gettext=shared \
    --enable-mbstring \
    --with-pcre-regex="${BUILD_DIR}${VENDOR}/pcre" \
    --with-pcre-dir="${BUILD_DIR}${VENDOR}/pcre" \
    --disable-shmop \
    --enable-sockets \
    --enable-wddx=shared \
    --with-libxml-dir=shared,/usr \
    --with-zlib \
    --without-kerberos \
    --with-openssl \
    --enable-soap=shared \
    --enable-zip=shared \
    --with-mhash=yes \
    --without-mm \
    --enable-pdo=shared \
    --with-pdo-mysql=shared \
    --disable-dba \
    --enable-inifile \
    --with-config-file-scan-dir="${PREFIX}/etc/conf.d" \
    --enable-flatfile \
    --with-mysql=shared \
    --with-mysqli=shared \
    --without-sybase-ct \
    --without-mssql \
    --with-sqlite3=shared \
    --with-pdo-sqlite=shared \
    --with-pgsql=shared \
    --enable-json=shared \
    --without-ldap \
    --with-mcrypt=shared,"${BUILD_DIR}${VENDOR}/libmcrypt" \
    --enable-opcache=shared \
    --enable-session \
    --without-snmp \
    --enable-xml=shared \
    --enable-mysqlnd \
    --enable-shared \
    --enable-dom=shared \
    --enable-xmlreader=shared

# Make and install
make -j2
INSTALL_ROOT="${BUILD_DIR}" make install

# Move extensions to separate folder
cd ${BUILD_DIR}${PREFIX}/..
cat ${NAME}/etc/php-fpm.conf.default | grep -v -P "^;" | grep -P "[^\s].+" > ${NAME}/etc/php-fpm.conf
sed -i 's/listen\s=\s.*/listen = \/app\/vendor\/${NAME}\/var\/run\/socket/' ${NAME}/etc/php-fpm.conf

##############################################
# Prepare extensions to be packaged
##############################################
mkdir -p extensions
mv ${NAME}/lib/php/${PHP_API}/* extensions

##############################################
# Prepare CLI to be packaged
##############################################
mkdir -p cli
cp -a ${NAME} cli/${NAME}
rm cli/${NAME}/sbin/php-fpm

tar -C cli -caf ${NAME}-cli-${PHP_VERSION}.tar.gz ${NAME}

MD5=$(md5sum ${NAME}-cli-${PHP_VERSION}.tar.gz | cut -d" " -f1)
cat > "${NAME}-cli-$PHP_VERSION.sh" << EOF
#!/bin/sh

PHP5_BIN="${NAME}-cli-${PHP_VERSION}.tar.gz"

dependency_mark "${NAME}-cli-${PHP_VERSION}"
dependency_require "php-${PHP_VERSION}"

unpack "\${INSTALLER_DIR}/\${PHP5_BIN}" "$MD5"
EOF

##############################################
# Clean CLI from package
##############################################
rm ${NAME}/bin/php

# Compress build of PHP5-fpm without extensions
tar -caf ${NAME}-${PHP_VERSION}.tar.gz ${NAME}

EXT_SRC="extensions"
EXT_DIR="lib/php/$PHP_API"
WORK_DIR="tmp/${NAME}"
CUR_DIR="`pwd`"

for pkg in `ls $EXT_SRC | grep -o '[^\.]\+\.' | sort | uniq | tr -d '.'`; do
	echo "Packaging ${pkg}"

	package="${NAME}-${pkg}-${PHP_VERSION}"
    pkg_type=""

    if [ "${pkg}" = "opcache" ]; then
        pkg_type="zend_"
    fi

	mkdir -p "${WORK_DIR}/${EXT_DIR}"
	cp $EXT_SRC/${pkg}.* "${WORK_DIR}/${EXT_DIR}"

	cd "`dirname ${WORK_DIR}`"
	tar -c ${NAME} | gzip > "${package}.tar.gz"

	mv "${package}.tar.gz" "$CUR_DIR"
	cd "$CUR_DIR"

	MD5=$(md5sum ${package}.tar.gz | cut -d" " -f1)

##############################################
# Extension installer script
##############################################
	cat > "${package}.sh" << EOF
#!/bin/sh

PHP5EXT_VERSION="$PHP_VERSION"
PHP5EXT_MD5="$MD5"
PHP5EXT_NAME="${pkg}"
PHP5EXT_BIN="${NAME}-\${PHP5EXT_NAME}-\${PHP5EXT_VERSION}.tar.gz"

dependency_require "php-\$PHP5EXT_VERSION"

unpack "\${INSTALLER_DIR}/\${PHP5EXT_BIN}" "\$PHP5EXT_MD5"
php5_ext_enable "\$PHP5EXT_NAME" ${pkg_type}
EOF

	rm -Rf ${WORK_DIR}
done

##############################################
# Installer script
##############################################
cat > "${NAME}-$PHP_VERSION.sh" << EOF
#!/bin/sh

PHPFPM_VERSION="$PHP_VERSION"
PHPFPM_MD5="$(md5sum ${NAME}-${PHP_VERSION}.tar.gz | cut -d" " -f1)"
PHPFPM_BIN="${NAME}-\${PHPFPM_VERSION}.tar.gz"

dependency_require "pcre-8.37"
dependency_require "libmcrypt-2.5.8"

unpack "\${INSTALLER_DIR}/\${PHPFPM_BIN}" "\$PHPFPM_MD5"
env_extend PATH "${PREFIX}/bin"
env_extend PATH "${PREFIX}/sbin"

mkdir -p "${VENDOR}"
ln -s "\${BUILD_DIR}/vendor/${NAME}" "${PREFIX}"

print_action "Generating boot portion for PHP5-FPM"
echo "${PREFIX}/sbin/php-fpm &" >> "\${BUILD_DIR}/boot.sh"

dependency_mark "php-\$PHPFPM_VERSION"

php5_ext_enable() {
	local config
	local extension
	local ext_type

	extension="\$1"
	ext_type="\$2"

	config="\${BUILD_DIR}/vendor/${NAME}/etc/php.ini"

	if [ ! -f "\$config" ]; then
		echo "[PHP]" >> "\$config"
	fi
	echo "\${ext_type}extension=\${extension}.so" >> "\$config"
}
EOF

# Compress everything into one archive
mv ${NAME}-*.tar.gz "$OUTPUT_DIR"
mv ${NAME}-*.sh "$OUTPUT_DIR"

#!/bin/sh

set -e

test -z "$NAME" && >&2 echo "Package NAME not set." && exit 1

OUT_DIR="$1"
VENDOR_DIR="/app/vendor"
PREFIX="${VENDOR_DIR}/${NAME}"

cat > "${OUT_DIR}/${NAME}.sh" << EOF
#!/bin/sh

mkdir -p "\${BUILD_DIR}$PREFIX"
export PATH="\${PATH}:\${BUILD_DIR}${PREFIX}"
curl -sS "https://getcomposer.org/installer" | php -- --filename=composer --install-dir="\${BUILD_DIR}$PREFIX"
echo 'export PATH="\${PATH}:${PREFIX}"' >> \${BUILD_DIR}/configure.sh
EOF

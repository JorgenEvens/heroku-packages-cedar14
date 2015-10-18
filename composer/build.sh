#!/bin/sh

set -e

test -z "$NAME" && >&2 echo "Package NAME not set." && exit 1

OUT_DIR="$1"
PREFIX="/app/vendor/${NAME}"
DESTDIR="\${BUILD_DIR}/vendor/${NAME}"

cat > "${OUT_DIR}/${NAME}.sh" << EOF
#!/bin/sh

env_extend PATH "$PREFIX"
mkdir -p "$DESTDIR"
curl -sS "https://getcomposer.org/installer" | php -- --filename=composer --install-dir="$DESTDIR"
EOF

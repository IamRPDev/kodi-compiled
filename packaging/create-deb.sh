#!/usr/bin/env bash
# Usage:
#   packaging/create-deb.sh /path/to/xbmc <version-or-commit> <build-dir> <out-dir>
set -euo pipefail
if [ $# -lt 4 ]; then
  echo "Usage: $0 /path/to/xbmc version build-dir out-dir"
  exit 2
fi

XBMC_SRC="$1"
VERSION="$2"
BUILD_DIR="$3"
OUT_DIR="$4"
PREFIX="/opt/kodi"

mkdir -p "${BUILD_DIR}"
mkdir -p "${OUT_DIR}"

cmake -S "${XBMC_SRC}" -B "${BUILD_DIR}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DENABLE_TESTS=OFF

cmake --build "${BUILD_DIR}" -- -j$(nproc)
cmake --install "${BUILD_DIR}" --prefix "${PREFIX}" --DESTDIR="${BUILD_DIR}/staging" || \
  cp -a "${BUILD_DIR}/install-root/." "${BUILD_DIR}/staging/"

PKG_DIR="${BUILD_DIR}/pkg"
rm -rf "${PKG_DIR}"
mkdir -p "${PKG_DIR}${PREFIX}"
cp -a "${BUILD_DIR}/staging${PREFIX}/." "${PKG_DIR}${PREFIX}/"

mkdir -p "${PKG_DIR}/DEBIAN"
sed -e "s|%VERSION%|${VERSION}|g" packaging/control.template > "${PKG_DIR}/DEBIAN/control"
if [ -f packaging/postinst ]; then
  install -m 0755 packaging/postinst "${PKG_DIR}/DEBIAN/postinst"
fi
if [ -f packaging/prerm ]; then
  install -m 0755 packaging/prerm "${PKG_DIR}/DEBIAN/prerm"
fi
chmod -R 0755 "${PKG_DIR}/DEBIAN"

OUTPUT_FILE="${OUT_DIR}/kodi-${VERSION}_amd64.deb"
dpkg-deb --build "${PKG_DIR}" "${OUTPUT_FILE}"
echo "Package created: ${OUTPUT_FILE}"

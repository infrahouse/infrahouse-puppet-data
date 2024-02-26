#!/usr/bin/env bash

set -eux


function generate_changelog() {
  current_version=$(grep current_version setup.cfg | awk '{ print $3}')
  cat > debian/changelog << EOF
infrahouse-puppet-data (${current_version}-1build$(date +%s)) jammy; urgency=medium

  * commit event. see changes history in git log

 -- Oleksandr Kuzminskyi <aleks@infrahouse.com>  $(date)

EOF
}

pkg_name="infrahouse-puppet-data"
generate_changelog
upstream_version=$(head -1 debian/changelog | awk '{ print $2 }' | sed -e 's/[()]//g' | awk -F- '{ print $1 }')
TMPDIR=$(mktemp -d)

DEBEMAIL=${DEBEMAIL-packager@infrahouse.com}
DEBFULLNAME=${DEBFULLNAME-InfraHouse Packager}

cleanup () {
  rm -rf "${TMPDIR}"
}

trap cleanup ERR
trap cleanup EXIT

mkdir "${TMPDIR}/${pkg_name}_${upstream_version}"
cp -R environments LICENSE README.md "${TMPDIR}/${pkg_name}_${upstream_version}"

tar zcf "../${pkg_name}_${upstream_version}.orig.tar.gz" -C "${TMPDIR}" "${pkg_name}_${upstream_version}"
debuild --build=all -us -uc

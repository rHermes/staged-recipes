#!/bin/bash
set -ex

# Cf. https://github.com/conda-forge/staged-recipes/issues/673, we're in the
# process of excising Libtool files from our packages. Existing ones can break
# the build while this happens. We have "/." at the end of ${PREFIX} to be safe
# in case the variable is empty.
find ${PREFIX}/. -name '*.la' -delete

echo libtoolize
libtoolize
echo aclocal -I ${PREFIX}/share/aclocal -I ${BUILD_PREFIX}/share/aclocal
aclocal -I ${PREFIX}/share/aclocal -I ${BUILD_PREFIX}/share/aclocal
echo autoconf
autoconf
echo automake --force-missing --add-missing --include-deps
automake --force-missing --add-missing --include-deps

export CONFIG_FLAGS="--build=${BUILD}"

export PKG_CONFIG_LIBDIR=${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig
configure_args=(
    ${CONFIG_FLAGS}
    --disable-debug
    --disable-dependency-tracking
    --prefix=${PREFIX}
)

./configure "${configure_args[@]}"
make -j${CPU_COUNT}
make install

rm -rf ${PREFIX}/share/man ${PREFIX}/share/doc/wmctrl

# Remove any new Libtool files we may have installed. It is intended that
# conda-build will eventually do this automatically.
find ${PREFIX}/. -name '*.la' -delete

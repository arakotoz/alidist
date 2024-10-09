package: abseil
version: "%(tag_basename)s"
tag: "20240722.0"
requires:
  - "GCC-Toolchain:(?!osx)"
build_requires:
  - CMake
  - alibuild-recipe-tools
source: https://github.com/abseil/abseil-cpp
incremental_recipe: |
  cmake --build . -- ${JOBS:+-j$JOBS} install
  mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles
---
#!/bin/bash -e

mkdir -p $INSTALLROOT
cmake $SOURCEDIR                             \
  ${CXXSTD:+-DCMAKE_CXX_STANDARD=$CXXSTD}    \
  -DBUILD_TESTING=OFF                        \
  -DABSL_ENABLE_INSTALL=ON                   \
  -DCMAKE_INSTALL_PREFIX=$INSTALLROOT

cmake --build . -- ${JOBS:+-j$JOBS} install


# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --lib --bin --cmake > "$MODULEFILE"
cat >> "$MODULEFILE" <<EoF
prepend-path LD_LIBRARY_PATH \$PKG_ROOT/lib64
EoF

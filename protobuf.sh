package: protobuf
version: v24.4
source: https://github.com/protocolbuffers/protobuf
build_requires:
  - CMake
  - "GCC-Toolchain:(?!osx)"
  - abseil
---
#!/bin/bash -e

cmake $SOURCEDIR                        \
    -G Ninja                            \
    -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
    -Dprotobuf_BUILD_TESTS=OFF          \
    -Dprotobuf_MODULE_COMPATIBLE=ON    \
    -Dprotobuf_BUILD_SHARED_LIBS=ON    \
    -DCMAKE_INSTALL_LIBDIR=lib           \
    -Dprotobuf_ABSL_PROVIDER=package    \
    ${ABSEIL_ROOT:+-DCMAKE_PREFIX_PATH=$ABSEIL_ROOT} 
    
cmake --build . -- ${JOBS+-j $JOBS} install
#make ${JOBS:+-j $JOBS}
#make install

#ModuleFile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
cat > "$MODULEFILE" <<EoF
#%Module1.0
proc ModulesHelp { } {
  global version
  puts stderr "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
}
set version $PKGVERSION-@@PKGREVISION@$PKGHASH@@
module-whatis "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
# Dependencies
module load BASE/1.0
# Our environment
set PROTOBUF_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv PROTOBUF_ROOT \$PROTOBUF_ROOT
prepend-path LD_LIBRARY_PATH \$PROTOBUF_ROOT/lib
prepend-path PATH \$PROTOBUF_ROOT/bin
EoF

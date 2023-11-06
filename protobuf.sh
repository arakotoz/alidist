package: protobuf
version: v24.4
source: https://github.com/protocolbuffers/protobuf
build_requires:
  - CMake
  - "GCC-Toolchain:(?!osx)"
  - abseil
  - alibuild-recipe-tools
prepend_path:
  # The protobuf headers must match the protoc binary version, so prevent the
  # use of system headers by putting ours first in the path.
  PKG_CONFIG_PATH: "$PROTOBUF_ROOT/lib/pkgconfig"
---
#!/bin/bash -e

cmake $SOURCEDIR                               \
    -G Ninja                                   \
    ${CXXSTD:+-DCMAKE_CXX_STANDARD=$CXXSTD}    \
    -DCMAKE_INSTALL_PREFIX=$INSTALLROOT        \
    -DBUILD_SHARED_LIBS=ON                     \
    -Dprotobuf_BUILD_LIBPROTOC=ON              \
    -Dprotobuf_BUILD_SHARED_LIBS=ON            \
    -Dprotobuf_BUILD_TESTS=OFF                 \
    -Dprotobuf_MODULE_COMPATIBLE=ON            \
    -DCMAKE_INSTALL_LIBDIR=lib                 \
    -Dprotobuf_ABSL_PROVIDER=package           \
    ${ABSEIL_ROOT:+-DCMAKE_PREFIX_PATH=$ABSEIL_ROOT} 
    
cmake --build . -- ${JOBS+-j $JOBS} install

mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --bin --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"

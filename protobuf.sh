package: protobuf
version: v29.1
source: https://github.com/protocolbuffers/protobuf
requires:
  - abseil
build_requires:
  - CMake
  - "GCC-Toolchain:(?!osx)"
  - alibuild-recipe-tools
  - ninja
prepend_path:
  # The protobuf headers must match the protoc binary version, so prevent the
  # use of system headers by putting ours first in the path.
  PKG_CONFIG_PATH: "$PROTOBUF_ROOT/lib/pkgconfig"
---
#!/bin/bash -e
cmake "$SOURCEDIR"                          \
    -G 'Ninja'                              \
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"   \
    -Dprotobuf_ABSL_PROVIDER=package        \
    -DCMAKE_PREFIX_PATH="$ABSEIL_ROOT"      \
    ${CXXSTD:+-DCMAKE_CXX_STANDARD=$CXXSTD} \
    -Dprotobuf_BUILD_TESTS=NO               \
    -Dprotobuf_MODULE_COMPATIBLE=YES        \
    -Dprotobuf_BUILD_SHARED_LIBS=OFF        \
    -DCMAKE_INSTALL_LIBDIR=lib

cmake --build . -- ${JOBS:+-j$JOBS} install

mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --bin --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"

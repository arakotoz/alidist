package: grpc
version: "%(tag_basename)s"
tag: v1.66.2
requires:
  - protobuf
  - c-ares
  - "OpenSSL:(?!osx)"
  - "GCC-Toolchain:(?!osx)"
  - re2
  - abseil
build_requires:
  - CMake
  - ninja
source: https://github.com/grpc/grpc
incremental_recipe: |
  cmake --build . -- ${JOBS:+-j$JOBS} install
  mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles
---
#!/bin/bash -e
SONAME=so
case $ARCHITECTURE in
  osx*)
    SONAME=dylib
    MACOSX_RPATH=OFF
    [[ ! $OPENSSL_ROOT ]] && OPENSSL_ROOT=$(brew --prefix openssl@3)
    [[ ! $PROTOBUF_ROOT ]] && PROTOBUF_ROOT=$(brew --prefix protobuf)
    [[ ! $CARES_ROOT ]] && CARES_ROOT=$(brew --prefix c-ares)
    # to avoid issues with rpath on mac
    linker_flags="-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-undefined,dynamic_lookup,-rpath,$INSTALLROOT/lib"
    packages_path="$ABSEIL_ROOT;$CARES_ROOT;$PROTOBUF_ROOT"
    extra_cmake_variables="-DCMAKE_INSTALL_RPATH=$INSTALLROOT/lib \
    -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=FALSE \
    -DCMAKE_SKIP_BUILD_RPATH=FALSE \
    -DCMAKE_PREFIX_PATH=${packages_path} \
    ${linker_flags}
    "
  ;;
esac

echo "OPENSSL_ROOT : $OPENSSL_ROOT"
echo "OPENSSL_REVISION: $OPENSSL_REVISION"

cmake $SOURCEDIR                                    \
  -G Ninja 					                                \
  ${CXXSTD:+-DCMAKE_CXX_STANDARD=$CXXSTD}           \
  -DCMAKE_CXX_STANDARD_REQUIRED=TRUE                \
  -DCMAKE_INSTALL_PREFIX=$INSTALLROOT               \
  ${MACOSX_RPATH:+-DMACOSX_RPATH=${MACOSX_RPATH}}   \
  -DgRPC_BUILD_TESTS=OFF                            \
  -DBUILD_SHARED_LIBS=ON                            \
  -DCMAKE_BUILD_TYPE=Release                        \
  -DgRPC_CARES_PROVIDER=package                     \
  -DgRPC_SSL_PROVIDER=package                       \
  -DgRPC_ZLIB_PROVIDER=package                      \
  -DgRPC_PROTOBUF_PROVIDER=package                  \
  -DgRPC_ABSL_PROVIDER=package                      \
  -DgRPC_RE2_PROVIDER=package                       \
  -DgRPC_BUILD_GRPC_CSHARP_PLUGIN=OFF               \
  -DgRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN=OFF          \
  -DgRPC_BUILD_GRPC_PHP_PLUGIN=OFF 		              \
  -DgRPC_BUILD_GRPC_CPP_PLUGIN=ON                   \
  -DgRPC_BUILD_CSHARP_EXT=OFF                       \
  ${OPENSSL_ROOT:+-DOPENSSL_ROOT_DIR=$OPENSSL_ROOT} \
  ${OPENSSL_ROOT:+-DOpenSSL_ROOT="$OPENSSL_ROOT"}   \
  ${OPENSSL_ROOT:+-DOPENSSL_INCLUDE_DIRS=$OPENSSL_ROOT/include} \
  ${OPENSSL_ROOT:+-DOPENSSL_LIBRARIES=$OPENSSL_ROOT/lib/libssl.$SONAME;$OPENSSL_ROOT/lib/libcrypto.$SONAME} \
  $extra_cmake_variables

cmake --build . -- ${JOBS:+-j$JOBS} install

case $ARCHITECTURE in
  osx*)
    # Add correct rpath to dylibs on Mac as long as there is no better way to
    # control rpath in the GRPC CMake
    # Add rpath to all libraries in lib and change their IDs to be absolute paths.
    find "$INSTALLROOT/lib" -name '*.dylib' -not -name '*ios*.dylib' \
         -exec install_name_tool -id '{}' '{}' \;
  ;;
esac


#ModuleFile
mkdir -p etc/modulefiles
alibuild-generate-module --bin --lib > etc/modulefiles/$PKGNAME
mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles

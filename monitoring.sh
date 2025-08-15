package: Monitoring
version: "%(tag_basename)s"
tag: v3.19.8
source: https://github.com/arakotoz/Monitoring
requires:
  - boost
  - "GCC-Toolchain:(?!osx)"
  - curl
  - libInfoLogger
  - grpc
build_requires:
  - CMake
  - alibuild-recipe-tools
  - abseil
  - protobuf
prepend_path:
  PKG_CONFIG_PATH: "${PROTOBUF_ROOT}/lib/config"
incremental_recipe: |
  cmake --build . -- ${JOBS+-j $JOBS} install
  mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles
---
#!/bin/bash -ex

case $ARCHITECTURE in
  osx*)
    [[ ! $BOOST_ROOT ]] && BOOST_ROOT=$(brew --prefix boost)
    [[ -z $PROTOBUF_ROOT ]] && PROTOBUF_ROOT=$(brew --prefix protobuf)
    ;;
esac

if [[ $ALIBUILD_O2_TESTS ]]; then
  CXXFLAGS="${CXXFLAGS} -Werror -Wno-error=deprecated-declarations"
fi

cmake $SOURCEDIR \
  -G Ninja \
  ${PROTOBUF_ROOT:+-DProtobuf_ROOT=$PROTOBUF_ROOT} \
  ${LIBRDKAFKA_REVISION:+-DRDKAFKA_ROOT="${LIBRDKAFKA_ROOT}"} \
  ${GRPC_REVISION:+-DGRPC_ROOT="${GRPC_ROOT}"} \
  -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
  ${BOOST_REVISION:+-DBOOST_ROOT=$BOOST_ROOT} \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
  -DCMAKE_PREFIX_PATH="$ABSEIL_ROOT;$PROTOBUF_ROOT;$GRPC_ROOT;"

cp ${BUILDDIR}/compile_commands.json ${INSTALLROOT}

ninja ${JOBS:+-j$JOBS} install

if [[ $ALIBUILD_O2_TESTS ]]; then
  ctest --output-on-failure
fi

#ModuleFile
mkdir -p etc/modulefiles
alibuild-generate-module --bin --lib >etc/modulefiles/$PKGNAME
cat >>etc/modulefiles/$PKGNAME <<EoF
# Our environment
set MONITORING_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path ROOT_INCLUDE_PATH \$PKG_ROOT/include
EoF
mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $ISTALLROOT/etc/modulefiles

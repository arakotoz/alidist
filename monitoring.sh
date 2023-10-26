package: Monitoring
version: "%(tag_basename)s"
tag: v3.17.5
requires:
  - boost
  - protobuf
  - "GCC-Toolchain:(?!osx)"
  - curl
  - libInfoLogger
build_requires:
  - CMake
  - alibuild-recipe-tools
  - abseil
source: https://github.com/AliceO2Group/Monitoring
incremental_recipe: |
  make ${JOBS:+-j$JOBS} install
  mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles
---
#!/bin/bash -ex

case $ARCHITECTURE in
    osx*) [[ ! $BOOST_ROOT ]] && BOOST_ROOT=$(brew --prefix boost);;
esac

if [[ $ALIBUILD_O2_TESTS ]]; then
  CXXFLAGS="${CXXFLAGS} -Werror -Wno-error=deprecated-declarations"
fi

cmake $SOURCEDIR                                           \
      -G Ninja                                             \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT                  \
      ${BOOST_REVISION:+-DBOOST_ROOT=$BOOST_ROOT}          \
      -DCMAKE_EXPORT_COMPILE_COMMANDS=ON                   \
      -DProtobuf_USE_STATIC_LIBS=OFF \
      ${PROTOBUF_ROOT:+-DProtobuf_LIBRARY=$PROTOBUF_ROOT/lib/libprotobuf.dylib} \
      ${PROTOBUF_ROOT:+-DProtobuf_LITE_LIBRARY=$PROTOBUF_ROOT/lib/libprotobuf-lite.dylib} \
      ${PROTOBUF_ROOT:+-DProtobuf_PROTOC_LIBRARY=$PROTOBUF_ROOT/lib/libprotoc.dylib} \
      ${PROTOBUF_ROOT:+-DProtobuf_INCLUDE_DIR=$PROTOBUF_ROOT/include} \
      ${PROTOBUF_ROOT:+-DProtobuf_PROTOC_EXECUTABLE=$PROTOBUF_ROOT/bin/protoc} \
      ${ABSEIL_ROOT:+-DCMAKE_PREFIX_PATH=${ABSEIL_ROOT}/include}

cp ${BUILDDIR}/compile_commands.json ${INSTALLROOT}

cmake --build . -- ${JOBS+-j $JOBS} install

#make ${JOBS+-j $JOBS} install

if [[ $ALIBUILD_O2_TESTS ]]; then
  ctest --output-on-failure
fi


#ModuleFile
mkdir -p etc/modulefiles
alibuild-generate-module --bin --lib > etc/modulefiles/$PKGNAME
cat >> etc/modulefiles/$PKGNAME <<EoF
# Our environment
set MONITORING_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path ROOT_INCLUDE_PATH \$PKG_ROOT/include
EoF
mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles

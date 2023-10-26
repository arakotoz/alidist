package: ONNXRuntime
version: "%(tag_basename)s"
tag: v1.16.1
source: https://github.com/microsoft/onnxruntime.git
requires:
  - abseil
  - protobuf
  - re2
  - flatbuffers
  - boost
build_requires:
  - CMake
  - alibuild-recipe-tools
  - "Python:(slc|ubuntu)"  # this package builds ONNX, which requires Python
  - "Python-system:(?!slc.*|ubuntu)"
---
#!/bin/bash -e

pushd $SOURCEDIR
  git submodule update --init -- cmake/external/onnx
  git submodule update --init -- cmake/external/emsdk
  git submodule update --init -- cmake/external/libprotobuf-mutator
popd

mkdir -p $INSTALLROOT

cmake "$SOURCEDIR/cmake" \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
      -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DPYTHON_EXECUTABLE=$(python3 -c "import sys; print(sys.executable)") \
      -Donnxruntime_BUILD_UNIT_TESTS=OFF \
      -Donnxruntime_PREFER_SYSTEM_LIB=ON \
      -Donnxruntime_BUILD_SHARED_LIB=ON \
      -DProtobuf_USE_STATIC_LIBS=OFF \
      ${PROTOBUF_ROOT:+-DProtobuf_LIBRARY=$PROTOBUF_ROOT/lib/libprotobuf.dylib} \
      ${PROTOBUF_ROOT:+-DProtobuf_LITE_LIBRARY=$PROTOBUF_ROOT/lib/libprotobuf-lite.dylib} \
      ${PROTOBUF_ROOT:+-DProtobuf_PROTOC_LIBRARY=$PROTOBUF_ROOT/lib/libprotoc.dylib} \
      ${PROTOBUF_ROOT:+-DProtobuf_INCLUDE_DIR=$PROTOBUF_ROOT/include} \
      ${PROTOBUF_ROOT:+-DProtobuf_PROTOC_EXECUTABLE=$PROTOBUF_ROOT/bin/protoc} \
      ${RE2_ROOT:+-DRE2_INCLUDE_DIR=${RE2_ROOT}/include} \
      ${FLATBUFFERS_ROOT:+-DFLATBUFFERS_INCLUDE_DIR=${FLATBUFFERS_ROOT}/include} \
      ${BOOST_ROOT:+-DBOOST_INCLUDE_DIR=${BOOST_ROOT}/include} \
      ${ABSEIL_ROOT:+-DCMAKE_PREFIX_PATH=${ABSEIL_ROOT}/include} 

cmake --build . -- ${JOBS:+-j$JOBS} install

# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
MODULEFILE="$INSTALLROOT/etc/modulefiles/$PKGNAME"
alibuild-generate-module --lib > "$MODULEFILE"
cat >> "$MODULEFILE" <<EoF

# Our environment
set ${PKGNAME}_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path ROOT_INCLUDE_PATH \$${PKGNAME}_ROOT/include
EoF

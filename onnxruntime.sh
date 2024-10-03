package: ONNXRuntime
version: "%(tag_basename)s"
tag: v1.19.2
source: https://github.com/microsoft/onnxruntime
requires:
  - protobuf
  - re2
  - flatbuffers
  - boost
  - abseil
build_requires:
  - CMake
  - alibuild-recipe-tools
  - "Python:(slc|ubuntu)"  # this package builds ONNX, which requires Python
  - "Python-system:(?!slc.*|ubuntu)"
prepend_path:
  ROOT_INCLUDE_PATH: "$ONNXRUNTIME_ROOT/include/onnxruntime"
---
#!/bin/bash -e

mkdir -p $INSTALLROOT

case $ARCHITECTURE in
  osx*)
    # If we preferred system tools, we need to make sure we can pick them up.
    [[ -z $BOOST_ROOT ]] && BOOST_ROOT=$(brew --prefix boost)
    [[ -z $PROTOBUF_ROOT ]] && PROTOBUF_ROOT=$(brew --prefix protobuf)
#    [[ -z $PROTOBUF_ROOT ]] && PROTOBUF_ROOT=$(dirname "$(dirname "$(which protoc)")")
    [[ ! -d $BOOST_ROOT ]] && unset BOOST_ROOT
    [[ ! -d $PROTOBUF_ROOT ]] && unset PROTOBUF_ROOT
    SONAME=dylib
    MACOSX_RPATH=OFF
  ;;
  *) SONAME=so ;;
esac

cmake "$SOURCEDIR/cmake"                                                              \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT                                             \
      -DCMAKE_BUILD_TYPE=Release                                                      \
      -DCMAKE_INSTALL_LIBDIR=lib                                                      \
      -DPYTHON_EXECUTABLE=$(python3 -c "import sys; print(sys.executable)")           \
      ${MACOSX_RPATH:+-DMACOSX_RPATH=${MACOSX_RPATH}}                                 \
      -DONNX_USE_PROTOBUF_SHARED_LIBS=ON                                              \
      -Donnxruntime_BUILD_SHARED_LIB=ON                                               \
      -Donnxruntime_BUILD_UNIT_TESTS=OFF                                              \
      -DONNX_BUILD_SHARED_LIBS=ON                                                     \
      ${PROTOBUF_ROOT:+-DProtobuf_LIBRARY="$PROTOBUF_ROOT/lib/libprotobuf.$SONAME"}                 \
      ${PROTOBUF_ROOT:+-DProtobuf_LITE_LIBRARY="$PROTOBUF_ROOT/lib/libprotobuf-lite.$SONAME"}       \
      ${PROTOBUF_ROOT:+-DProtobuf_PROTOC_LIBRARY="$PROTOBUF_ROOT/lib/libprotoc.$SONAME"}            \
      ${PROTOBUF_ROOT:+-DProtobuf_INCLUDE_DIR="$PROTOBUF_ROOT/include"}                             \
      ${PROTOBUF_ROOT:+-DProtobuf_PROTOC_EXECUTABLE="$PROTOBUF_ROOT/bin/protoc"}                    \
      ${RE2_ROOT:+-DRE2_ROOT="$RE2_ROOT"}                                                           \
      ${FLATBUFFERS_ROOT:+-DFLATBUFFERS_INCLUDE_DIR=${FLATBUFFERS_ROOT}/include}                    \
      ${BOOST_ROOT:+-DBOOST_INCLUDE_DIR=${BOOST_ROOT}/include}                                      \
      -DCMAKE_CXX_FLAGS="$CXXFLAGS -Wno-unknown-warning -Wno-unknown-warning-option -Wno-error=unused-but-set-variable -Wno-error=deprecated" \
      -DCMAKE_C_FLAGS="$CFLAGS -Wno-unknown-warning -Wno-unknown-warning-option -Wno-error=unused-but-set-variable -Wno-error=deprecated"

cmake --build . -- ${JOBS:+-j$JOBS} install

# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
MODULEFILE="$INSTALLROOT/etc/modulefiles/$PKGNAME"
alibuild-generate-module --lib > "$MODULEFILE"
cat >> "$MODULEFILE" <<EoF

# Our environment
set ${PKGNAME}_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path ROOT_INCLUDE_PATH \$${PKGNAME}_ROOT/include/onnxruntime
EoF

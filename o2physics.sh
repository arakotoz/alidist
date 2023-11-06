package: O2Physics
version: "%(tag_basename)s"
tag: "daily-20231105-0100"
requires:
  - O2
  - ONNXRuntime
  - KFParticle
  - fastjet
  - libjalienO2
  - DDS
build_requires:
  - "Clang:(?!osx)"
  - CMake
  - ninja
  - alibuild-recipe-tools
source: https://github.com/AliceO2Group/O2Physics
incremental_recipe: |
  [[ $ALIBUILD_O2PHYSICS_TESTS ]] && CXXFLAGS="${CXXFLAGS} -Werror -Wno-error=deprecated-declarations"
  cmake --build . -- ${JOBS:+-j$JOBS} install
  mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles
---
#!/bin/sh

if [[ $ALIBUILD_O2PHYSICS_TESTS ]]; then
  # Impose extra errors.
  CXXFLAGS="${CXXFLAGS} -Werror -Wno-error=deprecated-declarations"
fi

case $ARCHITECTURE in
  osx*)
    export PKG_CONFIG_PATH=${ONNXRUNTIME_ROOT}/lib/pkgconfig
  ;;
esac

# When O2 is built against Gandiva (from Arrow), then we need to use
# -DLLVM_ROOT=$CLANG_ROOT, since O2's CMake calls into Gandiva's
# -CMake, which requires it.
cmake "$SOURCEDIR" "-DCMAKE_INSTALL_PREFIX=$INSTALLROOT"          \
      -G Ninja                                                    \
      ${CMAKE_BUILD_TYPE:+"-DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE"} \
      ${CXXSTD:+"-DCMAKE_CXX_STANDARD=$CXXSTD"}                   \
      -DCMAKE_EXPORT_COMPILE_COMMANDS=ON                          \
      ${CLANG_ROOT:+-DLLVM_ROOT="$CLANG_ROOT"}                    \
      ${ONNXRUNTIME_ROOT:+-DONNXRuntime_DIR=$ONNXRUNTIME_ROOT}    \
      ${FASTJET_ROOT:+-Dfjcontrib_ROOT="$FASTJET_ROOT"}           \
      ${LIBJALIENO2_ROOT:+-DlibjalienO2_ROOT=$LIBJALIENO2_ROOT}   \
      ${LIBUV_ROOT:+-DLibUV_ROOT=$LIBUV_ROOT}                     \
      ${DDS_ROOT:+-DDDS_ROOT=$DDS_ROOT}                           \
      ${KFPARTICLE_ROOT:+-DKFPARTICLE_ROOT=$KFPARTICLE_ROOT}      \
      ${XROOTD_REVISION:+-DXROOTD_DIR=$XROOTD_ROOT}                                                       \
      ${JALIEN_ROOT_REVISION:+-DJALIEN_ROOT_ROOT=$JALIEN_ROOT_ROOT}                                       \
      ${CURL_ROOT:+-DCURL_ROOT=$CURL_ROOT}                                                                \
      ${LIBUV_ROOT:+-DLibUV_ROOT=$LIBUV_ROOT}                                                             \
      ${ARROW_ROOT:+-DGandiva_DIR=$ARROW_ROOT/lib/cmake/Gandiva}                                          \
      ${ARROW_ROOT:+-DArrow_DIR=$ARROW_ROOT/lib/cmake/Arrow}                                              \
      ${ARROW_ROOT:+${CLANG_ROOT:+-DLLVM_ROOT=$CLANG_ROOT}}                                               \
      -DCMAKE_PREFIX_PATH="$JALIEN_ROOT_ROOT;$ONNXRUNTIME_ROOT;$XROOTD_ROOT;$DDS_ROOT;$LIBJALIENO2_ROOT;$CLANG_ROOT;$KFPARTICLE_ROOT;$PYTHIA_ROOT;"
cmake --build . -- ${JOBS+-j $JOBS} install

# export compile_commands.json in (taken from o2.sh)
DEVEL_SOURCES="`readlink $SOURCEDIR || echo $SOURCEDIR`"
if [ "$DEVEL_SOURCES" != "$SOURCEDIR" ]; then
  perl -p -i -e "s|$SOURCEDIR|$DEVEL_SOURCES|" compile_commands.json
  ln -sf $BUILDDIR/compile_commands.json $DEVEL_SOURCES/compile_commands.json
fi

# Modulefile
mkdir -p etc/modulefiles
MODULEFILE="etc/modulefiles/$PKGNAME"
alibuild-generate-module --bin --lib > "$MODULEFILE"
cat >> "$MODULEFILE" <<EoF
# Our environment
set O2PHYSICS_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv O2PHYSICS_ROOT \$O2PHYSICS_ROOT
prepend-path ROOT_INCLUDE_PATH \$O2PHYSICS_ROOT/include
EoF
mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles

package: O2Physics
version: "%(tag_basename)s"
tag: "daily-20241009-0200"
requires:
  - O2
  - ONNXRuntime
  - fastjet
  - libjalienO2
  - KFParticle
build_requires:
  - "Clang:(?!osx)"
  - CMake
  - alibuild-recipe-tools
source: https://github.com/AliceO2Group/O2Physics
incremental_recipe: |
  unset DYLD_LIBRARY_PATH
  if [[ ! $CMAKE_GENERATOR && $DISABLE_NINJA != 1 && $DEVEL_SOURCES != $SOURCEDIR ]]; then
    NINJA_BIN=ninja-build
    type "$NINJA_BIN" &> /dev/null || NINJA_BIN=ninja
    type "$NINJA_BIN" &> /dev/null || NINJA_BIN=
    [[ $NINJA_BIN ]] && CMAKE_GENERATOR=Ninja || true
    unset NINJA_BIN
  fi
  if [ "X$CMAKE_GENERATOR" = XNinja ]; then
    # Find the old binary byproducts
    mkdir -p stage/{bin,lib,tests}
    find stage/{bin,lib,tests} -type f > old.txt
    # Find new targets
    ninja -t targets all  | grep stage | cut -f1 -d: > new.txt
    # Delete all those which are found twice (i.e. which are in old.txt only)
    # FIXME: this breaks some corner cases, apparently...
    # cat old.txt old.txt new.txt | sort | uniq -c | grep " 2 " | sed -e's|[ ][ ]*2 ||' | xargs rm -f
  fi
  cmake --build . -- ${JOBS:+-j$JOBS} install
  mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles
---
#!/bin/sh

# Use ninja if in devel mode, ninja is found and DISABLE_NINJA is not 1
if [[ ! $CMAKE_GENERATOR && $DISABLE_NINJA != 1 && $DEVEL_SOURCES != $SOURCEDIR ]]; then
  NINJA_BIN=ninja-build
  type "$NINJA_BIN" &> /dev/null || NINJA_BIN=ninja
  type "$NINJA_BIN" &> /dev/null || NINJA_BIN=
  [[ $NINJA_BIN ]] && CMAKE_GENERATOR=Ninja || true
  unset NINJA_BIN
fi

unset DYLD_LIBRARY_PATH
# When O2 is built against Gandiva (from Arrow), then we need to use
# -DLLVM_ROOT=$CLANG_ROOT, since O2's CMake calls into Gandiva's
# -CMake, which requires it.
cmake $SOURCEDIR -DCMAKE_INSTALL_PREFIX=$INSTALLROOT                        \
      ${CMAKE_GENERATOR:+-G "$CMAKE_GENERATOR"}                             \
      ${CMAKE_BUILD_TYPE:+-DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE}             \
      ${CXXSTD:+-DCMAKE_CXX_STANDARD=$CXXSTD}                               \
      -DCMAKE_EXPORT_COMPILE_COMMANDS=ON                                    \
      ${CLANG_ROOT:+-DLLVM_ROOT="$CLANG_ROOT"}                              \
      ${ONNXRUNTIME_ROOT:+-DONNXRuntime_DIR=$ONNXRUNTIME_ROOT}              \
      ${FASTJET_ROOT:+-Dfjcontrib_ROOT="$FASTJET_ROOT"}                     \
      ${LIBJALIENO2_ROOT:+-DlibjalienO2_ROOT=$LIBJALIENO2_ROOT}             \
      ${CLANG_REVISION:+-DCLANG_EXECUTABLE="$CLANG_ROOT/bin-safe/clang"}    \
      ${CLANG_REVISION:+-DLLVM_LINK_EXECUTABLE="$CLANG_ROOT/bin/llvm-link"} \
      ${LIBUV_ROOT:+-DLibUV_ROOT=$LIBUV_ROOT}                               \
      ${ALIBUILD_O2PHYSICS_TESTS:+-DO2PHYSICS_WARNINGS_AS_ERRORS=OFF}
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

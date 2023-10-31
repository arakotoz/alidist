package: Monitoring
version: "%(tag_basename)s"
tag: v3.17.26
requires:
  - boost
  - abseil
  - protobuf
  - "GCC-Toolchain:(?!osx)"
  - curl
  - libInfoLogger
build_requires:
  - alibuild-recipe-tools
  - CMake
source: https://github.com/arakotoz/Monitoring
incremental_recipe: |
  cmake --build . -- ${JOBS+-j $JOBS} install
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
      -DCMAKE_PREFIX_PATH="$BOOST_ROOT;$ABSEIL_ROOT;$PROTOBUF_ROOT"

cp ${BUILDDIR}/compile_commands.json ${INSTALLROOT}

cmake --build . -- ${JOBS+-j $JOBS} install

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

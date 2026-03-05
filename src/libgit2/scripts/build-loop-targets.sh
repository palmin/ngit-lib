#!/bin/sh

#  Automatic build script for libssl and libcrypto
#  for iPhoneOS, iPhoneSimulator and macCatalyst

OPTFLAG=-O2

for TARGET in ${TARGETS}
do
  # Determine relevant SDK version
  if [[ "${TARGET}" == tvos* ]]; then
    SDKVERSION="${TVOS_SDKVERSION}"
  elif [[ "${TARGET}" == "mac-"* ]]; then
    SDKVERSION="${MACOSX_SDKVERSION}"
  else
    SDKVERSION="${IOS_SDKVERSION}"
  fi

  # These variables are used in the configuration file
  export SDKVERSION
  export IOS_MIN_SDK_VERSION
  export TVOS_MIN_SDK_VERSION
  export CONFIG_DISABLE_BITCODE

  # Determine platform
  if [[ "${TARGET}" == "ios-sim-cross-"* ]]; then
    PLATFORM="iPhoneSimulator"
  elif [[ "${TARGET}" == "tvos-sim-cross-"* ]]; then
    PLATFORM="AppleTVSimulator"
  elif [[ "${TARGET}" == "tvos64-cross-"* ]]; then
    PLATFORM="AppleTVOS"
  elif [[ "${TARGET}" == "mac-"* ]]; then
    PLATFORM="MacOSX"
    if [[ "${TARGET}" == "mac-catalyst-"* ]]; then
      PLATFORM_VARIANT="Catalyst"
    else
      PLATFORM_VARIANT="Mac"
    fi
  else
    PLATFORM="iPhoneOS"
  fi

  # Extract ARCH from TARGET (part after last dash)
  ARCH=$(echo "${TARGET}" | sed -E 's|^.*\-([^\-]+)$|\1|g')

  if [[ "$ARCH" == arm64* ]]; then
    HOST="aarch64-apple-darwin"
  else
    HOST="$ARCH-apple-darwin"
  fi 

  # Cross compile references, see Configurations/10-main.conf
  export CROSS_COMPILE="${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/"
  export CROSS_TOP="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
  export CROSS_SDK="${PLATFORM}${SDKVERSION}.sdk"
  export SDKROOT="${CROSS_TOP}/SDKs/${CROSS_SDK}"

  # Prepare TARGETDIR and SOURCEDIR
  prepare_target_source_dirs

  ## Determine config options
  # Add build target, --prefix and prevent async (references to getcontext(),
  # setcontext() and makecontext() result in App Store rejections) and creation
  # of shared libraruuuies (default since 1.1.0)
  if [[ "${PLATFORM}" == "MacOSX" ]]; then
    if [[ "${PLATFORM_VARIANT}" == "Catalyst" ]]; then
      export CFLAGS="-arch $ARCH $OPTFLAG -pipe -no-cpp-precomp -fPIE -isysroot $SDKROOT --target=$ARCH-apple-ios-macabi -fembed-bitcode -DCMAKE_COCOA -DGIT_COCOA"
      export CPPFLAGS="-arch $ARCH $OPTFLAG -pipe -no-cpp-precomp -fPIE -isysroot $SDKROOT --target=$ARCH-apple-ios-macabi -fembed-bitcode"
    else
      export CFLAGS="-arch $ARCH $OPTFLAG -pipe -no-cpp-precomp -fPIE -isysroot $SDKROOT -fembed-bitcode -DCMAKE_COCOA -DGIT_COCOA"
      export CPPFLAGS="-arch $ARCH $OPTFLAG -pipe -no-cpp-precomp -fPIE -isysroot $SDKROOT -fembed-bitcode"
    fi
  else
    export CFLAGS="-arch $ARCH $OPTFLAG -pipe -no-cpp-precomp -fPIE -isysroot $SDKROOT -mios-version-min=${IOS_MIN_SDK_VERSION} -fembed-bitcode -DCMAKE_COCOA -DGIT_COCOA"
    export CPPFLAGS="-arch $ARCH $OPTFLAG -pipe -no-cpp-precomp -fPIE -isysroot $SDKROOT -mios-version-min=${IOS_MIN_SDK_VERSION} -fembed-bitcode"
  fi
  export LOCAL_CONFIG_OPTIONS=""
  if [[ "${ARCH}" != "x86_64" ]]
  then
    LOCAL_CONFIG_OPTIONS="-DCMAKE_OSX_SYSROOT=${SDKROOT}"
  fi
  if [[ "${PLATFORM}" == "iPhoneSimulator" ]]; then
    export CFLAGS="$CFLAGS --target=$ARCH-apple-ios-simulator"
  fi
  export PKG_CONFIG_PATH="{$TARGETDIR}/lib/pkgconfig/"
  #export LOCAL_CONFIG_OPTIONS="-DLIB_INSTALL_DIR:STRING="${TARGETDIR}/lib" -DINCLUDE_INSTALL_DIR:STRING="${TARGETDIR}/include" -DUSE_ICONV:BOOL=OFF -DOPENSSL_ROOT_DIR=${OPENSSLDIR} -DOPENSSL_INCLUDE_DIR=${OPENSSLDIR}/include -DOPENSSL_SSL_LIBRARY=${OPENSSLDIR}/lib/libssl.a -DOPENSSL_CRYPTO_LIBRARY=${OPENSSLDIR}/lib/libcrypto.a -DCMAKE_INSTALL_PREFIX="${TARGETDIR}/" -DCMAKE_C_COMPILER_WORKS:BOOL=ON -DBUILD_SHARED_LIBS:BOOL=OFF -DUSE_BUNDLED_ZLIB:BOOL=ON -DBUILD_CLAR:BOOL=OFF -DHAVE_FUTIMENS:BOOL=OFF -DUSE_HTTPS=OpenSSL -DLIBSSH2_FOUND=TRUE -DLIBSSH2_INCLUDE_DIRS="${TARGETDIR}/include" -DLIBSSH2_LIBRARY_DIRS="${TARGETDIR}/lib" -DHAVE_LIBSSH2_MEMORY_CREDENTIALS:BOOL=ON -DPKG_CONFIG_USE_CMAKE_PREFIX_PATH:BOOL=ON -DTHREADSAFE:BOOL=ON -DCMAKE_OSX_ARCHITECTURES:STRING="${ARCH}" $LOCAL_CONFIG_OPTIONS"
  export LOCAL_CONFIG_OPTIONS="-DCMAKE_BUILD_TYPE=RelWithDebInfo -DOPENSSL_ROOT_DIR=${OPENSSLDIR} -DOPENSSL_INCLUDE_DIR=${OPENSSLDIR}/include -DOPENSSL_SSL_LIBRARY=${OPENSSLDIR}/lib/libssl.a -DOPENSSL_CRYPTO_LIBRARY=${OPENSSLDIR}/lib/libcrypto.a -DCMAKE_INSTALL_PREFIX="${TARGETDIR}/" -DCMAKE_C_COMPILER_WORKS:BOOL=ON -DBUILD_SHARED_LIBS:BOOL=OFF -DBUILD_TESTS:BOOL=OFF -DBUILD_CLI:BOOL=OFF -DHAVE_FUTIMENS:BOOL=OFF -DUSE_HTTPS=OpenSSL -DUSE_GSSAPI=OFF -DICONV_INCLUDE_DIR="${TARGETDIR}/include" -DICONV_LIBRARIES="iconv"
-DUSE_SSH="libssh2" -DUSE_BUNDLED_ZLIB:BOOL=ON -DGIT_SSH_LIBSSH2_MEMORY_CREDENTIALS:BOOL=ON -DCMAKE_PREFIX_PATH:PATH=${TARGETDIR} -DPKG_CONFIG_USE_CMAKE_PREFIX_PATH:BOOL=ON -DTHREADSAFE:BOOL=ON -DREGEX_BACKEND=builtin -DCMAKE_OSX_DEPLOYMENT_TARGET=${IOS_MIN_SDK_VERSION} -DCMAKE_OSX_ARCHITECTURES:STRING=${ARCH} $LOCAL_CONFIG_OPTIONS"

  # Run Configure
  run_configure

  # Run make
  run_make

  # Remove source dir, add references to library files to relevant arrays
  # Keep reference to first build target for include file
  finish_build_loop
done

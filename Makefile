#
#  Makefile
#  libgit2 for Apple stuff
#
#

DEFAULTTARGETS="ios64-cross mac-catalyst-x86_64"
DEFAULTFWTARGETS="iOS-arm64 macOS-x86_64 simulator-x86_64 simulator-arm64"
OPENSSLVER="1.1.1q"
LIBSSHVER="1.10.0"

CUR_DIR = $(CURDIR)
TARGETDIR := target

#LIBSSH2_ENV := CONFIG_OPTIONS=--enable-debug
LIBSSH2_ENV := CONFIG_OPTIONS=--disable-debug
BUILD_LIBSSH := $(LIBSSH2_ENV) $(realpath $(CUR_DIR)/src/libssh2/build-libssh.sh) --disable-bitcode 

BUILD_OPENSSL := $(realpath $(CUR_DIR)/src/openssl/build-libssl.sh) --disable-bitcode 
BUILD_LIBGIT := $(realpath $(CUR_DIR)/src/libgit2/build-libgit.sh) --disable-bitcode 

STATIC_IOS := $(TARGETDIR)/iOS-arm64/libgit2static.a
STATIC_MACOS := $(TARGETDIR)/mac-x86_64/libgit2static.a
STATIC_MACOS_ARM64 := $(TARGETDIR)/mac-arm64/libgit2static.a
STATIC_MACOS_CATALYST := $(TARGETDIR)/mac-catalyst-x86_64/libgit2static.a
STATIC_MACOS_CATALYST_ARM64 := $(TARGETDIR)/mac-catalyst-arm64/libgit2static.a
STATIC_SIM := $(TARGETDIR)/simulator-x86_64/libgit2static.a
STATIC_SIM_ARM64 := $(TARGETDIR)/simulator-arm64/libgit2static.a

OUTPUT_DIR := framework

default: framework_static

${TARGETDIR}:
	mkdir -p ${TARGETDIR}

build_ios: ${TARGETDIR} ${STATIC_IOS}
${STATIC_IOS}: openssl_ios libssh2_ios libgit2_ios
openssl_ios: 
	cd ./$(TARGETDIR) && \
	$(BUILD_OPENSSL) --targets="ios-cross-arm64" --verbose-on-error --ec-nistp-64-gcc-128 --version=${OPENSSLVER}
libssh2_ios:
	cd ./$(TARGETDIR) && \
	$(BUILD_LIBSSH) --targets="ios-cross-arm64" --verbose-on-error --version=$(LIBSSHVER)
libgit2_ios:
	cd ./$(TARGETDIR) && \
	$(BUILD_LIBGIT) --targets="ios-cross-arm64" --verbose
	mkdir -p $(TARGETDIR)/iOS-arm64
	libtool -static -o $(STATIC_IOS) $(TARGETDIR)/lib/libgit2.a $(TARGETDIR)/lib/libcrypto.a $(TARGETDIR)/lib/libssl.a $(TARGETDIR)/lib/libssh2.a

build_macos: ${TARGETDIR} ${STATIC_MACOS}
${STATIC_MACOS}: openssl_mac libssh2_mac libgit2_mac
openssl_mac:
	cd ./$(TARGETDIR) && \
	$(BUILD_OPENSSL) --targets="mac-x86_64" --verbose-on-error --ec-nistp-64-gcc-128 --version=${OPENSSLVER}
libssh2_mac:
	cd ./$(TARGETDIR) && \
	$(BUILD_LIBSSH) --targets="mac-x86_64" --verbose-on-error --version=$(LIBSSHVER)
libgit2_mac:
	cd ./$(TARGETDIR) && \
	$(BUILD_LIBGIT) --targets="mac-x86_64" --verbose
	mkdir -p $(TARGETDIR)/mac-x86_64
	libtool -static -o $(STATIC_MACOS) $(TARGETDIR)/lib/libgit2.a $(TARGETDIR)/lib/libcrypto.a $(TARGETDIR)/lib/libssl.a $(TARGETDIR)/lib/libssh2.a

build_macos_arm64: ${STATIC_MACOS_ARM64}
${STATIC_MACOS_ARM64}: ${TARGETDIR} openssl_mac_arm64 libssh2_mac_arm64 libgit2_mac_arm64
openssl_mac_arm64:
	cd ./$(TARGETDIR) && \
	$(BUILD_OPENSSL) --targets="mac-arm64" --verbose-on-error --ec-nistp-64-gcc-128 --version=${OPENSSLVER}
libssh2_mac_arm64:
	cd ./$(TARGETDIR) && \
	$(BUILD_LIBSSH) --targets="mac-arm64" --verbose-on-error --version=$(LIBSSHVER)
libgit2_mac_arm64:
	cd ./$(TARGETDIR) && \
	$(BUILD_LIBGIT) --targets="mac-arm64" --verbose
	mkdir -p $(TARGETDIR)/mac-arm64
	libtool -static -o $(STATIC_MACOS_ARM64) $(TARGETDIR)/lib/libgit2.a $(TARGETDIR)/lib/libcrypto.a $(TARGETDIR)/lib/libssl.a $(TARGETDIR)/lib/libssh2.a

build_macos_catalyst_arm64: ${STATIC_MACOS_CATALYST_ARM64}
${STATIC_MACOS_CATALYST_ARM64}: ${TARGETDIR} openssl_mac_catalyst_arm64 libssh2_mac_catalyst_arm64 libgit2_mac_catalyst_arm64
openssl_mac_catalyst_arm64:
	cd ./$(TARGETDIR) && \
	$(BUILD_OPENSSL) --targets="mac-catalyst-arm64" --verbose-on-error --ec-nistp-64-gcc-128 --version=${OPENSSLVER}
libssh2_mac_catalyst_arm64:
	cd ./$(TARGETDIR) && \
	$(BUILD_LIBSSH) --targets="mac-catalyst-arm64" --verbose-on-error --version=$(LIBSSHVER)
libgit2_mac_catalyst_arm64:
	cd ./$(TARGETDIR) && \
	$(BUILD_LIBGIT) --targets="mac-catalyst-arm64" --verbose
	mkdir -p $(TARGETDIR)/mac-catalyst-arm64
	libtool -static -o $(STATIC_MACOS_CATALYST_ARM64) $(TARGETDIR)/lib/libgit2.a $(TARGETDIR)/lib/libcrypto.a $(TARGETDIR)/lib/libssl.a $(TARGETDIR)/lib/libssh2.a

build_macos_catalyst: ${STATIC_MACOS_CATALYST}
${STATIC_MACOS_CATALYST}: ${TARGETDIR} openssl_mac_catalyst libssh2_mac_catalyst libgit2_mac_catalyst
openssl_mac_catalyst:
	cd ./$(TARGETDIR) && \
	$(BUILD_OPENSSL) --targets="mac-catalyst-x86_64" --verbose-on-error --ec-nistp-64-gcc-128 --version=${OPENSSLVER}
libssh2_mac_catalyst:
	cd ./$(TARGETDIR) && \
	$(BUILD_LIBSSH) --targets="mac-catalyst-x86_64" --verbose-on-error --version=$(LIBSSHVER)
libgit2_mac_catalyst:
	cd ./$(TARGETDIR) && \
	$(BUILD_LIBGIT) --targets="mac-catalyst-x86_64" --verbose
	mkdir -p $(TARGETDIR)/mac-catalyst-x86_64
	libtool -static -o $(STATIC_MACOS_CATALYST) $(TARGETDIR)/lib/libgit2.a $(TARGETDIR)/lib/libcrypto.a $(TARGETDIR)/lib/libssl.a $(TARGETDIR)/lib/libssh2.a

build_sim: ${STATIC_SIM}
${STATIC_SIM}: ${TARGETDIR} openssl_sim libssh2_sim libgit2_sim
openssl_sim:
	cd ./$(TARGETDIR) && \
	$(BUILD_OPENSSL) --targets="ios-sim-cross-x86_64" --verbose-on-error --ec-nistp-64-gcc-128 --version=${OPENSSLVER}
libssh2_sim:
	cd ./$(TARGETDIR) && \
	$(BUILD_LIBSSH) --targets="ios-sim-cross-x86_64" --verbose-on-error --version=$(LIBSSHVER)
libgit2_sim:
	cd ./$(TARGETDIR) && \
	$(BUILD_LIBGIT) --targets="ios-sim-cross-x86_64" --verbose
	mkdir -p $(TARGETDIR)/simulator-x86_64
	libtool -static -o $(STATIC_SIM) $(TARGETDIR)/lib/libgit2.a $(TARGETDIR)/lib/libcrypto.a $(TARGETDIR)/lib/libssl.a $(TARGETDIR)/lib/libssh2.a

build_sim_arm64: ${STATIC_SIM_ARM64}
${STATIC_SIM_ARM64}: ${TARGETDIR} openssl_sim_arm64 libssh2_sim_arm64 libgit2_sim_arm64
openssl_sim_arm64:
	cd ./$(TARGETDIR) && \
	$(BUILD_OPENSSL) --targets="ios-sim-cross-arm64" --verbose-on-error --ec-nistp-64-gcc-128 --version=${OPENSSLVER}
libssh2_sim_arm64:
	cd ./$(TARGETDIR) && \
	$(BUILD_LIBSSH) --targets="ios-sim-cross-arm64" --verbose-on-error --version=$(LIBSSHVER)
libgit2_sim_arm64:
	cd ./$(TARGETDIR) && \
	$(BUILD_LIBGIT) --targets="ios-sim-cross-arm64" --verbose
	mkdir -p $(TARGETDIR)/simulator-arm64
	libtool -static -o $(STATIC_SIM_ARM64) $(TARGETDIR)/lib/libgit2.a $(TARGETDIR)/lib/libcrypto.a $(TARGETDIR)/lib/libssl.a $(TARGETDIR)/lib/libssh2.a

framework_static: build_ios build_macos build_macos_arm64 build_macos_catalyst build_macos_catalyst_arm64 build_sim build_sim_arm64 libgit2.xcframework
libgit2.xcframework:
	lipo -create $(STATIC_MACOS) $(STATIC_MACOS_ARM64) -output ${TARGETDIR}/libgit2static_macos.a
	lipo -create $(STATIC_MACOS_CATALYST) $(STATIC_MACOS_CATALYST_ARM64) -output ${TARGETDIR}/libgit2static_catalyst.a
	xcodebuild -create-xcframework \
		-library $(STATIC_IOS) \
		-library ${TARGETDIR}/libgit2static_macos.a \
		-library ${TARGETDIR}/libgit2static_catalyst.a \
		-library ${STATIC_SIM_ARM64} \
		-output libgit2.xcframework

codesign:
	codesign_identity=$(security find-identity -v -p codesigning | grep A33F2F2 | grep -o -E '\w{40}' | head -n 1)
	codesign -f --deep -s 769B34C9C0E7AA7E0B0D60FF33C9F6F565288DBC libgit2.xcframework

clean:
	@echo " Cleaning...";
	@$(RM) -r libgit2.xcframework
	@$(RM) -r $(TARGETDIR)
.PHONY: clean

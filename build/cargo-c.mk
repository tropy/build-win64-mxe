PKG             := cargo-c
$(PKG)_WEBSITE  := https://github.com/lu-zero/cargo-c
$(PKG)_DESCR    := cargo applet to build and install C-ABI compatibile libraries
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 0.10.3
$(PKG)_CHECKSUM := 922171afb3ceaf6553ff3916ae4663d3743ba22f80725f2300a26b76eb6eb94f
$(PKG)_PATCHES  := $(realpath $(sort $(wildcard $(dir $(lastword $(MAKEFILE_LIST)))/patches/$(PKG)-[0-9]*.patch)))
$(PKG)_GH_CONF  := lu-zero/cargo-c/tags,v
$(PKG)_TARGETS  := $(BUILD)
$(PKG)_DEPS_$(BUILD) := $(BUILD)~rust

define $(PKG)_BUILD_$(BUILD)
    # Enable networking while we build cargo-c
    $(eval export MXE_ENABLE_NETWORK := 1)

    # Ensure that the downloaded build dependencies of Cargo are
    # stored in the build directory.
    $(eval export CARGO_HOME := $(BUILD_DIR)/.cargo)

    # Disable LTO, panic strategy and optimization settings while
    # we build cargo-c
    $(eval unexport CARGO_PROFILE_RELEASE_LTO)
    $(eval unexport CARGO_PROFILE_RELEASE_OPT_LEVEL)
    $(eval unexport CARGO_PROFILE_RELEASE_PANIC)

    # Unexport target specific compiler / linker flags
    $(eval unexport CFLAGS)
    $(eval unexport CXXFLAGS)
    $(eval unexport LDFLAGS)

    cd '$(SOURCE_DIR)' && cargo build \
        --release

    cargo install \
        --path='$(SOURCE_DIR)' \
        --root='$(PREFIX)/$(BUILD)'
endef

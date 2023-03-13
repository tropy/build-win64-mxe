PKG             := libheif
$(PKG)_WEBSITE  := http://www.libheif.org/
$(PKG)_DESCR    := libheif is a ISO/IEC 23008-12:2017 HEIF file format decoder and encoder.
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.15.1
$(PKG)_CHECKSUM := 28d5a376fe7954d2d03453f983aaa0b7486f475c27c7806bda31df9102325556
$(PKG)_PATCHES  := $(realpath $(sort $(wildcard $(dir $(lastword $(MAKEFILE_LIST)))/patches/$(PKG)-[0-9]*.patch)))
$(PKG)_GH_CONF  := strukturag/libheif/releases,v
$(PKG)_DEPS     := cc aom

define $(PKG)_BUILD
    # Disable multithreading when building with Win32 threads to
    # avoid a dependency on mingw-std-threads (which we only use
    # in the "all" variant). Disabling multithreading only affects
    # decoding tiled HEIF images, so it should be fine.
    cd '$(BUILD_DIR)' && $(TARGET)-cmake \
        -DENABLE_PLUGIN_LOADING=0 \
        -DWITH_EXAMPLES=0 \
        $(if $(WIN32_THREADS), -DENABLE_MULTITHREADING_SUPPORT=0) \
        $(if $(IS_HEVC),, -DWITH_LIBDE265=0) \
        -DWITH_X265=0 \
        '$(SOURCE_DIR)'
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 $(subst -,/,$(INSTALL_STRIP_LIB))
endef

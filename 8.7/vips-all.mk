PKG             := vips-all
$(PKG)_WEBSITE  := https://libvips.github.io/libvips/
$(PKG)_DESCR    := A fast image processing library with low memory needs.
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 8.7.3
$(PKG)_CHECKSUM := 03e0ed90d63b4e2d7d60ea5bd97283d0f5b1388c6c363e27ec9d34b624b6f5aa
$(PKG)_PATCHES  := $(realpath $(sort $(wildcard $(dir $(lastword $(MAKEFILE_LIST)))/vips-[0-9]*.patch)))
$(PKG)_GH_CONF  := libvips/libvips/releases/download,v
$(PKG)_SUBDIR   := $(subst -all,,$(PKG))-$($(PKG)_VERSION)
$(PKG)_FILE     := $(subst -all,,$(PKG))-$($(PKG)_VERSION).tar.gz
$(PKG)_DEPS     := cc matio libwebp librsvg giflib poppler glib pango fftw \
                   libgsf libjpeg-turbo tiff openslide lcms libexif \
                   imagemagick libpng openexr cfitsio nifticlib orc

define $(PKG)_PRE_CONFIGURE
    # Copy some files to the packaging directory
    mkdir -p $(TOP_DIR)/vips-packaging
    $(foreach f,COPYING ChangeLog README.md AUTHORS, mv '$(SOURCE_DIR)/$f' '$(TOP_DIR)/vips-packaging';)
endef

define $(PKG)_BUILD
    $($(PKG)_PRE_CONFIGURE)
    cd '$(BUILD_DIR)' && $(SOURCE_DIR)/configure \
        $(MXE_CONFIGURE_OPTS) \
        --enable-debug=no \
        --disable-introspection \
        --with-jpeg-includes='$(PREFIX)/$(TARGET)/include/libjpeg-turbo' \
        --with-jpeg-libraries='$(PREFIX)/$(TARGET)/lib/libjpeg-turbo'

    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install
endef

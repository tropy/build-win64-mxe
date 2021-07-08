PKG             := vips-tropy
$(PKG)_WEBSITE  := https://libvips.github.io/libvips/
$(PKG)_DESCR    := A fast image processing library with low memory needs.
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 8.11.2
$(PKG)_CHECKSUM := bb5ab776ee4c61ae94b4496c63ef523ca7367ebceabcba78ceb1bf97b1d36e06
$(PKG)_PATCHES  := $(realpath $(sort $(wildcard $(dir $(lastword $(MAKEFILE_LIST)))/patches/vips-[0-9]*.patch)))
$(PKG)_GH_CONF  := libvips/libvips/releases,v
$(PKG)_SUBDIR   := vips-$($(PKG)_VERSION)
$(PKG)_FILE     := vips-$($(PKG)_VERSION).tar.gz
$(PKG)_DEPS     := cc libwebp librsvg poppler glib pango libgsf \
                   libjpeg-turbo tiff lcms libexif libde265 libheif \
                   libjxl libpng libspng libimagequant orc openjpeg

define $(PKG)_PRE_CONFIGURE
    # Copy some files to the packaging directory
    mkdir -p $(PREFIX)/$(TARGET)/vips-packaging
    $(foreach f,COPYING ChangeLog README.md AUTHORS, cp '$(SOURCE_DIR)/$f' '$(PREFIX)/$(TARGET)/vips-packaging';)

    (printf '{\n'; \
     printf '  "aom": "$(aom_VERSION)",\n'; \
     printf '  "cairo": "$(cairo_VERSION)",\n'; \
     printf '  "de265": "$(libde265_VERSION)",\n'; \
     printf '  "exif": "$(libexif_VERSION)",\n'; \
     printf '  "expat": "$(expat_VERSION)",\n'; \
     printf '  "ffi": "$(libffi_VERSION)",\n'; \
     printf '  "fftw": "$(fftw_VERSION)",\n'; \
     printf '  "fontconfig": "$(fontconfig_VERSION)",\n'; \
     printf '  "freetype": "$(freetype_VERSION)",\n'; \
     printf '  "fribidi": "$(fribidi_VERSION)",\n'; \
     printf '  "gdkpixbuf": "$(gdk-pixbuf_VERSION)",\n'; \
     printf '  "gif": "$(giflib_VERSION)",\n'; \
     printf '  "glib": "$(glib_VERSION)",\n'; \
     printf '  "gsf": "$(libgsf_VERSION)",\n'; \
     printf '  "harfbuzz": "$(harfbuzz_VERSION)",\n'; \
     printf '  "heif": "$(libheif_VERSION)",\n'; \
     printf '  "highway": "$(highway_VERSION)",\n'; \
     $(if $(IS_MOZJPEG),,printf '  "jpeg": "$(libjpeg-turbo_VERSION)"$(comma)\n';) \
     printf '  "jxl": "$(libjxl_VERSION)",\n'; \
     printf '  "lcms": "$(lcms_VERSION)",\n'; \
     $(if $(IS_MOZJPEG),printf '  "mozjpeg": "$(mozjpeg_VERSION)"$(comma)\n';) \
     printf '  "openjpeg": "$(openjpeg_VERSION)",\n'; \
     printf '  "orc": "$(orc_VERSION)",\n'; \
     printf '  "pango": "$(pango_VERSION)",\n'; \
     printf '  "pixman": "$(pixman_VERSION)",\n'; \
     printf '  "png": "$(libpng_VERSION)",\n'; \
     printf '  "poppler": "$(poppler_VERSION)",\n'; \
     printf '  "svg": "$(librsvg_VERSION)",\n'; \
     printf '  "spng": "$(libspng_VERSION)",\n'; \
     printf '  "tiff": "$(tiff_VERSION)",\n'; \
     printf '  "vips": "$(vips-all_VERSION)",\n'; \
     printf '  "webp": "$(libwebp_VERSION)",\n'; \
     $(if $(IS_HEVC),printf '  "x265": "$(x265_VERSION)"$(comma)\n';) \
     printf '  "xml": "$(libxml2_VERSION)",\n'; \
     printf '  "zlib": "$(zlib_VERSION)"\n'; \
     printf '}';) \
     > '$(PREFIX)/$(TARGET)/vips-packaging/versions.json'
endef

define $(PKG)_BUILD
    $($(PKG)_PRE_CONFIGURE)

    # --libdir argument ensures that the dynamic modules
    # are installed and found in /bin (Windows convention).
    # --with-pkgconfigdir argument is needed since we have
    # overwritten the $libdir variable.
    cd '$(BUILD_DIR)' && $(SOURCE_DIR)/configure \
        $(MXE_CONFIGURE_OPTS) \
        --libdir='$(PREFIX)/$(TARGET)/bin' \
        --with-pkgconfigdir='$(PREFIX)/$(TARGET)/lib/pkgconfig' \
        --enable-debug=no \
        --without-pdfium \
        --without-openslide \
        --without-cfitsio \
        --without-OpenEXR \
        --without-nifti \
        --without-matio \
        --without-ppm \
        --without-analyze \
        --without-radiance \
        --disable-introspection \
        --disable-deprecated

    # remove -nostdlib from linker commandline options
    # https://debbugs.gnu.org/cgi/bugreport.cgi?bug=27866
    $(if $(IS_LLVM), \
        $(SED) -i '/^archive_cmds=/s/\-nostdlib//g' '$(BUILD_DIR)/libtool')

    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install
endef

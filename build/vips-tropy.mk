PKG             := vips-tropy
$(PKG)_WEBSITE  := https://libvips.github.io/libvips/
$(PKG)_DESCR    := A fast image processing library with low memory needs.
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 8.15.3
$(PKG)_CHECKSUM := 3e27d9f536eafad64013958fe9e8a1964c90b564c731d49db7c1a1c11b1052a0
$(PKG)_PATCHES  := $(realpath $(sort $(wildcard $(dir $(lastword $(MAKEFILE_LIST)))/patches/vips-[0-9]*.patch)))
$(PKG)_GH_CONF  := libvips/libvips/releases,v,,,,.tar.xz
$(PKG)_SUBDIR   := vips-$($(PKG)_VERSION)
$(PKG)_FILE     := vips-$($(PKG)_VERSION).tar.xz
$(PKG)_DEPS     := cc meson-wrapper libwebp librsvg glib pango libarchive \
                   libjpeg-turbo tiff lcms libexif libheif libpng \
                   libspng libimagequant cgif openjpeg poppler

define $(PKG)_PRE_CONFIGURE
    # Copy some files to the packaging directory
    mkdir -p $(PREFIX)/$(TARGET)/vips-packaging
    $(foreach f, ChangeLog LICENSE README.md, \
        cp '$(SOURCE_DIR)/$(f)' '$(PREFIX)/$(TARGET)/vips-packaging';)

    (printf '{\n'; \
     printf '  "aom": "$(aom_VERSION)",\n'; \
     printf '  "archive": "$(libarchive_VERSION)",\n'; \
     printf '  "cairo": "$(cairo_VERSION)",\n'; \
     printf '  "cgif": "$(cgif_VERSION)",\n'; \
     $(if $(IS_HEVC),printf '  "de265": "$(libde265_VERSION)"$(comma)\n';) \
     printf '  "exif": "$(libexif_VERSION)",\n'; \
     printf '  "expat": "$(expat_VERSION)",\n'; \
     printf '  "ffi": "$(libffi_VERSION)",\n'; \
     printf '  "fontconfig": "$(fontconfig_VERSION)",\n'; \
     printf '  "freetype": "$(freetype_VERSION)",\n'; \
     printf '  "fribidi": "$(fribidi_VERSION)",\n'; \
     printf '  "gdkpixbuf": "$(gdk-pixbuf_VERSION)",\n'; \
     $(if $(IS_INTL_DUMMY),,printf '  "gettext": "$(gettext_VERSION)"$(comma)\n';) \
     printf '  "glib": "$(glib_VERSION)",\n'; \
     printf '  "harfbuzz": "$(harfbuzz_VERSION)",\n'; \
     printf '  "heif": "$(libheif_VERSION)",\n'; \
     printf '  "imagequant": "$(libimagequant_VERSION)",\n'; \
     $(if $(IS_MOZJPEG),,printf '  "jpeg": "$(libjpeg-turbo_VERSION)"$(comma)\n';) \
     printf '  "lcms": "$(lcms_VERSION)",\n'; \
     $(if $(IS_MOZJPEG),printf '  "mozjpeg": "$(mozjpeg_VERSION)"$(comma)\n';) \
     printf '  "openjpeg": "$(openjpeg_VERSION)",\n'; \
     printf '  "pango": "$(pango_VERSION)",\n'; \
     printf '  "pixman": "$(pixman_VERSION)",\n'; \
     printf '  "png": "$(libpng_VERSION)",\n'; \
     printf '  "poppler": "$(poppler_VERSION)",\n'; \
     $(if $(IS_INTL_DUMMY),printf '  "proxy-libintl": "$(proxy-libintl_VERSION)"$(comma)\n';) \
     printf '  "rsvg": "$(librsvg_VERSION)",\n'; \
     printf '  "spng": "$(libspng_VERSION)",\n'; \
     printf '  "tiff": "$(tiff_VERSION)",\n'; \
     printf '  "vips": "$(vips-tropy_VERSION)",\n'; \
     printf '  "webp": "$(libwebp_VERSION)",\n'; \
     printf '  "xml": "$(libxml2_VERSION)",\n'; \
     $(if $(IS_ZLIB_NG), \
          printf '  "zlib-ng": "$(zlib-ng_VERSION)"\n';, \
          printf '  "zlib": "$(zlib_VERSION)"\n';) \
     printf '}';) \
     > '$(PREFIX)/$(TARGET)/vips-packaging/versions.json'
endef

define $(PKG)_BUILD
    $($(PKG)_PRE_CONFIGURE)

    $(eval export CFLAGS += -O3)
    $(eval export CXXFLAGS += -O3)

    $(MXE_MESON_WRAPPER) \
        --default-library=shared \
        -Ddeprecated=false \
        -Dexamples=false \
        -Dintrospection=disabled \
        -Dmodules=disabled \
        -Dcfitsio=disabled \
        -Dfftw=disabled \
        -Djpeg-xl=disabled \
        -Dmagick=disabled \
        -Dmatio=disabled \
        -Dnifti=disabled \
        -Dopenexr=disabled \
        -Dopenjpeg=enabled \
        -Dopenslide=disabled \
        -Dheif-module=$(if $(IS_HEVC),enabled,disabled) \
        -Dpdfium=disabled \
        -Dpoppler=enabled \
        -Dquantizr=disabled \
        -Dppm=false \
        -Danalyze=false \
        -Dradiance=false \
        '$(SOURCE_DIR)' \
        '$(BUILD_DIR)'

    $(MXE_NINJA) -C '$(BUILD_DIR)' -j '$(JOBS)' install
endef

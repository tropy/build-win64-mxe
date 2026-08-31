$(PLUGIN_HEADER)

# Enable old-style JPEG in TIFF images so Tropy can read legacy
# OJPEG-compressed TIFFs. Appended after the -Dold-jpeg=OFF that
# tiff_BUILD passes, so this wins. See:
# https://github.com/libvips/libvips/issues/1328#issuecomment-572020749
tiff_CMAKE_OPTS = -Dold-jpeg=ON

# The 'web' group of loaders, plus JPEG XL, JPEG 2000, PDF and camera RAW.
vips_MESON_OPTS = \
    -Dmodules=disabled \
    -Dcfitsio=disabled \
    -Dfftw=disabled \
    -Djpeg-xl=enabled \
    -Dmagick=disabled \
    -Dmatio=disabled \
    -Dnifti=disabled \
    -Dopenexr=disabled \
    -Dopenjpeg=enabled \
    -Dopenslide=disabled \
    -Dpdfium=disabled \
    -Dpoppler=enabled \
    -Dquantizr=disabled \
    -Draw=enabled \
    -Dspng=disabled \
    -Dppm=false \
    -Danalyze=false \
    -Dradiance=false

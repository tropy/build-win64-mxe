$(PLUGIN_HEADER)

vips_MESON_OPTS = \
    -Dmodules=enabled \
    -Dcfitsio=disabled \
    -Dfftw=disabled \
    -Djpeg-xl=disabled \
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

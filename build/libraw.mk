PKG             := libraw
$(PKG)_WEBSITE  := https://libraw.org
$(PKG)_DESCR    := A library for reading RAW files obtained from digital cameras
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 0.22.1
$(PKG)_CHECKSUM := a789dc4e2409e2901d93793a4e0b80c7b49d0d97cf6ad71c850eb7616acfd786
$(PKG)_SUBDIR   := LibRaw-$($(PKG)_VERSION)
$(PKG)_FILE     := LibRaw-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://www.libraw.org/data/$($(PKG)_FILE)
$(PKG)_DEPS     := cc libjpeg-turbo lcms zlib

define $(PKG)_BUILD
    cd '$(SOURCE_DIR)' && autoreconf -fi
    cd '$(BUILD_DIR)' && '$(SOURCE_DIR)'/configure \
        $(MXE_CONFIGURE_OPTS) \
        --disable-openmp \
        --enable-jpeg \
        --enable-zlib \
        --enable-lcms \
        --disable-examples \
        CXXFLAGS='-std=gnu++11 $(if $(BUILD_SHARED),-DLIBRAW_BUILDLIB,-DLIBRAW_NODLL)' \
        LDFLAGS='-lws2_32'
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' install
    # Add missing entries to pkg-config files.
    (echo ''; \
     echo 'Libs.private: -lws2_32'; \
     echo 'Cflags.private: -DLIBRAW_NODLL';) \
     | tee -a '$(PREFIX)/$(TARGET)/lib/pkgconfig/$(PKG).pc' \
              '$(PREFIX)/$(TARGET)/lib/pkgconfig/$(PKG)_r.pc'

    '$(TARGET)-g++' -Wall -Wextra -std=c++11 \
        '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
        `'$(TARGET)-pkg-config' libraw_r --cflags --libs`
endef

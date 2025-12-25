################################################################################
#
# fbink
#
################################################################################

FBINK_VERSION = master
FBINK_SITE = $(call github,NiLuJe,FBInk,$(FBINK_VERSION))
FBINK_LICENSE = GPL-2.0+
FBINK_LICENSE_FILES = LICENSE
FBINK_DEPENDENCIES =

# FBInk uses submodules; ensure they're initialized
FBINK_SUBMODULES = YES

# Build options
FBINK_MAKE_OPTS = \
    PREFIX=/usr \
    CC="$(TARGET_CC)" \
    CFLAGS="$(TARGET_CFLAGS) -D_GNU_SOURCE -DFBINK_FOR_KOBO" \
    LDFLAGS="$(TARGET_LDFLAGS) $(if $(BR2_PACKAGE_FBINK_STATIC),-static)" \
    STRIP="$(TARGET_STRIP)" AR="$(TARGET_AR)" RANLIB="$(TARGET_RANLIB)" \
    DRAW=1 \
    BITMAP=1 \
    FONTS=1

define FBINK_INIT_SUBMODULES
    # Initialize git repository first
    cd $(@D) && git init && git config user.email "buildroot@localhost" && \
    git config user.name "buildroot" && git add -A && \
    git commit -m "buildroot snapshot" --allow-empty
    # Download ALL submodules needed by FBInk to avoid version conflicts
    echo "Downloading ALL FBInk submodules..." && \
    rm -rf $(@D)/font8x8 $(@D)/stb $(@D)/libunibreak $(@D)/i2c-tools $(@D)/libevdev $(@D)/libi2c && \
    git clone --depth 1 --branch fbink https://github.com/NiLuJe/font8x8.git $(@D)/font8x8 && \
    git clone --depth 1 --branch fbink-1.26 https://github.com/NiLuJe/stb.git $(@D)/stb && \
    git clone --depth 1 https://github.com/adah1972/libunibreak.git $(@D)/libunibreak && \
    git clone https://git.kernel.org/pub/scm/utils/i2c-tools/i2c-tools.git $(@D)/i2c-tools && \
    cd $(@D)/i2c-tools && git checkout ea51da725b743da00b894dfdc4ab189f5a51e90e && cd $(@D) && \
    git clone --depth 1 https://gitlab.freedesktop.org/libevdev/libevdev.git $(@D)/libevdev && \
    git clone --depth 1 https://github.com/amaork/libi2c.git $(@D)/libi2c
    # Apply cross-compilation compatibility fix
endef
FBINK_POST_EXTRACT_HOOKS += FBINK_INIT_SUBMODULES

define FBINK_BUILD_CMDS
    echo "master" > $(@D)/VERSION
    # Run the upstream "release" target to build shared libraries
    # (upstream Makefile defaults to static builds when no target is given).
    $(TARGET_MAKE_ENV) $(MAKE) -C $(@D) $(FBINK_MAKE_OPTS) KOBO=1 release
endef

define FBINK_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/Release/fbink $(TARGET_DIR)/usr/bin/fbink
    if [ -f $(@D)/Release/libfbink.so.1.0.0 ]; then \
        $(INSTALL) -D -m 0755 $(@D)/Release/libfbink.so.1.0.0 $(TARGET_DIR)/usr/lib/libfbink.so.1.0.0; \
        ln -sf libfbink.so.1.0.0 $(TARGET_DIR)/usr/lib/libfbink.so.1; \
        ln -sf libfbink.so.1.0.0 $(TARGET_DIR)/usr/lib/libfbink.so; \
    fi
    if [ -f $(@D)/Release/button_scan ]; then \
        $(INSTALL) -D -m 0755 $(@D)/Release/button_scan $(TARGET_DIR)/usr/bin/button_scan; \
    fi
    $(if $(BR2_PACKAGE_FBINK_FONTS), \
        if [ -d $(@D)/fonts ]; then \
            mkdir -p $(TARGET_DIR)/usr/share/fbink; \
            cp -r $(@D)/fonts $(TARGET_DIR)/usr/share/fbink/; \
        fi \
    )
endef

define FBINK_INSTALL_STAGING_CMDS
    $(TARGET_MAKE_ENV) $(MAKE) -C $(@D) $(FBINK_MAKE_OPTS) DESTDIR=$(STAGING_DIR) install
endef

$(eval $(generic-package))

# Override eudev CFLAGS to enable C99 support
EUDEV_CONF_ENV = CFLAGS="$(TARGET_CFLAGS) -std=gnu99"

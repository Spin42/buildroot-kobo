# Buildroot external extension: support split kernel tarballs
#
# Kobo publishes the kernel sources for the Clara Colour as split files, e.g.:
#   kernel.tar.zst.part-aa + kernel.tar.zst.part-ab
#
# The linux package can download extra files via LINUX_EXTRA_DOWNLOADS,
# but extraction expects a single archive. When the selected custom
# tarball ends with ".part-aa", also download ".part-ab", concatenate
# them to rebuild the original archive, and extract it.

LINUX_KOBO_SPLIT_TARBALL_AA := $(filter %.part-aa,$(LINUX_SOURCE))

ifneq ($(LINUX_KOBO_SPLIT_TARBALL_AA),)
LINUX_KOBO_SPLIT_TARBALL_AB := $(patsubst %.part-aa,%.part-ab,$(LINUX_KOBO_SPLIT_TARBALL_AA))
LINUX_KOBO_SPLIT_TARBALL_JOINED := $(patsubst %.part-aa,%,$(LINUX_KOBO_SPLIT_TARBALL_AA))

# Download the second part from the same site.
LINUX_EXTRA_DOWNLOADS += $(LINUX_SITE)/$(LINUX_KOBO_SPLIT_TARBALL_AB)

# Extra downloads must have a hash, otherwise the download step fails.
# The kernel tarball itself is already typically exempted from hash checking
# for custom sources; do the same for the additional split part.
BR_NO_CHECK_HASH_FOR += $(LINUX_KOBO_SPLIT_TARBALL_AB)

# We'll run zstdcat (via suitable-extractor) ourselves.
LINUX_DEPENDENCIES += host-zstd

define LINUX_EXTRACT_CMDS
	$(Q)mkdir -p $(@D)
	$(Q)cat $(LINUX_DL_DIR)/$(LINUX_KOBO_SPLIT_TARBALL_AA) \
		$(LINUX_DL_DIR)/$(LINUX_KOBO_SPLIT_TARBALL_AB) \
		> $(@D)/$(LINUX_KOBO_SPLIT_TARBALL_JOINED)
	$(Q)$(call suitable-extractor,$(LINUX_KOBO_SPLIT_TARBALL_JOINED)) \
		$(@D)/$(LINUX_KOBO_SPLIT_TARBALL_JOINED) | \
		$(TAR) --strip-components=1 -C $(@D) $(TAR_OPTIONS) -
	$(Q)if [ ! -f "$(@D)/Makefile" ] && [ -f "$(@D)/v4.9/Makefile" ]; then \
		cp -a "$(@D)/v4.9/." "$(@D)/"; \
		rm -rf "$(@D)/v4.9"; \
	fi
endef

endif

SHELL=/bin/bash
HS_CONFIG_DIR := $(HOME)/.hammerspoon

$(HS_CONFIG_DIR): backup
	ln -s $(PWD) $@

backup:
	if [ -d $(HS_CONFIG_DIR) ]; then \
		mv $(HS_CONFIG_DIR) $(HS_CONFIG_DIR).bak; \
	fi

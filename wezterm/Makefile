SHELL=/bin/bash
WEZTERM_CONFIG_DIR := $(HOME)/.config/wezterm
WEZTERM_CONFIG := $(WEZTERM_CONFIG_DIR)/wezterm.lua

$(WEZTERM_CONFIG): backup $(WEZTERM_CONFIG_DIR)
	ln -s $(PWD)/wezterm.lua $@

$(WEZTERM_CONFIG_DIR):
	mkdir -p $@

backup:
	if [ -f $(WEZTERM_CONFIG) ]; then \
		mv $(WEZTERM_CONFIG) $(WEZTERM_CONFIG).bak; \
	fi

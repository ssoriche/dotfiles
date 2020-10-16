SHELL=/bin/bash
export KITTY_CONFIG_DIR := $(HOME)/.config/kitty
KITTY_CONFIG := $(KITTY_CONFIG_DIR)/kitty.conf
KITTY_THEMES := $(KITTY_CONFIG_DIR)/kitty-themes
KITTY_THEME := $(KITTY_CONFIG_DIR)/theme.conf

$(KITTY_CONFIG): backup $(KITTY_CONFIG_DIR) $(KITTY_THEMES) $(KITTY_THEME)
	if [ ! -h $(KITTY_CONFIG) ]; then \
		ln -s $(PWD)/kitty.conf $@; \
	fi

$(KITTY_CONFIG_DIR):
	mkdir -p $@

.PHONY: backup
backup:
	if [ -e $(KITTY_CONFIG) ] && [ ! -h $(KITTY_CONFIG) ]; then \
		mv $(KITTY_CONFIG) $(KITTY_CONFIG).bak; \
	fi
	if [ ! -h $(KITTY_THEME) ]; then \
		mv $(KITTY_THEME) $(KITTY_THEME).bak; \
	fi

$(KITTY_THEMES): $(KITTY_CONFIG_DIR)
	if [ ! -h $(KITTY_THEMES) ]; then \
		ln -s $(PWD)/kitty-themes $@; \
	fi

$(KITTY_THEMES_THEMES): $(KITTY_THEMES)
	if [ ! -d $(KITTY_THEMES_THEMES) ]; then \
		mkdir -p $@; \
	fi \
	curl -sfLo $(KITTY_THEMES_THEMES)/Jellybeans.conf \
	https://raw.githubusercontent.com/dexpota/kitty-themes/master/themes/Jellybeans.conf

$(KITTY_THEME): $(KITTY_THEMES)
	if [ ! -h $(KITTY_THEME) ]; then \
		ln -s $(KITTY_THEMES_THEMES)/Jellybeans.conf $@; \
	fi

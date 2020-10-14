SHELL=/bin/bash
export KITTY_CONFIG_DIR := $(HOME)/.config/kitty
KITTY_CONFIG := $(KITTY_CONFIG_DIR)/kitty.conf
SPACEGREY_THEME := $(KITTY_CONFIG_DIR)/spacegrey.conf

$(KITTY_CONFIG): backup $(KITTY_CONFIG_DIR) $(SPACEGREY_THEME)
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
	if [ ! -h $(SPACEGREY_THEME) ]; then \
		mv $(SPACEGREY_THEME) $(SPACEGREY_THEME).bak; \
	fi

$(SPACEGREY_THEME): $(KITTY_CONFIG_DIR)
	if [ ! -h $(SPACEGREY_THEME) ]; then \
		ln -s $(PWD)/spacegrey.conf $@; \
	fi

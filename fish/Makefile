SHELL=/bin/bash
FISH_CONFIG_DIR := $(HOME)/.config/fish
FISH_CONFIG := $(FISH_CONFIG_DIR)/config.fish
FISH_FUNCTION_DIR := $(FISH_CONFIG_DIR)/functions
FISHER_PLUG := $(FISH_FUNCTION_DIR)/fisher.fish

$(FISH_CONFIG): backup $(FISH_CONFIG_DIR) $(FISHER_PLUG)
	ln -s $(PWD)/config.fish $@

$(FISH_CONFIG_DIR):
	mkdir -p $@

backup:
	if [ -f $(FISH_CONFIG) ]; then \
		mv $(FISH_CONFIG) $(FISH_CONFIG).bak; \
	fi

$(FISHER_PLUG): $(FISH_FUNCTION_DIR)
	curl -sfLo $(FISHER_PLUG) \
	    https://git.io/fisher

$(FISH_FUNCTION_DIR):
	mkdir -p $@

SHELL=/bin/bash
export FISH_CONFIG_DIR := $(HOME)/.config/fish
FISH_CONFIG := $(FISH_CONFIG_DIR)/config.fish
FISH_FUNCTION_DIR := $(FISH_CONFIG_DIR)/functions
FISHER_PLUG := $(FISH_FUNCTION_DIR)/fisher.fish
FISHER_CONFIG := $(FISH_CONFIG_DIR)/fishfile

$(FISH_CONFIG): backup $(FISH_CONFIG_DIR) $(FISHER_PLUG) completions configurations $(FISHER_CONFIG)
	if [ ! -h $(FISH_CONFIG) ]; then \
		ln -s $(PWD)/config.fish $@; \
	fi

$(FISH_CONFIG_DIR):
	mkdir -p $@

.PHONY: backup
backup:
	if [ ! -h $(FISH_CONFIG) ]; then \
		mv $(FISH_CONFIG) $(FISH_CONFIG).bak; \
	fi

$(FISHER_PLUG): $(FISH_FUNCTION_DIR)
	curl -sfLo $(FISHER_PLUG) \
	    https://git.io/fisher

$(FISH_FUNCTION_DIR):
	mkdir -p $@

.PHONY: completions
completions: $(FISH_CONFIG_DIR)
	$(MAKE) -C completions

.PHONY: configurations
configurations: $(FISH_CONFIG_DIR)
	$(MAKE) -C conf.d

$(FISHER_CONFIG): $(FISH_CONFIG_DIR)
	if [ ! -h $(FISHER_CONFIG) ]; then \
		ln -s $(PWD)/fishfile $@; \
	fi

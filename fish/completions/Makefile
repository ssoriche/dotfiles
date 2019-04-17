SHELL=/bin/bash
FISH_COMPLETION_DIR := $(FISH_CONFIG_DIR)/completions

$(FISH_COMPLETION_DIR)/git.fish: $(FISH_COMPLETION_DIR)
	if [ ! -h $(FISH_COMPLETION_DIR)/git.fish ]; then \
		ln -s $(PWD)/completions/git.fish $@; \
	fi

$(FISH_COMPLETION_DIR):
	mkdir -p $@

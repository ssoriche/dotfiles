SHELL=/bin/bash
FISH_COMPLETION_DIR := $(FISH_CONFIG_DIR)/completions

default: $(FISH_COMPLETION_DIR)/git.fish $(FISH_COMPLETION_DIR)/aws.fish

$(FISH_COMPLETION_DIR)/git.fish: $(FISH_COMPLETION_DIR)
	if [ ! -h $(FISH_COMPLETION_DIR)/git.fish ]; then \
		ln -s $(PWD)/completions/git.fish $@; \
	fi

$(FISH_COMPLETION_DIR)/aws.fish: $(FISH_COMPLETION_DIR)
	if [ ! -h $(FISH_COMPLETION_DIR)/aws.fish ]; then \
		ln -s $(PWD)/completions/aws.fish $@; \
	fi

$(FISH_COMPLETION_DIR):
	mkdir -p $@

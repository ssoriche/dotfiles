SHELL=/bin/bash
FISH_CONFIGUARTIONS_DIR := $(FISH_CONFIG_DIR)/conf.d

$(FISH_CONFIGUARTIONS_DIR)/0rax-bd.fish: $(FISH_CONFIGUARTIONS_DIR)
	if [ ! -h $(FISH_CONFIGUARTIONS_DIR)/0rax-bd.fish ]; then \
		ln -s $(PWD)/conf.d/0rax-bd.fish $@; \
	fi

$(FISH_CONFIGUARTIONS_DIR):
	mkdir -p $@

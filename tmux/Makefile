SHELL:=/bin/bash
TMUX_CONFIG := $(HOME)/.tmux.conf
TMUX_VERSION := $(shell tmux -V)
TMUX_MAJOR_VERSION := $(firstword $(subst ., , $(word 2, $(TMUX_VERSION))))

# all:
# 	@echo TMUX_VERSION is $(TMUX_VERSION)
# 	@echo TMUX_MAJOR_VERSION is :${TMUX_MAJOR_VERSION}:

$(TMUX_CONFIG): backup
	if [ ! -e $(TMUX_CONFIG) ] || [ -h $(TMUX_CONFIG) ]; then \
		ln -sf $(PWD)/tmux.conf.$(TMUX_MAJOR_VERSION) $@; \
	fi

.PHONY: backup
backup:
	if [ -e $(TMUX_CONFIG) ] && [ ! -h $(TMUX_CONFIG) ]; then \
		mv $(TMUX_CONFIG) $(TMUX_CONFIG).bak; \
	fi

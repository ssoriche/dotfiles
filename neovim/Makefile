SHELL=/bin/bash
NVIM_CONFIG_DIR := $(HOME)/.config/nvim
NVIM_CONFIG := $(NVIM_CONFIG_DIR)/init.vim
NVIM_STATUS := $(NVIM_CONFIG_DIR)/status.vim
VIM_PLUG_DIR := $(HOME)/.local/share/nvim/site/autoload
VIM_PLUG := $(VIM_PLUG_DIR)/plug.vim

$(NVIM_CONFIG): backup $(NVIM_CONFIG_DIR) $(NVIM_STATUS) $(VIM_PLUG)
	ln -s $(PWD)/init.vim $@

$(NVIM_STATUS):
	ln -s $(PWD)/status.vim $@

$(NVIM_CONFIG_DIR):
	mkdir -p $@

backup:
	if [ -f $(NVIM_CONFIG) ]; then \
		mv $(NVIM_CONFIG) $(NVIM_CONFIG).bak; \
	fi
	if [ -f $(NVIM_STATUS) ]; then \
		mv $(NVIM_STATUS) $(NVIM_STATUS).bak; \
	fi

$(VIM_PLUG): $(VIM_PLUG_DIR)
	curl -fLo $(VIM_PLUG) \
	    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

$(VIM_PLUG_DIR):
	mkdir -p $@


SHELL=/bin/bash
NVIM_CONFIG_DIR := $(HOME)/.config/nvim
NVIM_LUA_DIR := $(NVIM_CONFIG_DIR)/lua
NVIM_CONFIG := $(NVIM_CONFIG_DIR)/init.lua
NVIM_FTPLUGIN_DIR := $(NVIM_CONFIG_DIR)/ftplugin
# NVIM_STATUS := $(NVIM_CONFIG_DIR)/status.vim
# VIM_PLUG_DIR := $(HOME)/.local/share/nvim/site/autoload
# VIM_PLUG := $(VIM_PLUG_DIR)/plug.vim

$(NVIM_CONFIG): backup $(NVIM_CONFIG_DIR) $(NVIM_STATUS) $(NVIM_FTPLUGIN_DIR) $(NVIM_LUA_DIR)
	ln -s $(PWD)/init.lua $@

# $(NVIM_STATUS):
# 	ln -s $(PWD)/status.vim $@

$(NVIM_CONFIG_DIR):
	mkdir -p $@

$(NVIM_LUA_DIR): $(NVIM_CONFIG_DIR)
	ln -s $(PWD)/lua $@

$(NVIM_FTPLUGIN_DIR): $(NVIM_CONFIG_DIR)
	ln -s $(PWD)/ftplugin $@

backup:
	if [ -f $(NVIM_CONFIG) ]; then \
		mv $(NVIM_CONFIG) $(NVIM_CONFIG).bak; \
	fi
	if [ -d $(NVIM_FTPLUGIN_DIR) ]; then \
		mv $(NVIM_FTPLUGIN_DIR) $(NVIM_FTPLUGIN_DIR).bak; \
	fi
	if [ -d $(NVIM_LUA_DIR) ]; then \
		mv $(NVIM_LUA_DIR) $(NVIM_LUA_DIR).bak; \
	fi

# $(VIM_PLUG): $(VIM_PLUG_DIR)
# 	curl -fLo $(VIM_PLUG) \
# 	    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# $(VIM_PLUG_DIR):
# 	mkdir -p $@


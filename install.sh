#! /bin/bash

# Check for instillation of git, vim, tmux, and zsh
command -v git >/dev/null 2>&1 ||\
	{ echo >&2 "How are you even running this without git?"; exit 1; }

# link vimrc
if command -v vim >/dev/null 2>&1; then
	echo "Linking vim configs"
	if [ ! -d ~/.vim/bundle/vundle ]; then
		git clone https://github.com/gmarik/vundle ~/.vim/bundle/vundle
	fi
	if [ -e ~/.vimrc ]; then
		echo ".vimrc detected, save anything important and remove it"
		exit 1
	else
		ln -s vimrc ~/.vimrc
	fi
	if [ -e ~/.vimrc.bundles ]; then
		echo ".vimrc.bundles detected, save anything important and remove it"
		exit 1
	else
		ln -s vimrc.bundles ~/.vimrc.bundles
	fi
	cp vimrc.local ~/.vimrc.local
	cp vimrc.bundles.local ~/.vimrc.bundles.local
	vim -c "PluginInstall" -c "q" -c "q"
else
	echo "vim not found, install it to configure"
fi

# link tmux.conf
if command -v tmux >/dev/null 2>&1; then
	echo "Linking tmux config"
	if [ -e ~/.tmux.conf ]; then
		echo ".tmux.conf detected, save anything important and remove it"
		exit 1
	else
		ln -s tmux.conf ~/.tmux.conf
	fi
else
	echo "tmux not found, install it to configure"
fi

# clone oh-my-zsh
if command -v zsh >/dev/null 2>&1; then
	echo "Linking zsh configs"
	if [ ! -d ~/.oh-my-zsh ]; then
		git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
	fi
	if [ -e ~/.zshrc ]; then
		echo ".zshrc detected, save anything important and remove it"
		exit 1
	else
		ln -s zshrc ~/.zshrc
	fi
	cp zshrc.local ~/.zshrc.local
else
	echo "zsh not found, install it to configure"
fi
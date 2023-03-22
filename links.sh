#!/bin/bash

# skhd
ln -vi .skhdrc ~

# yabai
ln -vi .yabairc ~

# zsh
ln -vi .zshrc ~

# starship
mkdir -vp ~/.config
ln -vi starship.toml ~/.config

# nvim
mkdir -vp ~/.config/nvim
ln -vi nvim/init.vim ~/.config/nvim
ln -vsi $PWD/nvim/lua ~/.config/nvim

# sketchybar
mkdir -vp ~/.config/sketchybar
ln -vi sketchybar/sketchybarrc ~/.config/sketchybar
ln -vi sketchybar/colors.sh ~/.config/sketchybar
ln -vi sketchybar/icons.sh ~/.config/sketchybar
ln -vsi $PWD/sketchybar/items ~/.config/sketchybar
ln -vsi $PWD/sketchybar/plugins ~/.config/sketchybar

# tmux
mkdir -vp ~/.config/tmux
ln -vi tmux.conf ~/.config/tmux

# bat
mkdir -vp ~/.config/bat
ln -vi bat/config ~/.config/bat
ln -vsi $PWD/bat/themes ~/.config/bat

# karabiner
mkdir -vp ~/.config/karabiner
ln -vi karabiner/karabiner.json ~/.config/karabiner
ln -vsi $PWD/karabiner/assets ~/.config/karabiner

# alacritty
mkdir -vp ~/.config/alacritty
ln -vi alacritty/alacritty.yml ~/.config/alacritty

# zellij
mkdir -vp ~/.config/zellij
ln -vi zellij/config.kdl ~/.config/zellij
ln -vsi zellij/themes ~/.config/zellij


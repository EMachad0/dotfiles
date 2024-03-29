# Dotfiles

This repository contains my personal dotfiles. They are configuration files that are used to customize your system.

## Screnshots

### Iterm2 + Tmux

![image](https://user-images.githubusercontent.com/30319164/226915770-1aac0f4e-f9e0-4f29-8806-2bb06cb2c7c5.png)


### Alacritty + Zellij

![image](https://user-images.githubusercontent.com/30319164/226915305-63d3adaa-74d6-4190-9508-b229b179f565.png)

### Yabai + Alfred

![image](https://user-images.githubusercontent.com/30319164/226936773-cf7bd2c0-4ea4-4fb2-8097-98b89279f40e.png)

### Fzf + Bat

![image](https://user-images.githubusercontent.com/30319164/226937620-89e806ad-7154-4e5f-8926-d19d6c20cbce.png)


## Theme

I use the [catpuccin](https://github.com/catppuccin) theme whenever possible, some apps include customizations to make it fit my own style!

## Installation

I use `GNU stow` to create symlinks for the dotfiles. 

To create links to the `.dotfiles` of this directory:

```bash
stow . -t ~
```

If the file already exists, an error will be displayed.

To delete all links created:
```bash
stow -D . -t ~
```

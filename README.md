# DNvim

A personal Neovim setup for everyday development work in Python, Go, Lua and Kubernetes/Helm.

## Goals

- **Fast.** Stays responsive in large repositories, big log files and long Helm charts.
- **Small.** Few plugins; simple features are built in rather than pulled in as dependencies.
- **Focused.** Tuned for one way of working rather than covering every possible use case.

## Features

- Fuzzy finding of files, text, recent files and projects, built on
  [fzf-lua](https://github.com/ibhagwan/fzf-lua) rather than Telescope, for speed and to work the same
  way as `fzf` does in the shell
- Language server support for Python, Go, Lua and YAML
- Navigation in Helm charts, between templates and values
- Git integration from staging and blame to merge conflicts and history search
- Live Markdown preview in the browser
- A simple note system for quickly creating and searching Markdown notes
- Persistent sessions per project
- Support for the [Neovide](https://neovide.dev) GUI

## Theme

The default colour scheme is [yaru-dark-ish](https://github.com/dapc11/yaru-dark-ish.nvim), a dark
theme inspired by Ubuntu's Yaru. Its background adapts to the terminal, so Neovim blends in with the
terminal theme in use.

![yaru-dark-ish palette](https://raw.githubusercontent.com/dapc11/yaru-dark-ish.nvim/main/palette.svg)

## Getting Started

Requires Neovim 0.11 or newer. Plugins are managed by [lazy.nvim](https://github.com/folke/lazy.nvim),
which installs itself and all plugins on the first start, so cloning the repository to
`~/.config/nvim` and starting Neovim is all it takes.

Searching relies on `ripgrep`, `fd` and `fzf`. Language support needs the corresponding language
servers to be installed. Anything missing only disables the feature that depends on it.

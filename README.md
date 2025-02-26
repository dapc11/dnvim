# DNvim

Neovim setup for Java, Kubernetes, Python and Golang development


## File structure
- ftplugin: Contains language-specific configurations for filetypes like Go, HTML, Java, JSON, Markdown, Python, and YAML.

- lazy-lock.json: JSON file related to lazy-loading plugins.

- lua: Directory containing Lua scripts for your Neovim setup, organized into subdirectories.

- config: Lua scripts for general configuration, such as autocmds, icons, keymaps, and options.

- plugins: Configuration for various Neovim plugins. Each plugin has its own Lua file.

- util: Utility scripts.

- queries/gotmpl: Contains configuration related to Go templates.

- snippets: Contains snippets for programming languages, including package.json and python.json.

- spell: Spelling-related files.

This directory structure helps organize your Neovim configuration for efficient and customized usage. you can modify individual lua files to fine-tune your editor's behavior, add or remove plugins in the plugins directory, and maintain language-specific settings in the ftplugin directory.


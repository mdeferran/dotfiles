# Future Improvements and Ideas

This document tracks potential improvements and features for the dotfiles repository.

## High Priority

### Terminal and Shell
- [ ] Consider switching from Antigen to a faster plugin manager (zinit, sheldon, or zsh4humans)
- [ ] Add starship prompt as an alternative to the current theme
- [ ] Create a custom Ghostty theme matching the dotfiles aesthetic
- [ ] Add bat configuration (modern cat replacement)
- [ ] Add eza configuration (modern ls replacement)

### Development Tools
- [ ] Add Rust development environment setup
- [ ] Add Node.js/TypeScript environment configuration
- [ ] Create language-specific .editorconfig file
- [ ] Add lazygit configuration for better git UI
- [ ] Add delta (git diff pager) configuration

### Editor Enhancements
- [x] Migrated to lazy.nvim with lockfile support (reproducible across machines)
- [x] Added server mode detection (disables heavy plugins over SSH)
- [ ] Add LSP configuration with nvim-lspconfig for more languages (Rust, TypeScript, etc.)
- [ ] Add Copilot or other AI completion support
- [ ] Consider adding Telescope for fuzzy finding (currently using FZF)
- [ ] Add which-key plugin for keybinding discovery

### Documentation
- [ ] Create INSTALL.md with step-by-step installation guide
- [ ] Add screenshots and examples to README
- [ ] Document all available functions and aliases
- [ ] Create TROUBLESHOOTING.md for common issues
- [ ] Add architecture diagram showing how configs interact

## Medium Priority

### Automation
- [ ] Add GitHub Actions for linting dotfiles
- [ ] Create automated backup script for existing configs
- [ ] Add update script to pull latest changes safely
- [ ] Create test suite for shell functions
- [ ] Add pre-commit hooks for dotfiles repository

### Configuration Management
- [ ] Add support for machine-specific overrides (work vs home)
- [ ] Create encrypted secrets management solution
- [ ] Add support for multiple OS distributions (Debian, Arch, etc.)
- [ ] Create migration guide from old dotfiles
- [ ] Add rollback functionality in installer

### Terminal Multiplexer
- [ ] Investigate tmux alternatives (zellij, byobu)
- [ ] Add tmux plugin manager (TPM) configuration
- [ ] Create session management scripts
- [ ] Add tmux status bar with system information
- [ ] Create project-based tmux sessions

### Security
- [ ] Add SSH key management helpers
- [ ] Create GPG key generation wizard
- [ ] Add hardware security key (YubiKey) setup guide
- [ ] Implement secure password generation utilities
- [ ] Add 2FA setup documentation

## Low Priority

### Quality of Life
- [ ] Add colored man pages configuration
- [ ] Create directory bookmarks system (z, autojump alternative)
- [ ] Add clipboard manager integration
- [ ] Create custom fzf keybindings for common tasks
- [ ] Add weather information to prompt

### Performance
- [ ] Profile ZSH startup time and optimize slow plugins
- [ ] Lazy-load heavy commands (kubectl, aws, etc.)
- [ ] Add compilation of ZSH configs for faster loading
- [ ] Optimize vim plugin loading times
- [ ] Add benchmarking tools for shell startup

### Container Development
- [ ] Add Podman configuration as Docker alternative
- [ ] Create development container configurations
- [ ] Add docker-compose templates for common services
- [ ] Create helper scripts for container management
- [ ] Add Kubernetes context switching utilities

### Cloud and Infrastructure
- [ ] Add Terraform workspace management
- [ ] Create AWS profile switching helpers
- [ ] Add cloud resource listing shortcuts
- [ ] Create infrastructure cost checking utilities
- [ ] Add multi-cloud CLI tool configurations

## Nice to Have

### Aesthetics
- [ ] Create synchronized color scheme across all tools
- [ ] Add nerd font installation and configuration
- [ ] Create custom Ghostty color schemes
- [ ] Add desktop wallpaper management
- [ ] Create GTK/Qt theme matching terminal theme

### Productivity
- [ ] Add time tracking integration (timewarrior, watson)
- [ ] Create task management CLI (taskwarrior)
- [ ] Add note-taking system integration
- [ ] Create pomodoro timer script
- [ ] Add calendar CLI integration

### Experimental
- [ ] Try fish shell as ZSH alternative
- [ ] Experiment with nushell for structured data
- [ ] Add WezTerm configuration as Ghostty alternative
- [ ] Try Helix editor as Neovim alternative
- [ ] Experiment with container-based development

## Ideas for Removal

Consider removing these if not actively used:
- [ ] Review and potentially remove unused ZSH plugins
- [ ] Audit vim plugins and remove unused ones
- [ ] Remove obsolete git aliases
- [ ] Clean up unused helper functions
- [ ] Remove redundant tool configurations

## User Feedback Needed

Before implementing, gather feedback on:
- Preferred plugin manager for ZSH
- Interest in LSP vs traditional completion
- Preference for terminal (Ghostty, Alacritty, WezTerm)
- Need for multi-machine sync solution
- Interest in secrets management

## Contributing

Have an idea? Open an issue or submit a pull request!

Priority guidelines:
- **High**: Improves daily workflow significantly
- **Medium**: Nice to have, used occasionally
- **Low**: Experimental or niche use cases

---

*Last updated: 2026-01-16*

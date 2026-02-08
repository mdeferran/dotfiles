# Future Improvements

Prioritized improvements for the dotfiles repository.

## High Priority

### Terminal and Shell
- [ ] Add starship prompt as modern alternative
- [ ] Add bat configuration (modern cat replacement)
- [ ] Add eza configuration (modern ls replacement)

### Python Workflow (uv integration)
- [ ] Add auto-activation of `.venv` when cd'ing into project directories
- [ ] Create `venv-init` shortcut using uv for quick project setup
- [ ] Add virtualenv indicator to prompt (shows active venv name)

### Multi-Project Management (6-15 repos)
- [ ] Create project bookmark system with `proj-add`, `proj-go` commands
- [ ] Add `rg-all` function to search pattern across all bookmarked projects
- [ ] Add `fzf-proj` to quickly find and open files across all projects
- [ ] Create shortcuts for common searches: `find-todos`, `find-fixmes`, `find-errors`

### Docker Compose Shortcuts
- [ ] Create service name autocomplete for common docker-compose commands
- [ ] Add smart `dcexec <service>` function (defaults to bash/sh)
- [ ] Add `dclogs <service>` with follow by default
- [ ] Add `dcrestart <service>` and `dcup <service>` shortcuts

### AWS Profile Management
- [ ] Add `aws-switch` function with profile selection menu
- [ ] Show current AWS profile in prompt
- [ ] Create aliases for common AWS profiles (dev, staging, prod)

### Tmux Session Persistence
- [ ] Add tmux-resurrect plugin (save/restore sessions across reboots)
- [ ] Configure auto-save every 15 minutes
- [ ] Add keybinding to manually save session state

### Documentation
- [ ] Create INSTALL.md with step-by-step installation guide
- [ ] Document all available functions and aliases
- [ ] Add architecture notes showing how configs interact
- [ ] Document machine-specific overrides (.zsh.local pattern)

### Quality of Life
- [ ] Add colored man pages configuration
- [ ] Lazy-load heavy commands (kubectl, aws) for faster shell startup

## Medium Priority

### SSH and Remote Work
- [ ] Create `ssh-book` system to save frequent connections
- [ ] Add `ssht` function (SSH + attach to tmux session)
- [ ] Add `rsync-to` and `rsync-from` helper functions for file sync
- [ ] Create project-specific sync configurations

### File Navigation
- [ ] Integrate `fzf` with `z` for fuzzy project jumping
- [ ] Add `recent-files` command (fzf recent git changes)
- [ ] Create `quick-edit` to edit recently modified files

### Repository Maintenance
- [ ] Add GitHub Actions for linting dotfiles
- [ ] Add screenshots and examples to README

## Completed ✅

### Terminal and Shell
- [x] Switched from Antigen to Sheldon (faster plugin manager)
- [x] Added server mode detection (disables heavy plugins over SSH)
- [x] Created directory bookmarks system (z.sh)

### Development Tools
- [x] Added delta (git diff pager) configuration

### Editor
- [x] Migrated to lazy.nvim with lockfile support
- [x] Added nerd font installation and configuration

---

**Priority guidelines:**
- **High**: Improves daily workflow, low complexity
- **Medium**: Nice to have, used occasionally

*Last updated: 2026-02-08*

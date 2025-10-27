# Installation Guide

Quick setup guide for the AI Development Toolkit.

## Prerequisites

### Required
- macOS (tested on macOS 12+)
- [Homebrew](https://brew.sh/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- Git
- Zsh (default on macOS)

### Install Required Tools

```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install core dependencies
brew install git gh rbenv

# Install Ruby via rbenv
rbenv install 3.3.0
rbenv global 3.3.0

# Install Rails
gem install rails bundler

# Install Docker Desktop
# Download from: https://www.docker.com/products/docker-desktop/
```

### Recommended Tools

```bash
brew install gitleaks just
```

## Toolkit Installation

### 1. Clone Repository

```bash
cd ~
git clone <your-repo-url> .ai-toolkit
```

### 2. Configure Shell

Add to `~/.zshrc`:

```bash
# AI Development Toolkit
export PATH="$HOME/.ai-toolkit/bin:$PATH"

# Load toolkit functions
source "$HOME/.ai-toolkit/bin/functions.sh"

# Optional: Enable shell completions
source "$HOME/.ai-toolkit/bin/completions.zsh"
```

### 3. Reload Shell

```bash
source ~/.zshrc
```

### 4. Verify Installation

```bash
dev help
```

You should see the usage information for the `dev` command.

## Post-Installation

### Test Basic Commands

```bash
# Check if dev command works
dev help

# Verify shell functions are loaded
type scan_here ai_bootstrap_repo stack_up
```

### Start Development Stack (Optional)

```bash
# Start Postgres + Redis + Mailhog
dev stack up

# Verify services are running
docker ps

# Stop when done
dev stack down
```

### Create Test Rails App

```bash
mkdir -p ~/code/test
cd ~/code/test
dev new rails TestApp
cd TestApp
just test
```

## Troubleshooting

### Command not found: dev

**Issue**: Shell can't find `dev` command

**Solution**:
```bash
# Verify PATH
echo $PATH | grep .ai-toolkit

# If not found, add to ~/.zshrc:
export PATH="$HOME/.ai-toolkit/bin:$PATH"

# Reload
source ~/.zshrc
```

### Shell functions not found

**Issue**: Functions like `scan_here` don't exist

**Solution**:
```bash
# Add to ~/.zshrc:
source "$HOME/.ai-toolkit/bin/functions.sh"

# Reload
source ~/.zshrc
```

### Docker permission errors

**Issue**: Can't connect to Docker daemon

**Solution**:
- Ensure Docker Desktop is running
- On Linux: Add user to docker group
  ```bash
  sudo usermod -aG docker $USER
  # Log out and back in
  ```

### Rails template fails

**Issue**: `rails new` with template fails

**Solution**:
- Verify Ruby version: `ruby -v` (should be 3.3+)
- Verify Rails installed: `rails -v`
- Check template path: `ls ~/.ai-toolkit/rails/ai_rails.rb`
- Try with absolute path:
  ```bash
  rails new TestApp -m "$HOME/.ai-toolkit/rails/ai_rails.rb"
  ```

## Uninstallation

To remove the toolkit:

```bash
# Remove from ~/.zshrc
# Delete these lines:
# export PATH="$HOME/.ai-toolkit/bin:$PATH"
# source "$HOME/.ai-toolkit/bin/functions.sh"
# source "$HOME/.ai-toolkit/bin/completions.zsh"

# Remove directory
rm -rf ~/.ai-toolkit

# Reload shell
source ~/.zshrc
```

## Upgrade

To upgrade to the latest version:

```bash
cd ~/.ai-toolkit
git pull origin main

# Reload shell
source ~/.zshrc
```

## Getting Help

- Check `README.md` for detailed usage
- Run `dev help` for command reference
- Review examples in `README.md`

## Next Steps

After installation, try these workflows:

1. **Create a Rails app**: `dev new rails MyApp`
2. **Review interview code**: `dev sandbox https://github.com/example/repo`
3. **Bootstrap existing project**: `cd myproject && dev bootstrap`
4. **Start planning**: `dev plan "New Feature"`

Happy coding! 🚀


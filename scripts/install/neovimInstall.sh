#!/usr/bin/env bash

set -euo pipefail

required_formulae=(
	neovim
	ripgrep
	fd
	fzf
	zoxide
	cmake
)

resolve_brew_bin() {
	if command -v brew >/dev/null 2>&1; then
		command -v brew
		return 0
	fi

	for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
		if [[ -x "$candidate" ]]; then
			echo "$candidate"
			return 0
		fi
	done

	echo "Homebrew not found. Please run the Homebrew install script first." >&2
	return 1
}

load_brew_env() {
	local brew_bin
	brew_bin="$(resolve_brew_bin)"
	eval "$("$brew_bin" shellenv)"
}

load_nvm_if_available() {
	export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

	if [[ -s "$NVM_DIR/nvm.sh" ]]; then
		# shellcheck disable=SC1090
		. "$NVM_DIR/nvm.sh"
		return 0
	fi

	return 1
}

install_formulae_if_needed() {
	local formula
	local missing_formulae=()

	for formula in "${required_formulae[@]}"; do
		if brew list --versions "$formula" >/dev/null 2>&1; then
			echo "Already installed: $formula"
			continue
		fi

		missing_formulae+=("$formula")
	done

	if [[ "${#missing_formulae[@]}" -eq 0 ]]; then
		echo "All Neovim-related Homebrew dependencies are already installed"
		return 0
	fi

	echo "Installing formulae: ${missing_formulae[*]}"
	brew install "${missing_formulae[@]}"
}

ensure_npm_available() {
	if command -v npm >/dev/null 2>&1; then
		return 0
	fi

	load_nvm_if_available || true

	if command -v npm >/dev/null 2>&1; then
		return 0
	fi

	if command -v nvm >/dev/null 2>&1; then
		echo "Installing Node.js LTS via nvm..."
		nvm install --lts
		nvm use --lts >/dev/null
	fi

	if command -v npm >/dev/null 2>&1; then
		return 0
	fi

	echo "npm not found. Please install Node.js with nvm first." >&2
	return 1
}

install_tree_sitter_cli_if_needed() {
	if command -v tree-sitter >/dev/null 2>&1; then
		echo "Already installed: tree-sitter-cli ($(tree-sitter --version))"
		return 0
	fi

	ensure_npm_available

	echo "Installing tree-sitter-cli via npm..."
	npm install -g tree-sitter-cli
}

main() {
	load_brew_env
	install_formulae_if_needed
	install_tree_sitter_cli_if_needed
	echo "Neovim is ready: $(nvim --version | head -n 1)"
	echo "Installed/checked brew dependencies: ${required_formulae[*]}"
	echo "Installed/checked npm dependencies: tree-sitter-cli"
}

main "$@"

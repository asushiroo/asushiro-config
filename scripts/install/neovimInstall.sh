#!/usr/bin/env bash

set -euo pipefail

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

install_neovim_if_needed() {
	if command -v nvim >/dev/null 2>&1; then
		echo "Neovim is already installed: $(command -v nvim)"
		return 0
	fi

	if brew list --formula neovim >/dev/null 2>&1; then
		echo "Neovim formula already exists in Homebrew"
		return 0
	fi

	echo "Installing Neovim via Homebrew..."
	brew install neovim
}

main() {
	load_brew_env
	install_neovim_if_needed
	echo "Neovim is ready: $(nvim --version | head -n 1)"
}

main "$@"

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
install_starship_if_needed() {
	if brew list --versions starship >/dev/null 2>&1; then
		echo "Starship is already installed"
		return 0
	fi

	echo "Installing Starship via Homebrew..."
	brew install starship
}

main() {
	load_brew_env
	install_starship_if_needed

	echo "Starship is ready: $(starship --version)"
}

main "$@"

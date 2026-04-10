#!/usr/bin/env bash

set -euo pipefail

export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
export HOMEBREW_PIP_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple"

mirror_env_lines=(
	'export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"'
	'export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"'
	'export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"'
	'export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"'
	'export HOMEBREW_PIP_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple"'
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

	return 1
}

default_brew_bin() {
	if [[ "$(uname -s)" == "Darwin" ]]; then
		if [[ "$(uname -m)" == "arm64" ]]; then
			echo "/opt/homebrew/bin/brew"
		else
			echo "/usr/local/bin/brew"
		fi
		return 0
	fi

	echo "/home/linuxbrew/.linuxbrew/bin/brew"
}

install_homebrew_if_needed() {
	if resolve_brew_bin >/dev/null 2>&1; then
		echo "Homebrew is already installed"
		return 0
	fi

	echo "Homebrew not found, starting installation..."
	NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

load_brew_into_current_shell() {
	local brew_bin
	if brew_bin="$(resolve_brew_bin)"; then
		:
	else
		brew_bin="$(default_brew_bin)"
	fi
	eval "$("$brew_bin" shellenv)"
}

main() {
	install_homebrew_if_needed
	load_brew_into_current_shell

	echo "Homebrew is ready: $(brew --version | head -n 1)"
	echo "Mirror environment variables used in this install run:"
	printf '  %s\n' "${mirror_env_lines[@]}"
}

main "$@"

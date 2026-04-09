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

detect_platform_and_rc_file() {
	local os_name
	os_name="$(uname -s)"

	if [[ "$os_name" == "Darwin" ]]; then
		echo "macos:$HOME/.zshrc"
		return 0
	fi

	if [[ "$os_name" == "Linux" ]] && [[ -r /etc/os-release ]]; then
		# shellcheck disable=SC1091
		. /etc/os-release

		if [[ "${ID:-}" == "ubuntu" ]] || [[ "${ID_LIKE:-}" == *ubuntu* ]]; then
			echo "ubuntu:$HOME/.bashrc"
			return 0
		fi
	fi

	echo "Unsupported system: $os_name" >&2
	return 1
}

append_line_if_missing() {
	local file="$1"
	local line="$2"

	if grep -Fqx "$line" "$file" 2>/dev/null; then
		return 1
	fi

	printf '%s\n' "$line" >>"$file"
	return 0
}

ensure_mirror_env_in_rc() {
	local line
	local var_name
	local added=false

	for line in "${mirror_env_lines[@]}"; do
		var_name="${line#export }"
		var_name="${var_name%%=*}"

		if grep -Eq "^[[:space:]]*export[[:space:]]+${var_name}=" "$rc_file" 2>/dev/null; then
			continue
		fi

		printf '%s\n' "$line" >>"$rc_file"
		added=true
	done

	if [[ "$added" == true ]]; then
		echo "Homebrew mirror environment variables appended to $rc_file"
	else
		echo "Homebrew mirror environment variables already exist in $rc_file"
	fi
}

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
	if [[ "$platform" == "macos" ]]; then
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

ensure_brew_shellenv_in_rc() {
	local brew_bin
	local shellenv_line

	if grep -Fq "brew shellenv" "$rc_file" 2>/dev/null; then
		echo "brew shellenv already exists in $rc_file"
		return 0
	fi

	if brew_bin="$(resolve_brew_bin)"; then
		:
	else
		brew_bin="$(default_brew_bin)"
	fi

	shellenv_line="eval \"\$(${brew_bin} shellenv)\""
	append_line_if_missing "$rc_file" "$shellenv_line" >/dev/null || true
	echo "brew shellenv appended to $rc_file"
}

load_brew_into_current_shell() {
	local brew_bin
	brew_bin="$(resolve_brew_bin)"
	eval "$("$brew_bin" shellenv)"
}

main() {
	local platform_and_rc

	platform_and_rc="$(detect_platform_and_rc_file)"
	platform="${platform_and_rc%%:*}"
	rc_file="${platform_and_rc#*:}"

	touch "$rc_file"

	ensure_mirror_env_in_rc
	install_homebrew_if_needed
	ensure_brew_shellenv_in_rc
	load_brew_into_current_shell

	echo "Homebrew is ready: $(brew --version | head -n 1)"
	echo "Shell profile configured: $rc_file"
}

main "$@"

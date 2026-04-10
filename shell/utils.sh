cdf() {
	if [[ "$1" == "-i" ]]; then
		local dir
		dir=$(fd -t d . . --exclude .git | fzf --preview 'ls -la {}') && cd "$dir"
		return
	fi

	if [[ -z "$1" ]]; then
		echo "Usage: cdf <pattern>  或  cdf -i"
		return 1
	fi

	local pattern="$1"
	local dir=""

	for depth in $(seq 1 15); do
		dir=$(fd -t d -i --max-depth "$depth" --exclude .git "$pattern" . | head -n 1)
		if [[ -n "$dir" ]]; then
			cd "$dir"
			return
		fi
	done

	echo "No directory found matching: $pattern"
}

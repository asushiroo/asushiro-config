# bash的初始化shell
# starship初始化
case $- in
*i*)
	[ "$TERM" != "dumb" ] && eval "$(starship init bash)"
	;;
esac
# zoxide初始化
eval "$(zoxide init bash)"

# yazi初始化
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd <"$tmp" || true
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

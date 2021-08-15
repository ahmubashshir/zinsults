#!/bin/zsh
0=${(%):-%N}
__zinsult_msgfile="${0:A:h}/msgs.zsh"
if
	[[ -w ${__zinsult_msgfile:P:h} ]] \
	&& [[
		-s "${__zinsult_msgfile}" \
		&& (
			! -s "${__zinsult_msgfile}.zwc" \
			|| "${__zinsult_msgfile}" -nt "${__zinsult_msgfile}.zwc"
		)
	]]
then
	builtin zcompile -Mz "${__zinsult_msgfile}"
fi
if ! ((${+functions[command_not_found_handler]})); then
	function command_not_found_handler {
		printf 'zsh: command not found: %s\n' "$1" >&2
	}
fi
if ! ((${+functions[__zinsult_try_find_command]}));then
	functions -c command_not_found_handler __zinsult_try_find_command
fi
if (( ! ${+zinsults_load} )); then
	typeset -ga zinsults_load
fi

function command_not_found_handler {
	local -a msgs
	local idx
	setopt localoptions noksharrays
	if ! ((${+CMD_NOT_FOUND_MSGS}));then
		source "${__zinsult_msgfile}"
	else
		msgs=( "${CMD_NOT_FOUND_MSGS[@]}" )
	fi
	if (($#msgs>0));then
		RANDOM=$(od -vAn -N4 -tu < /dev/urandom)
		builtin print -P -f 'zsh: %s\n' "$msgs[RANDOM % $#msgs + 1]"
		unset msgs
	fi
	__zinsult_try_find_command "$@"
}

# vim: ft=zsh ts=4 noet

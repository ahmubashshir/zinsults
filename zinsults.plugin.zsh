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
if (( ! ${+zinsults_load} ))
then typeset -ga zinsults_load
fi

# zsh segfaults on 'functions -c src dest' because of an incorrect null check & copy
# in functions builtin for sticky shell emulation
# Details: http://ix.io/3ZMR/irc - 2022-06-09 - irc://libera.chat/#zsh
# Fixed in zsh-5.9-20-gd4955bc0f
if ((${+functions[command_not_found_handler]}))
then () {
	setopt localoptions extendedglob noksharrays
	local -a match
	local -i 10 major minor patch
	local -li 16 rev
	local -F 3 version
	[[ $ZSH_PATCHLEVEL = (#b)zsh-(*).(*)-(*)-g(*) ]] && ((
		major = match[1],
		minor = match[2],
		patch = match[3],
		rev   = 16#${match[4]},
		version = ${match[1]}.${match[2]}
	))
	declare -r major minor patchrev version
	if (("$1"))
	then builtin functions -c "$2" "$3"
	else builtin declare -g "functions[$3]=$functions[$2]"
	fi
} \
		'version > 5.9 || version == 5.9 && (patch >= 20 || rev == 16#d4955bc)' \
		command_not_found_handler \
		__zinsult_try_find_command
fi

function command_not_found_handler {
	if [[ ! -t 1 ]]
	then return # Return if stdout is a pipe, not tty
	fi

	local -a msgs
	local idx
	setopt localoptions noksharrays
	if ! ((${+CMD_NOT_FOUND_MSGS}))
	then source "${__zinsult_msgfile}"
	else msgs=( "${CMD_NOT_FOUND_MSGS[@]}" )
	fi

	if (($#msgs>0));then
		RANDOM=$(od -vAn -N4 -tu < /dev/urandom)
		builtin print -P -f 'zsh: %s\n' "$msgs[RANDOM % $#msgs + 1]"
		unset msgs
	fi
	if ((${+functions[__zinsult_try_find_command]}))
	then __zinsult_try_find_command "$@"
	else builtin print -P -f 'zsh: command not found: %s\n' "$1"
	fi
}
# vim: ft=zsh ts=4 noet

#
# KSH options
#

HISTFILE=$HOME/.config/ksh/history
HISTSIZE=5000

set -o ignoreeof
set -o vi
set -o vi-tabcomplete

#
# Disable ^S
#

stty -ixon

#
# Colors.
#

. $HOME/.config/base16-shell/scripts/base16-eighties.sh

#
# Environment
#

function add_path {
  [ -e $1 ] && export PATH="$1/bin:$PATH"
}

add_path "$HOME/.local"
add_path "$HOME/.local/python"
add_path "$HOME/.cargo"

add_path "/opt/homebrew"
add_path "/opt/homebrew/opt/llvm"

[ -e $(which opam) ] && eval $(opam env)

#
# Set the encoding
#

LC_CTYPE="en_US.UTF-8"
export LC_CTYPE

#
# Aliases
#

if [ -e $(which eza) ]
then
  alias ls='eza --color=auto'
  alias ll='eza -l --no-user'
else
  alias ll='ls -ls'
fi

#
# Bat theme
#

export BAT_THEME="base16-256"

#
# SSH agent
#

function start_agent {
  SSH_ENV=$HOME/.ssh/environment;
  ssh-agent > ${SSH_ENV};
  chmod 600 ${SSH_ENV};
  . ${SSH_ENV} > /dev/null;
  #
  # Use the keychain in macOS.
  #
  if [ "$(uname -s)" = "Darwin" ]
  then
    ssh-add --apple-use-keychain $HOME/.ssh/*.rsa
  else
    ssh-add $HOME/.ssh/*.rsa
  fi
}

function selectively_start_agent {
  SSH_ENV=$HOME/.ssh/environment;
  if [ -f ${SSH_ENV} ]; then
    . ${SSH_ENV} > /dev/null
  fi
  AGENT_PID=$(pgrep ssh-agent)
  if [ "x${AGENT_PID}" == "x" ]; then
    start_agent
  fi
}

selectively_start_agent

#
# PS1
#

FG_LGH='\033[0;37m'
FG_DRK='\033[0;90m'
FG_GRN='\033[0;32m'
FG_BLU='\033[0;34m'
FG_CYA='\033[0;36m'
FG_RED='\033[0;31m'
FG_BRN='\033[0;33m'
FG_PUR='\033[0;35m'
FG_CLR='\033[0m'

function set_title {
  if [ -n "${TMUX}" ]; then
    tmux rename-window "$1"
  else
    echo -n "\033]0;[$(hostname)] $1\007"
  fi
}

function truncate_path {
  LEN=${#1}
  if [ ${LEN} -gt 18 ]
  then
    echo "...$(echo ${1} | cut -c $((${LEN} - 16))-${LEN})"
  else
    echo ${1}
  fi
}

function ts_ps1 {
  VALUE=$(date +%H:%M)
  echo "${FG_DRK}${VALUE}${FG_CLR}"
}

function path_ps1 {
  SHORT_PWD=$(echo "${PWD}" | sed "s%${HOME}%~%g")
  TRUNC_PWD=$(truncate_path "${SHORT_PWD}")
  set_title "${TRUNC_PWD}"
}

function git_ps1 {
  BRANCH=$(git branch --no-color 2>&1)
  if [ $? == 0 ]; then
    CLEANED_BRANCH=$(echo "${BRANCH}" | grep \* | tr -d '* ')
    STATUS=$(git status -s -uno)
    COLOR=${FG_GRN}
    [ "x${STATUS}" != "x" ] && COLOR=${FG_RED}
    echo " ${COLOR}${CLEANED_BRANCH}${FG_CLR}"
  else
    echo ""
  fi
}

PS1='$(ts_ps1)$(path_ps1)$(git_ps1) ▶ '
PS2=┃

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

export PATH=$PATH:${HOME}/bin:${HOME}/tempbin

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi


if [ -f ~/conf/aliases ]; then
    . ~/conf/aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

LS_COLORS=$LS_COLORS:'or=5;41;34:di=40;4;31:ow=40;4;32'; export LS_COLORS

# Tweak History for TMUX, give it a useful timestamp, 
HISTTIMEFORMAT="%y-%m-%d %T "

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=2000
HISTFILESIZE=4000

# append to the history file, don't overwrite it
shopt -s histappend

# Important Step here - Ensure that we have Unique History by window 
# Based on the Tmux Window Name
if [ ! -d ${HOME}/.tmux/bash_history ]; then
	mkdir -p ${HOME}/.tmux/bash_history
fi
if [[ $TMUX_PANE ]]; then
   HISTFILE=~/.tmux/bash_history/bash_history.$(tmux display-message -p '#W')
fi
# Make sure we save the prompt history at every step
PROMPT_COMMAND="history -a;history -c;history -r;$PROMPT_COMMAND"

export EDITOR=vi

if [ -f ~/bin/kube-ps1.sh ]; then
	. ~/bin/kube-ps1.sh
fi

alias k=kubectl



# Some hyper useful sightmachine Kubernetes functions.
if [ -f ~/conf/bash_kubecompletion.sh ]; then
	. ~/conf/bash_kubecompletion.sh; 
fi
# Go/Kube Stuff


export HELM_HOME=/home/shephard/.helm.

export GOPATH=${HOME}/gocode
if [ -f ${HOME}/bin/utils.bash ];  then
	source ${HOME}/bin/utils.bash
	kubeon
	source <(kubectl completion bash)
	source <(stern --completion bash)
	source ~/bin/st4
	PS1='\D{%F %T}: ${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(kube_ps1)\e[0;93m$(__git_ps1 " (%s)" )\e[m\n$ '
else
	PS1='\D{%F %T}: ${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\e[m\e[0;93m$(__git_ps1 " (%s)" )\e[m\n$ '
fi
# VirtualEnvWrappers are awesome for python
if [ -f /usr/local/bin/virtualenvwrapper.sh ]; then
	if [ -f /usr/bin/python3.6 ]; then
		export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3.6
	elif [ -f /usr/bin/python3.7 ]; then
		export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3.7
>>>>>>> 4ffdf3b397caf9a2024d635fd630d03b35cf37b4
	elif [ -f /usr/bin/python ]; then
		export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python
	fi
	source /usr/local/bin/virtualenvwrapper.sh
	export WORKON_HOME=~/.virtualenvs
fi

if [ -x /usr/bin/ssh-agent ] ; then
   eval `/usr/bin/ssh-agent`
fi

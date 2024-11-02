# git version control info
autoload -Uz vcs_info
precmd() { vcs_info }

# Format the vcs_info_msg_0_ variable

# Set up the prompt (with git branch name)
# Enable colors and change prompt:
autoload -U colors && colors
setopt PROMPT_SUBST

## this displays a user, dependent on whether the user is in a ssh session or not
if [[ "$USER" == "$DEFAULT_USER" && -z "$SSH_CLIENT" ]]; then
  zstyle ':vcs_info:git:*' formats "%F{yellow}(%f%F{green}%b%f%F{yellow}%f%F{yellow})%f "
  PS1='%B%{$fg[red]%}[${vcs_info_msg_0_}%{$fg[cyan]%}%3~%{$fg[red]%}]%{$reset_color%}$%b '
elif [[ -z "$SSH_CLIENT" ]]; then
  zstyle ':vcs_info:git:*' formats "%F{yellow}(%f%F{magenta}%b%f%F{yellow})%f "
  PS1='%B%{$fg[red]%}[%{$fg[green]%}%n ${vcs_info_msg_0_}%{$fg[cyan]%}%3~%{$fg[red]%}]%{$reset_color%}$%b '
else
  zstyle ':vcs_info:git:*' formats "%F{yellow}(%f%F{magenta}%b%f%F{yellow})%f "
  PS1='%B%{$fg[red]%}[%{$fg[green]%}%n%{$fg[magenta]%}@%{$fg[yellow]%}%M ${vcs_info_msg_0_}%{$fg[cyan]%}%3~%{$fg[red]%}]%{$reset_color%}$%b '
fi

setopt autocd
setopt interactive_comments

# History in cache directory:
HISTFILE=~/.local/share/zsh/history
HISTSIZE=1000
SAVEHIST=1000

# vi mode
bindkey -v
export KEYTIMEOUT=1

# enable backward histsearch
bindkey '^R' history-incremental-pattern-search-backward

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)                     # Include hidden files.

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

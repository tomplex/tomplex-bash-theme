# tomplex.theme.bash 
# Heavily inspired by this StackOverflow answer:
# https://stackoverflow.com/a/34812608/4453925
# Changes were mostly to colors, plus added support for Python virtualenv names

# Colors
Blue='\[\e[01;34m\]'
White='\[\e[01;37m\]'
Red='\[\e[01;31m\]'
Green='\[\e[01;32m\]'
Reset='\[\e[00m\]'
FancyX='\342\234\227'
Checkmark='\342\234\223'
Arrow='➙'

function timer_now {
    date +%s%N
}

function timer_start {
    timer_start=${timer_start:-$(timer_now)}
}

function timer_stop {
    local delta_us=$((($(timer_now) - $timer_start) / 1000))
    local us=$((delta_us % 1000))
    local ms=$(((delta_us / 1000) % 1000))
    local s=$(((delta_us / 1000000) % 60))
    local m=$(((delta_us / 60000000) % 60))
    local h=$((delta_us / 3600000000))
    # Goal: always show around 3 digits of accuracy
    if ((h > 0)); then timer_show=${h}h${m}m
    elif ((m > 0)); then timer_show=${m}m${s}s
    elif ((s >= 10)); then timer_show=${s}.$((ms / 100))s
    elif ((s > 0)); then timer_show=${s}.$(printf %03d $ms)s
    elif ((ms >= 100)); then timer_show=${ms}ms
    elif ((ms > 0)); then timer_show=${ms}.$((us / 100))ms
    else timer_show=${us}us
    fi
    unset timer_start
}

__check_virtualenv() {
    [[ -n $VIRTUAL_ENV ]] && printf "$White py:($Red$(basename $VIRTUAL_ENV)$White)"
}

__check_git() {
    [[ -n $(__git_ps1) ]] && printf "$White git:($Red$(__git_ps1 '%s')$White)"
}

__git_dirty() {
    ( [[ $(git diff --shortstat 2> /dev/null | tail -n1) != "" ]] && printf " $Red$FancyX" ) || ( [[ -n $(__git_ps1) ]] && printf " $Green$Checkmark" ) 
}

set_prompt () {
    Last_Command=$? # Must come first!

    # Add a bright white exit status for the last command
    PS1="$White\$? "
    # If it was successful, print a green check mark. Otherwise, print
    # a red X.
    if [[ $Last_Command == 0 ]]; then
        PS1+="$Green$Checkmark "
    else
        PS1+="$Red$FancyX "
    fi

    # Add the elapsed time and current date
    timer_stop
    PS1+="($timer_show) $White\t "
    
    PS1+="$Red\\u$White@\\h " 
     
    # add working directory
    PS1+="$Blue\\w"

    # check for a virtualenv
    PS1+="$Green$(__check_virtualenv)"

    # check for a git repository / branch
    PS1+="$(__check_git)$(__git_dirty)\n"
    PS1+="$Blue$Arrow $Reset"
}

trap 'timer_start' DEBUG
safe_append_prompt_command set_prompt

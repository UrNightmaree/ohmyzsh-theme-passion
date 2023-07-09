
# gdate for macOS
# REF: https://apple.stackexchange.com/questions/135742/time-in-milliseconds-since-epoch-in-the-terminal
if [[ "$OSTYPE" == "darwin"* ]]; then
    {
        gdate
    } || {
        echo -e "\n\e[1;33mpassion.zsh-theme depends on cmd [gdate] to get current time in milliseconds\e[0m"
        echo -e "\e[1;33m[gdate] is not installed by default in macOS\e[0m"
        echo -e "\e[1;33mto get [gdate] by running:\e[0m"
        echo -e "\e[1;32mbrew install coreutils;\e[0m";
        echo -e "\e[1;33m\nREF: https://github.com/ChesterYue/ohmyzsh-theme-passion#macos\n\e[0m"
    }
fi


# time
function real_time() {
    local color="\e[0;36m";                    # color in PROMPT need format in XXX which is not same with echo -e
    local time="[$(date +%H:%M:%S)]";
    local color_reset="\e\e[0m";
    echo -e -e "${color}${time}${color_reset}";
}

# login_info
function login_info() {
    local color="\e[0;36m";                    # color in PROMPT need format in XXX which is not same with echo -e
    local ip
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        # Linux
        ip="$(ifconfig | grep ^eth1 -A 1 | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | head -1)";
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        ip="$(ifconfig | grep ^en1 -A 4 | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | head -1)";
    elif [[ "$OSTYPE" == "cygwin" ]]; then
        # POSIX compatibility layer and Linux environment emulation for Windows
    elif [[ "$OSTYPE" == "msys" ]]; then
        # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
    elif [[ "$OSTYPE" == "win32" ]]; then
        # I'm not sure this can happen.
    elif [[ "$OSTYPE" == "freebsd"* ]]; then
        # ...
    else
        # Unknown.
    fi
    local color_reset="\e\e[0m";
    echo -e -e "${color}[%n@${ip}]${color_reset}";
}


# directory
function directory() {
    local color="\e[0;36m";
    # REF: https://stackoverflow.com/questions/25944006/bash-current-working-directory-with-replacing-path-to-home-folder
    local directory="${PWD/#$HOME/~}";
    local color_reset="\e\e[0m";
    echo -e -e "${color}[${directory}]${color_reset}";
}


# git
ZSH_THEME_GIT_PROMPT_PREFIX="\e[0;36m[";
ZSH_THEME_GIT_PROMPT_SUFFIX="\e\e[0m ";
ZSH_THEME_GIT_PROMPT_DIRTY=" \e[0;31m✖\e[0;36m]";
ZSH_THEME_GIT_PROMPT_CLEAN="\e[0;36m]";

function update_git_status() {
    GIT_STATUS=$(git_prompt_info);
}

function git_status() {
    echo -e "${GIT_STATUS}"
}


# command
function update_command_status() {
    local arrow="";
    local color_reset="\e[0m";
    local reset_font="\e[";
    COMMAND_RESULT=$1;
    export COMMAND_RESULT=$COMMAND_RESULT
    if $COMMAND_RESULT;
    then
        arrow="\e[1;31m%}❱\e[1;33m❱%{\e[1;32m❱";
    else
        arrow="\e[1;31m❱❱❱";
    fi
    COMMAND_STATUS="${arrow}${reset_font}${color_reset}";
}
update_command_status true;

function command_status() {
    echo -e "${COMMAND_STATUS}"
}


# output command execute after
output_command_execute_after() {
    if [ "$COMMAND_TIME_BEGIN" = "-20200325" ] || [ "$COMMAND_TIME_BEGIN" = "" ];
    then
        return 1;
    fi

    # cmd
    local cmd="$(fc -ln -1)";
    local color_cmd="";
    if $1;
    then
        color_cmd="\e[0;32m";
    else
        color_cmd="\e[1;31m";
    fi
    local color_reset="\e[0m";
    cmd="${color_cmd}${cmd}${color_reset}"

    # time
    local time="[$(date +%H:%M:%S)]"
    local color_time="\e[0;36m";
    time="${color_time}${time}${color_reset}";

    # cost
    local time_end="$(current_time_millis)";
    local cost=$(bc -l <<<"${time_end}-${COMMAND_TIME_BEGIN}");
    COMMAND_TIME_BEGIN="-20200325"
    local length_cost=${#cost};
    if [ "$length_cost" = "4" ];
    then
        cost="0${cost}"
    fi
    cost="[cost ${cost}s]"
    local color_cost="\e[0;36m";
    cost="${color_cost}${cost}${color_reset}";

    echo -e -e "${time} ${cost} ${cmd}";
    echo -e -e "";
}


# command execute before
# REF: http://zsh.sourceforge.net/Doc/Release/Functions.html
preexec() { # cspell:disable-line
    COMMAND_TIME_BEGIN="$(current_time_millis)";
}

current_time_millis() {
    local time_millis;
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        # Linux
        time_millis="$(date +%s.%3N)";
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        time_millis="$(gdate +%s.%3N)";
    elif [[ "$OSTYPE" == "cygwin" ]]; then
        # POSIX compatibility layer and Linux environment emulation for Windows
    elif [[ "$OSTYPE" == "msys" ]]; then
        # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
    elif [[ "$OSTYPE" == "win32" ]]; then
        # I'm not sure this can happen.
    elif [[ "$OSTYPE" == "freebsd"* ]]; then
        # ...
    else
        # Unknown.
    fi
    echo -e $time_millis;
}


# command execute after
# REF: http://zsh.sourceforge.net/Doc/Release/Functions.html
precmd() { # cspell:disable-line
    # last_cmd
    local last_cmd_return_code=$?;
    local last_cmd_result=true;
    if [ "$last_cmd_return_code" = "0" ];
    then
        last_cmd_result=true;
    else
        last_cmd_result=false;
    fi

    # update_git_status
    update_git_status;

    # update_command_status
    update_command_status $last_cmd_result;

    # output command execute after
    output_command_execute_after $last_cmd_result;
}


# set option
setopt PROMPT_SUBST; # cspell:disable-line


# timer
#REF: https://stackoverflow.com/questions/26526175/zsh-menu-completion-causes-problems-after-zle-reset-prompt
TMOUT=1;
TRAPALRM() { # cspell:disable-line
    # $(git_prompt_info) cost too much time which will raise stutters when inputting. so we need to disable it in this occurrence.
    # if [ "$WIDGET" != "expand-or-complete" ] && [ "$WIDGET" != "self-insert" ] && [ "$WIDGET" != "backward-delete-char" ]; then
    # black list will not enum it completely. even some pipe broken will appear.
    # so we just put a white list here.
    if [ "$WIDGET" = "" ] || [ "$WIDGET" = "accept-line" ] ; then
        zle reset-prompt;
    fi
}


# prompt
# PROMPT='$(real_time) $(login_info) $(directory) $(git_status)$(command_status) ';
PROMPT='$(real_time) $(directory) $(git_status)$(command_status) ';

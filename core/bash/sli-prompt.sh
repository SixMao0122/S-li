#!/usr/bin/env bash
# S-li Prompt Engine for Git Bash (MSYS2 / MinGW) & Linux WSL
# Designed for Six Life Injoy / Shell Line Interface

_sli_get_git_info() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    if [ -z "$branch" ]; then
        branch=$(git rev-parse --short HEAD 2>/dev/null)
    fi
    if [ -z "$branch" ]; then
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            branch="master"
        else
            return 1 # Not in a git repository
        fi
    fi

    # 輸出分支名稱
    printf "%s" "$branch"

    # 以 exit code 回傳 clean(0) 或 dirty(2)
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        return 2
    else
        return 0
    fi
}

_sli_render_prompt() {
    local esc=$'\033'
    local reset="\[${esc}[0m\]"

    # 主題色彩 (Sunset Theme RGB)
    local user_bg="123;44;191"
    local user_fg="255;255;255"

    local path_bg="217;70;118"
    local path_fg="255;255;255"

    local git_clean_bg="240;138;93"
    local git_dirty_bg="226;109;92"
    local git_fg="255;255;255"

    local time_bg="67;133;190"
    local time_fg="255;255;255"

    # Powerline 符號
    local sep=$'\ue0b0'
    local heart="♡"

    # 1. User
    local username="${SLI_USER:-$USER}"
    if [ -z "$username" ]; then
        username="${USERNAME:-user}"
    fi

    # 2. Path & Python Venv
    local venv_text=""
    if [ -n "$VIRTUAL_ENV" ]; then
        local vname
        vname=$(basename "$VIRTUAL_ENV")
        venv_text="🐍 ($vname) "
    elif [ -n "$CONDA_DEFAULT_ENV" ]; then
        venv_text="🐍 ($CONDA_DEFAULT_ENV) "
    fi

    local cur_dir
    if [ "$PWD" = "$HOME" ]; then
        cur_dir="~"
    else
        cur_dir=$(basename "$PWD")
    fi
    local path_text="${venv_text}${cur_dir}"

    # 3. Git Status
    local git_branch
    git_branch=$(_sli_get_git_info)
    local git_code=$?
    local has_git=0
    local git_text=""
    local git_bg="$git_clean_bg"

    if [ $git_code -eq 0 ]; then
        has_git=1
        git_text="→ ($git_branch)"
        git_bg="$git_clean_bg"
    elif [ $git_code -eq 2 ]; then
        has_git=1
        git_text="* → ($git_branch)"
        git_bg="$git_dirty_bg"
    fi

    # 4. Time
    local time_str
    time_str=$(date +%H:%M)
    local time_text="$heart $time_str"

    # 組合 PS1 (以 \[ \] 包覆純 ANSI 控制碼以確保游標長度計算正確)
    local p=""

    # Segment 1: User
    p+="\[${esc}[48;2;${user_bg}m${esc}[38;2;${user_fg}m\] ${username} "

    # Arrow 1 -> 2
    p+="\[${esc}[48;2;${path_bg}m${esc}[38;2;${user_bg}m\]${sep}"

    # Segment 2: Path
    p+="\[${esc}[48;2;${path_bg}m${esc}[38;2;${path_fg}m\] ${path_text} "

    if [ $has_git -eq 1 ]; then
        # Arrow 2 -> 3
        p+="\[${esc}[48;2;${git_bg}m${esc}[38;2;${path_bg}m\]${sep}"
        # Segment 3: Git
        p+="\[${esc}[48;2;${git_bg}m${esc}[38;2;${git_fg}m\] ${git_text} "
        # Arrow 3 -> 4
        p+="\[${esc}[48;2;${time_bg}m${esc}[38;2;${git_bg}m\]${sep}"
    else
        # Arrow 2 -> 4
        p+="\[${esc}[48;2;${time_bg}m${esc}[38;2;${path_bg}m\]${sep}"
    fi

    # Segment 4: Time
    p+="\[${esc}[48;2;${time_bg}m${esc}[38;2;${time_fg}m\] ${time_text} "

    # Closing Arrow
    p+="${reset}\[${esc}[38;2;${time_bg}m\]${sep}${reset} "

    PS1="$p"
}

PROMPT_COMMAND="_sli_render_prompt"

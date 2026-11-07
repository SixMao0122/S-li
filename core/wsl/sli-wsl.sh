#!/usr/bin/env bash
# S-li Prompt Engine for Linux WSL (Bash & Zsh)
# Designed for Six Life Injoy / Shell Line Interface

_sli_wsl_git_info() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 1

    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    if [ -z "$branch" ]; then
        branch=$(git rev-parse --short HEAD 2>/dev/null)
    fi
    if [ -z "$branch" ]; then
        branch=$(git config init.defaultBranch 2>/dev/null || echo "main")
    fi

    printf "%s" "$branch"

    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        return 2
    else
        return 0
    fi
}

_sli_wsl_render_prompt() {
    local esc=$'\033'
    local is_zsh=0
    [ -n "$ZSH_VERSION" ] && is_zsh=1

    local open_nonprint="\["
    local close_nonprint="\]"
    if [ $is_zsh -eq 1 ]; then
        open_nonprint="%{"
        close_nonprint="%}"
    fi

    local reset="${open_nonprint}${esc}[0m${close_nonprint}"

    # Sunset RGB
    local user_bg="123;44;191"
    local user_fg="255;255;255"

    local path_bg="217;70;118"
    local path_fg="255;255;255"

    local git_clean_bg="240;138;93"
    local git_dirty_bg="226;109;92"
    local git_fg="255;255;255"

    local time_bg="67;133;190"
    local time_fg="255;255;255"

    local sep=$'\ue0b0'
    local heart="♡"

    # User
    local username="${SLI_USER:-$USER}"
    if [ -z "$username" ]; then
        username="wsl"
    fi

    # Path & Venv
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

    # Git
    local git_branch
    git_branch=$(_sli_wsl_git_info)
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

    # Time
    local time_str
    time_str=$(date +%H:%M)
    local time_text="$heart $time_str"

    local p=""
    p+="${open_nonprint}${esc}[48;2;${user_bg}m${esc}[38;2;${user_fg}m${close_nonprint} ${username} "
    p+="${open_nonprint}${esc}[48;2;${path_bg}m${esc}[38;2;${user_bg}m${close_nonprint}${sep}"
    p+="${open_nonprint}${esc}[48;2;${path_bg}m${esc}[38;2;${path_fg}m${close_nonprint} ${path_text} "

    if [ $has_git -eq 1 ]; then
        p+="${open_nonprint}${esc}[48;2;${git_bg}m${esc}[38;2;${path_bg}m${close_nonprint}${sep}"
        p+="${open_nonprint}${esc}[48;2;${git_bg}m${esc}[38;2;${git_fg}m${close_nonprint} ${git_text} "
        p+="${open_nonprint}${esc}[48;2;${time_bg}m${esc}[38;2;${git_bg}m${close_nonprint}${sep}"
    else
        p+="${open_nonprint}${esc}[48;2;${time_bg}m${esc}[38;2;${path_bg}m${close_nonprint}${sep}"
    fi

    p+="${open_nonprint}${esc}[48;2;${time_bg}m${esc}[38;2;${time_fg}m${close_nonprint} ${time_text} "
    p+="${reset}${open_nonprint}${esc}[38;2;${time_bg}m${close_nonprint}${sep}${reset} "

    if [ $is_zsh -eq 1 ]; then
        PROMPT="$p"
    else
        PS1="$p"
    fi
}

if [ -n "$ZSH_VERSION" ]; then
    precmd_functions+=(_sli_wsl_render_prompt)
else
    PROMPT_COMMAND="_sli_wsl_render_prompt"
fi

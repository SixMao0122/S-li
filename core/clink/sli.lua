-- S-li Prompt Module for Windows CMD (via Clink)
-- Designed for Shell Line Interface

local function run_cmd(cmd, mode)
    local pipe = io.popen(cmd)
    if not pipe then return nil end
    local res = pipe:read(mode or "*l")
    pipe:close()
    return res
end

local function get_git_info()
    local git_dir = run_cmd("git rev-parse --is-inside-work-tree 2>nul", "*a")
    if not git_dir or not git_dir:find("true") then
        return nil
    end

    local branch = run_cmd("git symbolic-ref --short HEAD 2>nul", "*l")
    if not branch or branch == "" then
        branch = run_cmd("git rev-parse --short HEAD 2>nul", "*l")
    end
    if not branch or branch == "" then
        branch = "main"
    end

    local status = run_cmd("git status --porcelain 2>nul", "*a")
    local is_dirty = (status and #status > 0)

    return {
        branch = branch,
        is_dirty = is_dirty
    }
end

local function get_venv_info()
    local venv = os.getenv("VIRTUAL_ENV")
    if venv and venv ~= "" then
        local name = venv:match("([^/\\]+)$")
        return "🐍 (" .. (name or "venv") .. ") "
    end
    local conda = os.getenv("CONDA_DEFAULT_ENV")
    if conda and conda ~= "" then
        return "🐍 (" .. conda .. ") "
    end
    return ""
end

local function sli_prompt_filter()
    local esc = "\x1b"
    local reset = esc .. "[0m"
    local sep = "\xee\x82\xb0" -- \ue0b0
    local heart = "♡"

    -- RGB 顏色定義 (Sunset Theme)
    local user_bg = "123;44;191"
    local user_fg = "255;255;255"

    local path_bg = "217;70;118"
    local path_fg = "255;255;255"

    local git_clean_bg = "240;138;93"
    local git_dirty_bg = "226;109;92"
    local git_fg = "255;255;255"

    local time_bg = "67;133;190"
    local time_fg = "255;255;255"

    -- Segment 1: User
    local username = os.getenv("USERNAME") or "user"

    -- Segment 2: Path & Venv
    local venv_text = get_venv_info()
    local cwd = os.getcwd()
    local folder = cwd:match("([^/\\]+)$") or cwd
    local path_text = venv_text .. folder

    -- Segment 3: Git
    local git_info = get_git_info()

    -- Segment 4: Time
    local time_text = heart .. " " .. os.date("%H:%M")

    local prompt = ""

    -- User Segment
    prompt = prompt .. esc .. "[48;2;" .. user_bg .. "m" .. esc .. "[38;2;" .. user_fg .. "m " .. username .. " "

    -- Arrow 1 -> 2
    prompt = prompt .. esc .. "[48;2;" .. path_bg .. "m" .. esc .. "[38;2;" .. user_bg .. "m" .. sep

    -- Path Segment
    prompt = prompt .. esc .. "[48;2;" .. path_bg .. "m" .. esc .. "[38;2;" .. path_fg .. "m " .. path_text .. " "

    if git_info then
        local git_bg = git_info.is_dirty and git_dirty_bg or git_clean_bg
        local git_marker = git_info.is_dirty and "* →" or "→"
        local git_text = git_marker .. " (" .. git_info.branch .. ")"

        -- Arrow 2 -> 3
        prompt = prompt .. esc .. "[48;2;" .. git_bg .. "m" .. esc .. "[38;2;" .. path_bg .. "m" .. sep

        -- Git Segment
        prompt = prompt .. esc .. "[48;2;" .. git_bg .. "m" .. esc .. "[38;2;" .. git_fg .. "m " .. git_text .. " "

        -- Arrow 3 -> 4
        prompt = prompt .. esc .. "[48;2;" .. time_bg .. "m" .. esc .. "[38;2;" .. git_bg .. "m" .. sep
    else
        -- Arrow 2 -> 4
        prompt = prompt .. esc .. "[48;2;" .. time_bg .. "m" .. esc .. "[38;2;" .. path_bg .. "m" .. sep
    end

    -- Time Segment
    prompt = prompt .. esc .. "[48;2;" .. time_bg .. "m" .. esc .. "[38;2;" .. time_fg .. "m " .. time_text .. " "

    -- Closing Arrow
    prompt = prompt .. reset .. esc .. "[38;2;" .. time_bg .. "m" .. sep .. reset .. " "

    clink.prompt.value = prompt
end

if clink and clink.prompt then
    clink.prompt.register_filter(sli_prompt_filter, 1)
end

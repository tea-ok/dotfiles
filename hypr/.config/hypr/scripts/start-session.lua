local main_monitor = "DP-4"
local side_monitor = "DP-5"
local main_workspace = 1
local side_workspace = 4
local firefox = "/usr/bin/firefox"
local fastfetch = "/home/linuxbrew/.linuxbrew/bin/fastfetch"
local btop = "/home/linuxbrew/.linuxbrew/bin/btop"

local function after(ms, cb)
    hl.timer(cb, { timeout = ms, type = "oneshot" })
end

local function run(cmd, rules)
    hl.exec_cmd(cmd, rules or {})
end

local function focus_workspace(workspace)
    hl.dispatch(hl.dsp.focus({ workspace = workspace }))
end

local function focus_window(title)
    hl.dispatch(hl.dsp.focus({ window = "title:^" .. title .. "$" }))
end

local function preselect(direction)
    hl.dispatch(hl.dsp.layout("preselect " .. direction))
end

hl.dispatch(hl.dsp.workspace.move({ workspace = main_workspace, monitor = main_monitor }))
hl.dispatch(hl.dsp.workspace.move({ workspace = side_workspace, monitor = side_monitor }))

focus_workspace(side_workspace)
run(firefox .. " --new-window about:blank", { workspace = side_workspace })

after(1200, function()
    focus_workspace(main_workspace)

    run("ghostty --title=startup-terminal", { workspace = main_workspace })

    after(700, function()
        focus_window("startup-terminal")
        preselect("r")

        run("ghostty --title=startup-fastfetch -e zsh -lc '" .. fastfetch .. "; exec zsh'", { workspace = main_workspace })

        after(700, function()
            focus_window("startup-fastfetch")
            preselect("d")

            run("ghostty --title=startup-btop -e zsh -lc 'exec " .. btop .. "'", { workspace = main_workspace })

            after(800, function()
                focus_window("startup-terminal")
            end)
        end)
    end)
end)

return hl.dsp.no_op()

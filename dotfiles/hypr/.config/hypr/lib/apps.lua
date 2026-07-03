return {
    terminal = "kitty",
    file_manager = "dolphin",
    spotlight = "dms ipc spotlight toggle",
    launcher = "dms ipc launcher toggle",
    browser = "firefox",
    lock = "dms ipc lock lock",
    powermenu = "dms ipc powermenu toggle",
    startup_script = os.getenv("HOME") .. "/.config/hypr/scripts/start-session.sh",
}

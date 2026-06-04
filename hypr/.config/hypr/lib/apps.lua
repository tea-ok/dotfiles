return {
    terminal = "ghostty",
    file_manager = "dolphin",
    menu = "wofi --show drun",
    browser = "firefox",
    startup_script = os.getenv("HOME") .. "/.config/hypr/scripts/start-session.sh",
}

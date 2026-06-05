return {
    terminal = "ghostty",
    file_manager = "dolphin",
    menu = "rofi -show drun",
    browser = "firefox",
    startup_script = os.getenv("HOME") .. "/.config/hypr/scripts/start-session.sh",
}

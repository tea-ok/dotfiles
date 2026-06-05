return {
    terminal = "ghostty",
    file_manager = "dolphin",
    menu = "rofi -show drun",
    browser = "firefox",
    lock = "pidof hyprlock >/dev/null 2>&1 || hyprlock",
    startup_script = os.getenv("HOME") .. "/.config/hypr/scripts/start-session.sh",
}

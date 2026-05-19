nic() {
  local session_name="${1:-$(basename "$PWD")}"
  local dir="$PWD"

  if tmux has-session -t "$session_name" 2>/dev/null; then
    tmux attach-session -t "$session_name"
    return
  fi

  tmux new-session -d -s "$session_name" -c "$dir" -x "$(tput cols)" -y "$(tput lines)"
  tmux split-window -h -t "$session_name" -c "$dir" -l 50%
  tmux send-keys -t "$session_name":1.1 'nvim .' C-m
  tmux select-pane -t "$session_name":1.1
  tmux attach-session -t "$session_name"
}

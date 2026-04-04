nic() {
  if [[ "$1" == "ls" ]]; then
    tmux list-sessions 2>/dev/null || echo "No tmux sessions."
    return
  fi

  if [[ "$1" == "kill" ]]; then
    local target="${2:-$(tmux display-message -p '#S' 2>/dev/null)}"
    if [[ -z "$target" ]]; then
      echo "Usage: nic kill [session]"
      return 1
    fi
    tmux kill-session -t "$target" && echo "Killed session: $target"
    return
  fi

  local session_name="${1:-$(basename "$PWD")}"

  if [[ -n "$TMUX" ]]; then
    echo "Already in a tmux session. Detach first or run from outside tmux."
    return 1
  fi

  if tmux has-session -t "$session_name" 2>/dev/null; then
    tmux attach-session -t "$session_name"
    return
  fi

  tmux new-session -d -s "$session_name" -c "$PWD" -x "$(tput cols)" -y "$(tput lines)"
  tmux split-window -v -t "$session_name" -c "$PWD" -l 20%
  tmux split-window -h -t "$session_name":1.1 -c "$PWD" -l 30%
  tmux send-keys -t "$session_name":1.1 'nvim' C-m
  tmux send-keys -t "$session_name":1.2 'claude' C-m
  tmux select-pane -t "$session_name":1.1
  tmux attach-session -t "$session_name"
}

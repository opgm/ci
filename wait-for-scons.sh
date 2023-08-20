ssh comma << 'ENDSSH'
  sudo systemctl restart comma
  echo "Waiting for scons to build..."
  sleep 30

  loop_count=0
  while true; do
    loop_count=$((loop_count+1))
    pane_contents=$(tmux capture-pane -pS -10000 -J)
    if echo "$pane_contents" | grep -q "scons: done building targets."; then
        echo "Scons built."
        break  # Exit the loop once text is found
    else
        echo "Waiting for scons to build..."
        sleep 10
    fi
    if [ $loop_count -gt 63 ]; then
      echo "Scons failed to build after 10 minutes."
      exit 1
    fi
  done
ENDSSH

#!/usr/bin/env bash
set -euo pipefail

# Hyprsunset toggle script (Disabled <-> 5500K)

STATE_FILE="$HOME/.cache/.hyprsunset_state"

ensure_state() {
  [[ -f "$STATE_FILE" ]] || echo "off" > "$STATE_FILE"
}

stop_hyprsunset() {
  if pgrep -x hyprsunset >/dev/null 2>&1; then
    pkill -x hyprsunset || true
    sleep 0.2
  fi
}

cmd_toggle() {
  ensure_state
  state="$(cat "$STATE_FILE" 2>/dev/null || echo off)"

  stop_hyprsunset

  if [[ "$state" == "on" || "$state" == "5500" ]]; then
    # Disable / Off
    if command -v hyprsunset >/dev/null 2>&1; then
      nohup hyprsunset -i >/dev/null 2>&1 &
      sleep 0.3 && pkill -x hyprsunset || true
    fi
    echo "off" > "$STATE_FILE"
    notify-send -u low "Hyprsunset" "Disabled" || true
  else
    # Enable 5500K
    if command -v hyprsunset >/dev/null 2>&1; then
      nohup hyprsunset -t 5500 >/dev/null 2>&1 &
    fi
    echo "5500" > "$STATE_FILE"
    notify-send -u low "Hyprsunset" "Enabled (5500K)" || true
  fi
}

cmd_status() {
  ensure_state
  state="$(cat "$STATE_FILE" 2>/dev/null || echo off)"

  if [[ "$state" == "on" || "$state" == "5500" ]]; then
    txt="<span size='18pt'>🌇</span>"
    cls="on"
    tip="Night Light: Enabled (5500K)"
  else
    txt="<span size='16pt'>☀</span>"
    cls="off"
    tip="Night Light: Disabled"
  fi

  printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$txt" "$cls" "$tip"
}

cmd_init() {
  ensure_state
  state="$(cat "$STATE_FILE" 2>/dev/null || echo off)"

  if [[ "$state" == "on" || "$state" == "5500" ]]; then
    if command -v hyprsunset >/dev/null 2>&1; then
      nohup hyprsunset -t 5500 >/dev/null 2>&1 &
    fi
  else
    stop_hyprsunset
  fi
}

case "${1:-}" in
  toggle) cmd_toggle ;;
  status) cmd_status ;;
  init) cmd_init ;;
  *) echo "usage: $0 [toggle|status|init]" >&2; exit 2 ;;
esac

#!/usr/bin/env bash
set -euo pipefail

APP="/app/bin/ledger-live-desktop"
export APPIMAGE="$APP"

# Decide platform from env or session
PLATFORM="${ELECTRON_OZONE_PLATFORM_HINT:-}"
if [[ -z "${PLATFORM}" ]]; thens
  if [[ "${ELECTRON_ENABLE_WAYLAND:-}" = "1" || -n "${WAYLAND_DISPLAY:-}" ]]; then
    PLATFORM="wayland"
  else
    PLATFORM="x11"
  fi
fi

case "${PLATFORM}" in
  wayland)
    exec zypak-wrapper "$APP" \
      --ozone-platform=wayland \
      --enable-features=UseOzonePlatform \
      "$@"
    ;;
  x11|X11)
    exec zypak-wrapper "$APP" \
      --ozone-platform=x11 \
      --disable-features=WaylandWindowDecorations \
      "$@"
    ;;
  *)
    exec zypak-wrapper "$APP" "$@"
    ;;
esac
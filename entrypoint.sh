#!/usr/bin/env sh
set -e

# Default host and port (can be overridden with PB_HOST and PB_PORT environment variables)
HOST=${PB_HOST:-0.0.0.0}
PORT=${PB_PORT:-8090}
PB_DATA=${PB_DATA:-/app/pb_data}
PB_PUBLIC=${PB_PUBLIC:-/app/pb_public}
PB_HOOKS=${PB_HOOKS:-/app/pb_hooks}
PB_MIGRATIONS=${PB_MIGRATIONS:-/app/pb_migrations}

create_superuser() {
  if [ -n "$PB_ADMIN_EMAIL" ] && [ -n "$PB_ADMIN_PASSWORD" ]; then
    /usr/local/bin/pocketbase superuser create \
      "$PB_ADMIN_EMAIL" \
      "$PB_ADMIN_PASSWORD" \
      --dir="${PB_DATA}" \
      --migrationsDir="${PB_MIGRATIONS}"
  fi
}

serve() {
  create_superuser
  exec /usr/local/bin/pocketbase serve \
    --http="${HOST}:${PORT}" \
    --dir="${PB_DATA}" \
    --publicDir="${PB_PUBLIC}" \
    --hooksDir="${PB_HOOKS}" \
    --migrationsDir="${PB_MIGRATIONS}" \
    "$@"
}

# Handle global flags that should go to main pocketbase command
case "$1" in
--help | -h | --version | -v)
  exec /usr/local/bin/pocketbase "$@"
  ;;
esac

# If no arguments passed, use default serve command
if [ $# -eq 0 ]; then
  serve
# If first argument starts with '-', treat as serve arguments
elif [ "${1#-}" != "$1" ]; then
  serve "$@"
else
  # Otherwise, pass all arguments directly to pocketbase
  exec /usr/local/bin/pocketbase "$@"
fi

#!/bin/sh
# Start command for Render deploys (see render.yaml).
# Render attaches one disk per service, but LibreChat writes user files to two
# locations (api/config/paths.js). Both are empty in the built image, so they can
# be replaced with symlinks onto the disk mounted at /app/data.
set -e

DATA_DIR="${LIBRECHAT_DATA_DIR:-/app/data}"

# Render assigns the MongoDB private service its own internal host and port, so
# MONGO_HOSTPORT (render.yaml) supplies them and the URI is assembled here.
if [ -n "$MONGO_URI" ]; then
  echo "[render] Connecting to the MONGO_URI set on this service."
elif [ -n "$MONGO_HOSTPORT" ]; then
  MONGO_URI="mongodb://$MONGO_HOSTPORT/LibreChat"
  export MONGO_URI
  echo "[render] Connecting to the librechat-mongo private service at $MONGO_HOSTPORT."
fi

mkdir -p "$DATA_DIR/uploads" "$DATA_DIR/images"
rm -rf /app/uploads /app/client/public/images
ln -s "$DATA_DIR/uploads" /app/uploads
ln -s "$DATA_DIR/images" /app/client/public/images

exec npm run backend

#!/bin/sh
# Start command for Render deploys (see render.yaml).
#
# Render assigns the MongoDB private service its own internal host and port, and
# blueprints cannot concatenate strings, so MONGO_HOSTPORT supplies the address
# and the URI is assembled here. To use an external database, delete the
# librechat-mongo service, which removes MONGO_HOSTPORT, then set MONGO_URI.
#
# Render also attaches one disk per service, while LibreChat writes user files to
# two locations (api/config/paths.js). Both are empty in the built image, so they
# are replaced with symlinks onto the disk. Re-running is safe because rm removes
# the previous symlink rather than the files on the disk.
set -e

DATA_DIR=/app/data

if [ -n "$MONGO_HOSTPORT" ]; then
  export MONGO_URI="mongodb://$MONGO_HOSTPORT/LibreChat"
fi

mkdir -p "$DATA_DIR/uploads" "$DATA_DIR/images"
rm -rf /app/uploads /app/client/public/images
ln -s "$DATA_DIR/uploads" /app/uploads
ln -s "$DATA_DIR/images" /app/client/public/images

exec npm run backend

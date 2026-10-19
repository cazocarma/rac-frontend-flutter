#!/bin/sh
set -eu
cd /app/build/web
# Flutter's entrypoint names are stable. Version both requests together so an
# already-open browser cannot mix a new document with a cached application.
version="$(sha256sum main.dart.js | cut -c1-16)"
sed -i "s/main\.dart\.js/main.dart.js?v=$version/g" flutter_bootstrap.js
sed -i "s/src=\"flutter_bootstrap.js\"/src=\"flutter_bootstrap.js?v=$version\"/" index.html

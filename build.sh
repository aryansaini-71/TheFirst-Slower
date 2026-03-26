#!/bin/bash
set -e

# 1. Clone Flutter (shallow)
git clone --depth 1 https://github.com/flutter/flutter.git -b stable

# 2. Add to PATH (using absolute path for safety)
export PATH="$PATH:$(pwd)/flutter/bin"

# 3. Suppress analytics
export FLUTTER_NO_ANALYTICS=1

# 4. Build
./flutter/bin/flutter config --enable-web
./flutter/bin/flutter pub get
./flutter/bin/flutter build web --release --web-renderer canvaskit --no-tree-shake-icons

# 5. Move to public
mkdir -p public
cp -r build/web/* public/
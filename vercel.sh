#!/bin/bash

# 1. Faster Clone (only gets the latest version, not the whole history)
git clone --depth 1 https://github.com/flutter/flutter.git -b stable

# 2. Add to Path
export PATH="$PATH:`pwd`/flutter/bin"

# 3. Suppress the "Root User" warning and skip analytics to save time
export FLUTTER_NO_ANALYTICS=1
export PUB_CACHE=".pub-cache"

# 4. Enable Web and Build
flutter config --no-analytics
flutter config --enable-web
flutter build web --release --web-renderer canvaskit

# 5. Move files
mkdir -p public
cp -r build/web/* public

flutter build web --release --web-renderer canvaskit
mkdir -p public
cp -r build/web/* public
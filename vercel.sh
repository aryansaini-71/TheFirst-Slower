#!/bin/bash
set -e  # Stop on any error — important for debugging

# 1. Clone Flutter (shallow, faster)
git clone --depth 1 https://github.com/flutter/flutter.git -b stable

# 2. Add to PATH
export PATH="$PATH:$(pwd)/flutter/bin"

# 3. Suppress warnings and analytics
export FLUTTER_NO_ANALYTICS=1
export PUB_CACHE=".pub-cache"

# 4. Configure Flutter
flutter config --no-analytics
flutter config --enable-web

# 5. Get dependencies
flutter pub get

# 6. Build for web (pick ONE renderer)
flutter build web --release --web-renderer canvaskit --no-tree-shake-icons

# 7. Copy to output directory
mkdir -p public
cp -r build/web/* public/
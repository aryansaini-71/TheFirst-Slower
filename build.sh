#!/bin/bash
set -e

# 1. Clean up any old flutter folder so the clone doesn't fail
rm -rf flutter

# 2. Clone Flutter (shallow)
git clone --depth 1 https://github.com/flutter/flutter.git -b stable

# 3. Add to PATH
export PATH="$PATH:$(pwd)/flutter/bin"

# 4. Suppress analytics
export FLUTTER_NO_ANALYTICS=1

# 5. Build
./flutter/bin/flutter config --enable-web
./flutter/bin/flutter pub get
./flutter/bin/flutter build web --release

# 6. Move to public
mkdir -p public
cp -r build/web/* public/
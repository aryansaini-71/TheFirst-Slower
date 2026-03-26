#!/bin/bash
set -e

# 1. Clone Flutter (shallow)
git clone --depth 1 https://github.com/flutter/flutter.git -b stable

# 2. Add to PATH
export PATH="$PATH:$(pwd)/flutter/bin"

# 3. Suppress analytics
export FLUTTER_NO_ANALYTICS=1

# 4. Build (Simplified & Reordered)
./flutter/bin/flutter config --enable-web
./flutter/bin/flutter pub get
# We moved '--release' to the front and removed the problematic renderer flag for now
./flutter/bin/flutter build web --release

# 5. Move to public
mkdir -p public
cp -r build/web/* public/
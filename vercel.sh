#!/bin/bash

# 1. Download Flutter from Google
git clone https://github.com/flutter/flutter.git -b stable

# 2. Add Flutter to the path so the computer can find it
export PATH="$PATH:`pwd`/flutter/bin"

# 3. Enable Web support
flutter config --enable-web

# 4. Build the app (using the canvaskit renderer for better images)
flutter build web --release --web-renderer canvaskit

# 5. Move the finished product to the folder Vercel expects
mkdir -p public
cp -r build/web/* public
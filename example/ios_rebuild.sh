#!/bin/bash

echo "=== iOS Clean & Rebuild Script ==="

# Flutter clean
echo "[1/5] Flutter clean..."
flutter clean

# iOS 캐시 삭제
echo "[2/5] Removing iOS caches..."
rm -rf ios/Pods
rm -rf ios/Podfile.lock
rm -rf ios/.symlinks
rm -rf ios/build

# Xcode DerivedData 삭제
echo "[3/5] Removing Xcode DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Flutter dependencies
echo "[4/5] Getting Flutter dependencies..."
flutter pub get

# Pod install
echo "[5/5] Installing CocoaPods..."
cd ios && pod install --repo-update && cd ..

echo "=== Done! ==="
echo "Run: flutter run -d <device_id>"

#!/bin/sh
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$project_dir"
swift build -c release --product LapkaBattery
binary_dir=$(swift build -c release --show-bin-path)
app_dir="$project_dir/dist/LapkaBattery.app"
mkdir -p "$app_dir/Contents/MacOS"
cp "$binary_dir/LapkaBattery" "$app_dir/Contents/MacOS/LapkaBattery"
cp "$project_dir/Info.plist" "$app_dir/Contents/Info.plist"
codesign --force --sign - "$app_dir"
echo "$app_dir"

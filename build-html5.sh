#!/usr/bin/env bash
# Builds the HTML5 version with the Solar2D Linux snap (see README.md, "Сборка для веба").
#
# The snap can only see $HOME, and its console builder has no HTML5 support on Linux,
# so the project is staged under $HOME and built through the simulator GUI:
#   File -> Build -> HTML5, then close the simulator; the result is copied into builds/.
#
#   ./build-html5.sh        build into builds/ludumcoin.html5
#   ./build-html5.sh serve  build, then serve it on http://localhost:8000
set -euo pipefail
cd "$(dirname "$0")"

name=ludumcoin
stage="$HOME/ld43-html5"
out="builds/$name.html5"

mkdir -p "$stage/src" "$stage/out"
rsync -a --delete \
    --exclude .git --exclude .idea --exclude builds --exclude build-html5.sh \
    ./ "$stage/src/"
rm -rf "$stage/out/$name.html5"

# The HTML5 build dialog builds the simulator's "last project", not the one given on the command line,
# so point both of its project records at the staged copy.
conf="$HOME/snap/solar2d/current/.Solar2D"
mkdir -p "$conf/Sandbox/homescreen"
echo "src=$stage/src/main.lua" > "$conf/recent.conf"
if [[ -f "$conf/Sandbox/homescreen/app.conf" ]]; then
    sed -i "s|^lastProjectDirectory=.*|lastProjectDirectory=$stage/src|" "$conf/Sandbox/homescreen/app.conf"
else
    echo "lastProjectDirectory=$stage/src" > "$conf/Sandbox/homescreen/app.conf"
fi

cat <<MSG
Solar2D simulator is starting; the project opens as a running game, that is expected.
In the game window press Ctrl+Alt+B (File -> Build -> HTML5...):
    Application Name: $name
    Version Code:     2018.12.03
    Save To Folder:   $stage/out
  Build, wait for "Your application was built successfully", then quit with Ctrl+Q.
MSG
solar2d "$stage/src/main.lua"

test -f "$stage/out/$name.html5/index.html"
# Guard against the simulator having packed another project: one of our own assets must be inside.
asset="data/$(ls data | grep -v '^\.' | head -1)"
if ! grep -aq "$asset" "$stage/out/$name.html5/$name.data"; then
    echo "ERROR: $asset is missing from the build, the simulator packed a different project" >&2
    exit 1
fi
mkdir -p builds
rm -rf "$out"
cp -r "$stage/out/$name.html5" "$out"
echo "→ $out"

if [[ "${1:-}" == "serve" ]]; then
    python3 -m http.server -d "$out" 8000
fi

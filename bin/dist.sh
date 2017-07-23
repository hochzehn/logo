#!/bin/bash

SRC_DIR=src
DIST_DIR=dist

mkdir -p "$DIST_DIR"
rm "$DIST_DIR"/*

function createLogoVersions() {
  LOGO_TYPE=$1

  echo "Generating dist files for '$LOGO_TYPE'"

  SRC_SVG="$SRC_DIR"/"$LOGO_TYPE".min.svg
  TARGET_SVG="$DIST_DIR"/"$LOGO_TYPE".svg

  cp "$SRC_SVG" "$TARGET_SVG"

  echo "  Generating PNG versions..."
  resize 64
  resize 196
  resize 256
  resize 512

  echo ""
}

function resize() {
  size=$1
  density=$((size * 4))
  echo -n "    $size"x"$size""..."
  docker run --rm --volume "$PWD/$SRC_SVG":"/app/input.svg" --volume "$PWD/$DIST_DIR":"/output" --workdir "/app" acleancoder/imagemagick-full convert -background none -resize "$size"x -density "$density" -depth 8 input.svg /output/"$LOGO_TYPE"-"$size".png
  echo "OK"
}

function optimizePng() {
  DIR=$1

  echo "Size before optimization"
  du -h "$DIR"

  echo -n "Optimizing..."
  CURRENT="$PWD"
  cd "$DIR"
  docker run --rm -v "$PWD":/source buffcode/docker-optipng -q -o7 *.png
  cd "$CURRENT"
  echo "OK"

  echo "Size after optimization"
  du -h "$DIR"
}

createLogoVersions "arrow"
createLogoVersions "claim"
createLogoVersions "claim-white"
createLogoVersions "logo"

optimizePng "$DIST_DIR"

bin/own.sh "$PWD/$DIST_DIR"

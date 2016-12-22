#!/bin/bash

SRC_DIR=src
DIST_DIR=dist

SRC_SVG="$SRC_DIR"/logo.svg

mkdir -p "$DIST_DIR"
rm "$DIST_DIR"/*

cp "$SRC_DIR"/logo.min.svg "$DIST_DIR"/logo.svg

function resize() {
    size=$1
    density=$((size * 4))
    echo -n "$size"x"$size""..."
    docker run --rm --volume "$PWD/$SRC_SVG":"/app/input.svg" --volume "$PWD/$DIST_DIR":"/output" --workdir "/app" acleancoder/imagemagick-full convert -background none -resize "$size"x -density "$density" -depth 8 input.svg /output/logo-"$size".png
    echo "OK"
}

echo "Generating PNG versions..."
resize 64
resize 196
resize 256
resize 512

echo ""
echo "Size before optimization"
du -h "$DIST_DIR"

echo -n "Optimizing..."
CURRENT="$PWD"
cd "$DIST_DIR"
docker run --rm -v "$PWD":/source buffcode/docker-optipng -q -o7 *.png
cd "$CURRENT"
echo "OK"

echo "Size after optimization"
du -h "$DIST_DIR"

bin/own.sh "$PWD/$DIST_DIR"

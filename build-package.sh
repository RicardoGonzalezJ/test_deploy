#!/bin/bash

set -e

PACKAGE_DIR="package"
ZIP_NAME="testDeploy-package.zip"
SCRIPTS_DIR="scripts"
SERVER_DIST_DIR="scripts-dist"
FRONTEND_DIST_DIR="dist"
WINSW_URL="https://github.com/winsw/winsw/releases/latest/download/WinSW-x64.exe"
WINSW_EXE_NAME="testDeploy.exe"
WINSW_DEST="$SCRIPTS_DIR/$WINSW_EXE_NAME"

# Temporaty isolated build directory
BUILD_TEMP_DIR="build-temp"

# Ensure scripts dir exists
mkdir -p "$SCRIPTS_DIR"

# Download WinSW if not already present
if [ ! -f "$WINSW_DEST" ]; then
    echo "🌐 Downloading WinSW.exe..."
    curl -L -o "$WINSW_DEST" "$WINSW_URL"
    echo "✅ Downloaded WinSW to $WINSW_DEST"
fi
echo ""

# Clean previous temp/package builds
rm -rf "$BUILD_TEMP_DIR" "$PACKAGE_DIR" "$ZIP_NAME"

# Copy everything to a temporary build dir, excluding node_modules
echo "📂 Creating isolated build directory..."
rsync -av --exclude=node_modules --exclude=$BUILD_TEMP_DIR ./ "$BUILD_TEMP_DIR" > /dev/null
cd "$BUILD_TEMP_DIR"

echo "🔧 Installing dependencies..."
npm install

echo "🏗️ Building frontend with Vite..."
npm run build

echo "⚙️  Compiling backend server..."
npm run build:scripts

echo "🧹 Pruning dev dependencies..."
npm prune --omit=dev

# Create package directory
mkdir -p "$PACKAGE_DIR"

echo ""
echo "📦 Building Windows service deployment package..."
echo ""

# Copy frontend build
echo "📂 Copying frontend build..."
cp -r "$FRONTEND_DIST_DIR" "$PACKAGE_DIR/dist"
echo ""

# Copy compiled server.js and node_modules if needed
echo "📂 Copying server files..."
cp -r "$SERVER_DIST_DIR" "$PACKAGE_DIR/scripts-dist"
cp -r node_modules "$PACKAGE_DIR/"
echo ""

# Copy WinSW executable and config
echo "⚙️  Copying WinSW service files..."
cp "$SCRIPTS_DIR"/testDeploy.exe "$PACKAGE_DIR"
cp "$SCRIPTS_DIR"/testDeploy.xml "$PACKAGE_DIR"
cp "$SCRIPTS_DIR"/install.bat "$PACKAGE_DIR"
cp "$SCRIPTS_DIR"/uninstall.bat "$PACKAGE_DIR"
echo ""

# Move final output OUT of build-temp before removeing it
echo "📤 Moving final output outside build-temp..."
mv "$PACKAGE_DIR" ../
cd ..
echo ""

# Create a zip archive
echo "🗜️  Creating zip archive..."
zip -r "$ZIP_NAME" "$PACKAGE_DIR" > /dev/null
echo ""

# Clean up temp folder
rm -rf "$BUILD_TEMP_DIR"

echo "✅ Done. Output:" 
echo "   Folder: $PACKAGE_DIR/"
echo "   Archive: $ZIP_NAME"
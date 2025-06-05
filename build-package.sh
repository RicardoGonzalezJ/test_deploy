#!/bin/bash

set -e

PACKAGE_DIR="package"
ZIP_NAME="testDeploy-package.zip"
SCRIPTS_DIR="scripts"
SERVER_DIST_DIR="scripts-dist"
FRONTEND_DIST_DIR="dist"

echo "🔧 Installing dependencies..."
npm install

echo "🏗️ Building frontend with Vite..."
npm run build

echo "⚙️  Compiling backend server..."
npm run build:scripts

echo "🧹 Pruning dev dependencies..."
npm prune --omit=dev

echo ""
echo "📦 Building Windows service deployment package..."
echo ""

# Clean up prevous build
rm -rf "$PACKAGE_DIR" "$ZIP_NAME"
mkdir -p "$PACKAGE_DIR"

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

# Create a zip archive
echo "🗜️  Creating zip archive..."
zip -r "$ZIP_NAME" "$PACKAGE_DIR" > /dev/null
echo ""

echo "✅ Done. Output:" 
echo "   Folder: $PACKAGE_DIR/"
echo "   Archive: $ZIP_NAME"
#!/bin/bash

echo "🔍 Testing Firebase CLI Token"
echo "=============================="

# Load environment variables from .env if it exists
if [ -f ".env" ]; then
    echo "📄 Loading .env file..."
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "⚠️  No .env file found"
fi

# Check if token is set
if [ -z "$FIREBASE_CLI_TOKEN" ]; then
    echo "❌ FIREBASE_CLI_TOKEN is not set"
    echo ""
    echo "Please create a .env file with:"
    echo "FIREBASE_CLI_TOKEN=1//03C3OnT6AFA1JCgYIARAAGAMSNwF-L9IrTIZcU7r-TBMH-1ElGgZGbkpuoIGuY-tSZnQMLiJbG9xnfY8Zjku0LvxSskJaxHPxa5w"
    exit 1
fi

echo "✅ Token is set (length: ${#FIREBASE_CLI_TOKEN})"
echo "🔑 Token starts with: ${FIREBASE_CLI_TOKEN:0:20}..."

# Check Firebase CLI
echo ""
echo "🔧 Checking Firebase CLI..."
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found"
    echo "Installing Firebase CLI..."
    npm install -g firebase-tools
fi

firebase --version

# Test authentication
echo ""
echo "🔐 Testing Firebase authentication..."
firebase projects:list --token "$FIREBASE_CLI_TOKEN" || {
    echo "❌ Authentication failed"
    echo "This could be why you're getting 404 errors"
    exit 1
}

# Test specific project access
echo ""
echo "🎯 Testing access to warrior-dd0f2..."
firebase projects:list --token "$FIREBASE_CLI_TOKEN" | grep "warrior-dd0f2" || {
    echo "❌ Project warrior-dd0f2 not found or no access"
    exit 1
}

# Test App Distribution access
echo ""
echo "📱 Testing App Distribution access..."
firebase appdistribution:apps:list --project warrior-dd0f2 --token "$FIREBASE_CLI_TOKEN" || {
    echo "❌ App Distribution access failed"
    echo "This is likely the cause of your 404 error"
    echo ""
    echo "🔧 To fix this:"
    echo "1. Go to https://console.firebase.google.com/project/warrior-dd0f2"
    echo "2. Navigate to 'Release & Monitor' → 'App Distribution'"
    echo "3. Click 'Get started' if not already enabled"
    echo "4. Make sure your Android app is registered"
    exit 1
}

echo ""
echo "✅ All tests passed!"
echo "🎉 Your Firebase setup should work for App Distribution" 
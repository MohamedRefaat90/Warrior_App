#!/bin/bash

echo "🔍 Testing Firebase CLI Access and App Distribution Setup"
echo "=================================================="

# Check if Firebase CLI token is set
if [ -z "$FIREBASE_CLI_TOKEN" ]; then
    echo "❌ FIREBASE_CLI_TOKEN environment variable is not set"
    echo "Please set it with: export FIREBASE_CLI_TOKEN='your-token-here'"
    exit 1
else
    echo "✅ FIREBASE_CLI_TOKEN is set (length: ${#FIREBASE_CLI_TOKEN})"
fi

echo ""
echo "🔗 Testing Firebase project access..."

# Test basic Firebase access
echo "📋 Listing Firebase projects:"
firebase projects:list --token "$FIREBASE_CLI_TOKEN" || {
    echo "❌ Failed to list Firebase projects"
    echo "This usually means:"
    echo "  1. Invalid or expired Firebase CLI token"
    echo "  2. No access to any Firebase projects"
    exit 1
}

echo ""
echo "🎯 Testing specific project access (warrior-dd0f2):"
firebase projects:list --token "$FIREBASE_CLI_TOKEN" | grep "warrior-dd0f2" || {
    echo "❌ Project 'warrior-dd0f2' not found or no access"
    echo "Please check:"
    echo "  1. Project ID is correct"
    echo "  2. Service account has access to this project"
    exit 1
}

echo ""
echo "📱 Testing App Distribution access:"
firebase appdistribution:apps:list --project warrior-dd0f2 --token "$FIREBASE_CLI_TOKEN" || {
    echo "❌ Failed to access App Distribution"
    echo "This usually means:"
    echo "  1. App Distribution is not enabled in Firebase Console"
    echo "  2. Service account lacks 'Firebase App Distribution Admin' role"
    echo "  3. No apps registered for App Distribution"
    echo ""
    echo "🔧 Next steps:"
    echo "  1. Go to https://console.firebase.google.com/project/warrior-dd0f2"
    echo "  2. Navigate to 'Release & Monitor' → 'App Distribution'"
    echo "  3. Enable App Distribution if not already enabled"
    echo "  4. Register your Android app for distribution"
    exit 1
}

echo ""
echo "✅ All Firebase checks passed!"
echo "🎉 Your setup should work for Firebase App Distribution"

echo ""
echo "📱 App Configuration:"
echo "  Project ID: warrior-dd0f2"
echo "  App ID: 1:466603345246:android:a4d0161c402a1bd30a3bcf"
echo "  Package: com.warrior90.app"
echo ""
echo "🔗 Firebase Console: https://console.firebase.google.com/project/warrior-dd0f2/appdistribution" 
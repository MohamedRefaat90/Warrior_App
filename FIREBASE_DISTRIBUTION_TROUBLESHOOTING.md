# Firebase App Distribution Troubleshooting Guide

## Issue: Invalid request, status_code: 404

This error typically occurs when Firebase App Distribution can't find or access your app. Here's how to fix it:

## 🔧 Step-by-Step Fix

### 1. Enable Firebase App Distribution

1. Go to [Firebase Console](https://console.firebase.google.com/project/warrior-dd0f2)
2. Navigate to **Release & Monitor** → **App Distribution**
3. If prompted, **enable App Distribution** for your project
4. Select your Android app from the dropdown

### 2. Verify App Registration

Ensure your Android app is properly registered:

1. In Firebase Console, go to **Project Settings** → **General**
2. Scroll down to **Your apps** section
3. Verify the app with ID `1:466603345246:android:a4d0161c402a1bd30a3bcf` exists
4. Check that the package name matches: `com.warrior90.app`

### 3. Check Service Account Permissions

Your `FIREBASE_CLI_TOKEN` needs proper permissions:

1. Go to [Google Cloud Console](https://console.cloud.google.com/iam-admin/serviceaccounts)
2. Select your project: `warrior-dd0f2`
3. Find the service account used for the CLI token
4. Ensure it has these roles:
   - **Firebase App Distribution Admin**
   - **Firebase Admin SDK Administrator Service Agent**

### 4. Generate New Firebase CLI Token

If permissions are correct but still failing:

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login and generate token
firebase login:ci

# Copy the generated token to GitHub Secrets as FIREBASE_CLI_TOKEN
```

### 5. Test Firebase CLI Access

Test your token locally:

```bash
# Set token
export FIREBASE_CLI_TOKEN="your-token-here"

# List projects (should include warrior-dd0f2)
firebase projects:list --token "$FIREBASE_CLI_TOKEN"

# Test App Distribution access
firebase appdistribution:apps:list --project warrior-dd0f2 --token "$FIREBASE_CLI_TOKEN"
```

## 🚀 Alternative Solutions

### Option 1: Manual Upload

If automated distribution fails:

1. Download the APK artifact from the GitHub Actions run
2. Go to Firebase Console → App Distribution
3. Click **Distribute app** → **Upload**
4. Select the APK file and configure testers

### Option 2: Use Service Account Key

Instead of CLI token, use a service account key:

1. Go to [Google Cloud Console](https://console.cloud.google.com/iam-admin/serviceaccounts)
2. Create or select a service account
3. Generate a JSON key file
4. Add the entire JSON content as a GitHub secret
5. Update Fastfile to use `google_service_account_key_file`

```ruby
firebase_app_distribution(
  app: "1:466603345246:android:a4d0161c402a1bd30a3bcf",
  service_credentials_file: "path/to/service-account.json",
  # ... other options
)
```

## 🔍 Debug Information

Current configuration:
- **Project ID**: `warrior-dd0f2`
- **App ID**: `1:466603345246:android:a4d0161c402a1bd30a3bcf`
- **Package Name**: `com.warrior90.app`
- **Testers**: `bombotuf15@gmail.com`, `mohamedbfc700@gmail.com`, `momenrefat977@gmail.com`, `ahmedkok980@gmail.com`

## 📞 Additional Help

If issues persist:

1. **Check Firebase Console Logs**: Look for any error messages in the App Distribution section
2. **Verify App Status**: Ensure the app is not in a suspended or restricted state
3. **Contact Firebase Support**: Use the Firebase Console support chat
4. **Community Help**: Post on [Stack Overflow](https://stackoverflow.com/questions/tagged/firebase-app-distribution) with the `firebase-app-distribution` tag

## ✅ Success Indicators

You'll know it's working when:
- The Firebase CLI can list your apps
- App Distribution shows in Firebase Console
- Testers receive email notifications
- APK appears in the App Distribution dashboard 
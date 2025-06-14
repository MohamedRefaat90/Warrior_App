# Firebase App Distribution Setup Guide

## 🔧 Setup Instructions

### 1. Create .env File

Create a `.env` file in the project root with your Firebase CLI token:

```bash
# Create .env file
touch .env

# Add your Firebase CLI token
echo "FIREBASE_CLI_TOKEN=1//03C3OnT6AFA1JCgYIARAAGAMSNwF-L9IrTIZcU7r-TBMH-1ElGgZGbkpuoIGuY-tSZnQMLiJbG9xnfY8Zjku0LvxSskJaxHPxa5w" >> .env
```

### 2. Install Dependencies

```bash
cd android
bundle install
```

### 3. Test Firebase Access

Run the test script to verify your setup:

```bash
# Make script executable (Linux/Mac)
chmod +x scripts/test_firebase_token.sh

# Run the test
./scripts/test_firebase_token.sh
```

## 🔍 Troubleshooting 404 Error

The 404 error you're experiencing is likely due to one of these issues:

### Issue 1: Firebase App Distribution Not Enabled

1. Go to [Firebase Console](https://console.firebase.google.com/project/warrior-dd0f2)
2. Navigate to **Release & Monitor** → **App Distribution**
3. Click **"Get started"** if App Distribution isn't enabled
4. Make sure your Android app is registered for distribution

### Issue 2: Service Account Permissions

Your Firebase CLI token needs proper permissions:

1. Go to [Google Cloud Console](https://console.cloud.google.com/iam-admin/serviceaccounts?project=warrior-dd0f2)
2. Find the service account associated with your token
3. Ensure it has these roles:
   - **Firebase App Distribution Admin**
   - **Firebase Admin SDK Administrator Service Agent**

### Issue 3: Token Expired or Invalid

Generate a new Firebase CLI token:

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login and generate new token
firebase login:ci

# Copy the generated token to your .env file
```

## 🚀 Local Testing

Test the Fastlane setup locally:

```bash
cd android
bundle exec fastlane android fbd
```

## 📱 Current Configuration

- **Project ID**: `warrior-dd0f2`
- **App ID**: `1:466603345246:android:a4d0161c402a1bd30a3bcf`
- **Package Name**: `com.warrior90.app`
- **Testers**: 
  - bombotuf15@gmail.com
  - mohamedbfc700@gmail.com
  - momenrefat977@gmail.com
  - ahmedkok980@gmail.com

## 🔗 Useful Links

- [Firebase Console](https://console.firebase.google.com/project/warrior-dd0f2)
- [App Distribution](https://console.firebase.google.com/project/warrior-dd0f2/appdistribution)
- [Google Cloud IAM](https://console.cloud.google.com/iam-admin/serviceaccounts?project=warrior-dd0f2)

## ✅ Success Indicators

You'll know it's working when:
- ✅ Firebase CLI can list your projects
- ✅ App Distribution shows in Firebase Console
- ✅ Testers receive email notifications
- ✅ APK appears in the App Distribution dashboard 
# Firebase App Distribution Setup Guide

## ✅ Issue Fixed: App ID Corrected
The app ID in your Fastfile has been corrected from:
- ❌ `1:466603345246:android:a4d0161c402a1bd30a3bcf`
- ✅ `1:466603345246:android:810666c6db8b75510a3bcf`

## 🔧 Required Steps to Complete Setup

### Step 1: Upgrade Node.js (Required)
Your current Node.js version (18.12.1) is incompatible with Firebase CLI v14.7.0.

1. Download Node.js 20.x or 22.x LTS from: https://nodejs.org/
2. Install the new version
3. Restart your terminal/PowerShell
4. Verify installation: `node --version`

### Step 2: Choose Authentication Method

#### Option A: Firebase CLI Token (Simple)
1. After upgrading Node.js, run:
   ```bash
   firebase login:ci
   ```
2. This opens a browser for authentication and provides a token
3. Create a `.env` file in your project root:
   ```bash
   FIREBASE_CLI_TOKEN=your_actual_token_here
   ```

#### Option B: Service Account (Recommended for Production)
1. Go to Firebase Console → Project Settings → Service Accounts
2. Click "Generate new private key"
3. Download the JSON file
4. Place it in a secure location (e.g., `android/firebase-service-account.json`)
5. Update your Fastfile to use service account:
   ```ruby
   firebase_app_distribution(
     app: "1:466603345246:android:810666c6db8b75510a3bcf",
     service_credentials_file: "firebase-service-account.json",
     android_artifact_type: "APK",
     android_artifact_path: "../build/app/outputs/flutter-apk/app-release.apk",
     testers: "bombotuf15@gmail.com,mohamedbfc700@gmail.com,momenrefat977@gmail.com,ahmedkok980@gmail.com",
     release_notes: "First Release To Google Play",
   )
   ```

### Step 3: Enable Firebase App Distribution
1. Go to Firebase Console
2. Navigate to Release & Monitor → App Distribution
3. Make sure your Android app is registered
4. Add your test devices/testers if needed

### Step 4: Test the Setup
Run your Fastlane command again:
```bash
cd android
bundle exec fastlane android fbd
```

## 🚨 Additional Notes

### Security Best Practices
- Add `.env` to your `.gitignore` file
- Never commit service account keys to version control
- Use environment variables in CI/CD pipelines

### Troubleshooting
- If you still get 404 errors, verify the app exists in Firebase App Distribution
- Check that your Firebase project has App Distribution enabled
- Ensure your Google account has the necessary permissions

### Alternative: Manual Upload
If automation fails, you can manually upload via Firebase Console:
1. Build your APK: `flutter build apk --release`
2. Go to Firebase Console → App Distribution
3. Drag and drop your APK from `build/app/outputs/flutter-apk/app-release.apk`

## 📝 Updated Fastfile
Your Fastfile has been updated with the correct app ID and includes comments for both authentication options. 
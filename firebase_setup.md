# Firebase Setup Guide for MineChat

## Prerequisites
1. Firebase project created at https://console.firebase.google.com/
2. Flutter project with Firebase dependencies already added

## Step 1: Firebase Project Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing project
3. Enable the following services:
   - Authentication
   - Firestore Database
   - Storage (optional, for profile images)

## Step 2: Authentication Setup

1. In Firebase Console, go to **Authentication** > **Sign-in method**
2. Enable the following providers:
   - **Email/Password**
   - **Google** (requires OAuth 2.0 client ID)

### Google Sign-In Setup
1. Go to **Authentication** > **Sign-in method** > **Google**
2. Enable Google sign-in
3. Add your OAuth 2.0 client ID from Google Cloud Console
4. Add authorized domains

## Step 3: Firestore Database Setup

1. Go to **Firestore Database** > **Create database**
2. Choose **Start in test mode** (for development)
3. Select a location close to your users

### Security Rules
Update your Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Business accounts collection
    match /business_accounts/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Admin users collection
    match /admin_users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Step 4: Android Configuration

1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/google-services.json`
3. Ensure your `android/app/build.gradle` has:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```
4. Ensure your `android/build.gradle` has:
   ```gradle
   classpath 'com.google.gms:google-services:4.3.15'
   ```

## Step 5: iOS Configuration

1. Download `GoogleService-Info.plist` from Firebase Console
2. Place it in `ios/Runner/GoogleService-Info.plist`
3. Add it to your Xcode project

## Step 6: Web Configuration (if needed)

1. Download web config from Firebase Console
2. Create `web/index.html` with Firebase SDK
3. Add Firebase config object

## Step 7: Testing

1. Run `flutter pub get`
2. Test the app with:
   - Email/password registration
   - Google sign-in
   - Business account creation
   - Admin account creation

## Troubleshooting

### Common Issues:
1. **Google Sign-In not working**: Check OAuth 2.0 client ID and SHA-1 fingerprint
2. **Firestore permission denied**: Check security rules
3. **Build errors**: Ensure all Firebase dependencies are properly added

### SHA-1 Fingerprint (Android)
Get your SHA-1 fingerprint:
```bash
cd android
./gradlew signingReport
```

Add the SHA-1 to your Firebase project settings.

## Environment Variables (Optional)

For production, consider using environment variables:
- Create `.env` file
- Add Firebase config as environment variables
- Use `flutter_dotenv` package

## Next Steps

After setup:
1. Test all authentication flows
2. Verify data is being saved to Firestore
3. Implement additional features like profile image upload
4. Add proper error handling and user feedback
5. Implement email verification flow
6. Add password reset functionality

## Security Best Practices

1. Always validate data on the server side
2. Use proper Firestore security rules
3. Implement rate limiting
4. Add email verification
5. Use strong password policies
6. Implement proper session management

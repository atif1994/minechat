# Firestore Security Rules for MineChat

## Current Issue
The error `"The caller does not have permission to execute the specified operation"` occurs because the current Firestore security rules don't allow the email existence check query.

## Solution
Update your Firestore security rules in the Firebase Console:

1. Go to **Firestore Database** > **Rules**
2. Replace the current rules with the following:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      // Allow email existence check for new users
      allow list: if request.auth != null && 
        request.query.limit <= 1 && 
        request.query.filters.size() == 1 &&
        request.query.filters[0].fieldPath == 'email';
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

## Alternative Solution (Recommended)
If you want to avoid the email existence check entirely, you can rely on Firebase Authentication's built-in duplicate email handling. The updated code already handles this gracefully.

## Testing the Rules
After updating the rules:
1. Wait 1-2 minutes for the rules to propagate
2. Test the business account creation again
3. The error should be resolved

## Security Best Practices
- The rules ensure users can only access their own data
- Email existence checks are limited to authenticated users only
- Query limits prevent abuse of the email check functionality

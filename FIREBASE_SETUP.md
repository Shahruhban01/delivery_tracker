# Firebase Setup Instructions

## 1. Create Firebase Project

1. Go to https://console.firebase.google.com/
2. Click "Add project"
3. Enter project name: "delivery-tracker"
4. Disable Google Analytics (optional for Spark plan)
5. Click "Create project"

## 2. Add Android App

1. In Firebase Console, click Android icon
2. Android package name: `com.yourcompany.delivery_tracker`
3. Download `google-services.json`
4. Place file in `android/app/`

## 3. Add iOS App

1. In Firebase Console, click iOS icon
2. iOS bundle ID: `com.yourcompany.deliveryTracker`
3. Download `GoogleService-Info.plist`
4. Place file in `ios/Runner/`

## 4. Configure Android

Edit `android/build.gradle`:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}

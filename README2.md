# Delivery Tracker - Professional Delivery Management App

A production-ready Flutter application for tracking deliveries, managing customer interactions, and maintaining delivery records. Built with Firebase backend and offline-first architecture for reliability in poor network conditions.

![Flutter](https://img.shields.io/badge/Flutter-3.1+-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Spark-FFCA28?logo=firebase)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📱 Features

### Core Functionality
- **Daily Sheet Management** - Import and manage daily delivery schedules
- **Customer Tracking** - Track all customer interactions, calls, and delivery attempts
- **Call Logging** - Automatic call count tracking with timestamps
- **Status Management** - Custom status updates with optional notes
- **Area Grouping** - Organize customers by delivery area with drag-and-drop
- **Real-time Search** - Search across all customer fields instantly
- **Offline-First** - Works seamlessly without internet connection

### Authentication
- Email/Password authentication
- Google Sign-In
- Phone authentication (with test numbers)
- Session persistence

### Analytics
- **Delivery Analytics** - Track picked, delivered, and failed deliveries
- **Returns Analytics** - Monitor assigned, completed, and failed returns
- **Fuel Analytics** - Track petrol expenses per day

### Custom UI
- Professional, minimal design
- No default Material widgets
- Custom components built from scratch
- Smooth animations and transitions
- Optimized for physical movement and poor network

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|-----------|
| **Framework** | Flutter 3.1+ |
| **Language** | Dart |
| **Backend** | Firebase (Spark Plan) |
| **Authentication** | Firebase Auth |
| **Database** | Cloud Firestore |
| **State Management** | Provider |
| **Architecture** | Clean Architecture |

---

## 📋 Prerequisites

- Flutter SDK 3.1 or higher
- Dart SDK 3.1 or higher
- Node.js (for Firebase CLI)
- Firebase account
- Android Studio / Xcode (for mobile development)

---

## 🚀 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/delivery_tracker.git
cd delivery_tracker
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Install Firebase CLI

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login to Firebase
firebase login
```

### 4. Configure Firebase

```bash
# Run FlutterFire configuration
flutterfire configure
```

This will:
- Show your Firebase projects
- Let you select/create a project
- Ask which platforms to configure (Android, iOS, Web, macOS)
- Generate `lib/firebase_options.dart` automatically

### 5. Enable Firebase Services

#### In Firebase Console (https://console.firebase.google.com):

**Authentication:**
1. Go to **Authentication** > **Sign-in method**
2. Enable **Email/Password**
3. Enable **Google**
4. Enable **Phone**
5. Add test phone number:
   - Phone: `+1 650-555-3434`
   - Code: `123456`

**Firestore Database:**
1. Go to **Firestore Database**
2. Click **Create database**
3. Start in **production mode**
4. Choose your location

**Security Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 6. Run the App

```bash
# Run on connected device
flutter run

# Run on specific device
flutter devices
flutter run -d <device_id>
```

---

## 📖 Usage

### Adding Daily Sheet (JSON Import)

1. Tap the **+** button on home screen
2. Paste JSON data in the following format:

```json
{
  "date": "2026-01-15",
  "area": "Hardu Shiva, Sopore",
  "customers": [
    {
      "name": "Mehmeeza Manzoor",
      "address": "247, Hardu Shiva, near Jamia Masjid, Sopore - 193201",
      "phone": "9419012345",
      "area": "Hardu Shiva"
    }
  ]
}
```

3. Tap **Process & Save**

### JSON Format Specification

#### Required Fields
- `date` (string, ISO format: YYYY-MM-DD)
- `area` (string, default area for the day)
- `customers` (array)
  - `name` (string)
  - `address` (string)
  - `phone` (string)

#### Optional Fields
- `customers[].area` (string, overrides default area)

### Managing Customers

**Call Tracking:**
- Use **+** / **−** buttons to track call attempts
- Timestamp is automatically logged

**Status Updates:**
- Tap **Status** button on customer card
- Select from available statuses:
  - Pending
  - Confirmed (will accept)
  - Not Responding
  - Cancelled with Code (RTO)
  - Delivered
  - Heavy Load
  - Reschedule
- Optionally add notes

**Reordering:**
- Long-press any customer card
- Drag to reorder
- Changes are saved automatically

**Search:**
- Use search bar to filter by:
  - Name
  - Address
  - Phone
  - Area
  - Status
  - Notes

### Daily Metrics

From the Day Details screen:
1. Tap **Edit** icon
2. Update metrics:
   - Picked
   - Delivered
   - Failed
   - Assigned Returns
   - Completed Returns
   - Failed Returns
   - Earnings (₹)
   - Petrol (₹)
3. Tap **Save**

### Viewing Analytics

From home screen menu:
- **Delivery Analytics** - Last 30 days delivery performance
- **Returns Analytics** - Returns completion rates
- **Fuel Analytics** - Petrol expenses and averages

---

## 📁 Project Structure

```
delivery_tracker/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── app.dart                           # Root app widget
│   ├── firebase_options.dart              # Auto-generated Firebase config
│   │
│   ├── config/
│   │   └── firebase_config.dart           # Firebase helper utilities
│   │
│   ├── models/
│   │   ├── customer.dart                  # Customer model
│   │   ├── call_log.dart                  # Call log model
│   │   ├── daily_sheet.dart               # Daily sheet model
│   │   └── status_change.dart             # Status change model
│   │
│   ├── services/
│   │   ├── auth_service.dart              # Authentication service
│   │   └── firestore_service.dart         # Firestore operations
│   │
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart          # Login/Register
│   │   │   └── phone_auth_screen.dart     # Phone authentication
│   │   ├── home/
│   │   │   └── home_screen.dart           # Daily sheets list
│   │   ├── day_details/
│   │   │   └── day_details_screen.dart    # Customer list for day
│   │   ├── customer_detail/
│   │   │   └── customer_detail_screen.dart # Customer full details
│   │   ├── analytics/
│   │   │   ├── delivery_analytics_screen.dart
│   │   │   ├── returns_analytics_screen.dart
│   │   │   └── fuel_analytics_screen.dart
│   │   └── json_input/
│   │       └── json_input_screen.dart     # JSON import
│   │
│   └── widgets/
│       ├── custom_button.dart             # Custom button component
│       ├── custom_dropdown.dart           # Custom dropdown
│       ├── custom_search_bar.dart         # Custom search
│       ├── custom_card.dart               # Base card component
│       ├── day_card.dart                  # Daily sheet card
│       ├── customer_card.dart             # Customer card
│       └── draggable_customer_list.dart   # Drag-drop list
│
├── assets/
│   ├── images/                            # App images
│   └── icon/
│       └── app_logo.png                   # App icon
│
├── android/                               # Android-specific code
├── ios/                                   # iOS-specific code
├── pubspec.yaml                           # Dependencies
└── README.md                              # This file
```

---

## 🗄️ Firestore Data Structure

```
users/{userId}/
├── dailySheets/{sheetId}
│   ├── date: Timestamp
│   ├── area: String
│   ├── totalCustomers: Number
│   ├── picked: Number
│   ├── delivered: Number
│   ├── failed: Number
│   ├── assignedReturns: Number
│   ├── completedReturns: Number
│   ├── failedReturns: Number
│   ├── earnings: Number
│   ├── petrol: Number
│   ├── createdAt: Timestamp
│   └── updatedAt: Timestamp
│
├── customers/{customerId}
│   ├── dayId: String
│   ├── name: String
│   ├── address: String
│   ├── phone: String
│   ├── area: String
│   ├── status: String
│   ├── callCount: Number
│   ├── lastCallTime: Timestamp
│   ├── notes: String
│   ├── order: Number
│   ├── createdAt: Timestamp
│   └── updatedAt: Timestamp
│
├── callLogs/{logId}
│   ├── customerId: String
│   ├── dayId: String
│   ├── attemptNumber: Number
│   └── timestamp: Timestamp
│
└── statusChanges/{changeId}
    ├── customerId: String
    ├── dayId: String
    ├── oldStatus: String
    ├── newStatus: String
    ├── notes: String
    └── timestamp: Timestamp
```

---

## 🔧 Configuration

### Changing Package Name

```bash
flutter pub run change_app_package_name:main com.yourcompany.deliverytracker
```

### Updating App Icon

1. Replace `assets/icon/app_logo.png` with your icon (1024x1024px)
2. Run:
```bash
flutter pub run flutter_launcher_icons
```

### Firebase Configuration

All Firebase configuration is in `lib/firebase_options.dart` (auto-generated).

To reconfigure:
```bash
flutterfire configure
```

---

## 🐛 Troubleshooting

### FlutterFire Command Not Found

**Windows:**
Add to PATH: `C:\Users\YOUR_USERNAME\AppData\Local\Pub\Cache\bin`

**macOS/Linux:**
```bash
export PATH="$PATH:$HOME/.pub-cache/bin"
```

### Google Sign-In Issues

1. Ensure SHA-1 certificate is added to Firebase:
```bash
cd android
./gradlew signingReport
```
2. Add SHA-1 to Firebase Console > Project Settings > Your App

### Phone Auth Not Working

Use test phone numbers in Firebase Console:
- Phone: `+1 650-555-3434`
- Code: `123456`

### Offline Data Not Syncing

Firestore offline persistence is enabled by default. Check:
```dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^4.3.0
  firebase_auth: ^6.1.3
  cloud_firestore: ^6.1.1
  google_sign_in: ^7.2.0
  
  # State & Utilities
  provider: ^6.1.5
  intl: ^0.20.2
  shared_preferences: ^2.5.4
  
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  change_app_package_name: ^1.5.0
  flutter_launcher_icons: ^0.14.4
```

---

## 🎨 Design Philosophy

This app follows a **functional, predictable, and calm** design approach:

- **No Fancy UI**: Professional and minimal
- **Custom Components**: All UI built from scratch
- **Smooth Transitions**: Subtle animations only
- **Offline-First**: Works in poor network conditions
- **High Performance**: Optimized for daily use under physical movement
- **Zero Cognitive Load**: Intuitive interactions

---

## 🔐 Security

- All data is user-scoped (users can only access their own data)
- Firestore security rules enforce authentication
- Offline data is encrypted by default
- Phone authentication uses Firebase test numbers only (production requires real phone verification)

---

## 🚢 Deployment

### Android

1. Generate signing key:
```bash
keytool -genkey -v -keystore ~/delivery_tracker.jks -keyalg RSA -keysize 2048 -validity 10000 -alias delivery_tracker
```

2. Create `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=delivery_tracker
storeFile=<path-to-jks>
```

3. Build release APK:
```bash
flutter build apk --release
```

### iOS

1. Open `ios/Runner.xcworkspace` in Xcode
2. Configure signing in project settings
3. Build:
```bash
flutter build ios --release
```

---

## 📈 Performance Optimization

- **Offline-first architecture** with Firestore persistence
- **Lazy loading** of customer lists
- **Efficient queries** with proper indexing
- **Minimal rebuilds** with Provider state management
- **Optimized images** and assets

---

## 🤝 Contributing

This is a production application. For improvements:

1. Fork the repository
2. Create a feature branch
3. Make changes with tests
4. Submit a pull request

---

## 📄 License

MIT License - feel free to use this code for your projects.

---

## 👤 Author

Built with Flutter for professional delivery tracking.

---

## 📞 Support

For issues or questions:
- Open an issue on GitHub
- Check troubleshooting section above
- Review Firebase documentation

---

## 🎯 Roadmap

- [ ] Multi-language support
- [ ] Export reports to PDF
- [ ] Route optimization
- [ ] Push notifications for status updates
- [ ] Dark mode
- [ ] Biometric authentication

---

## ⚠️ Important Notes

1. **Firebase Spark Plan**: This app uses only free Firebase features
2. **Test Phone Numbers**: Use Firebase test numbers for development
3. **Offline Mode**: App works fully offline with automatic sync
4. **Data Privacy**: All user data is isolated per user
5. **Production Ready**: Complete code with zero placeholders

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for reliable backend services
- FlutterFire for seamless Firebase integration

---

**Built with ❤️ By Ruhban Abdullah**
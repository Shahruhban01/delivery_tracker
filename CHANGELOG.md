# Changelog

All notable changes to Delivery Tracker will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-01-15

### 🎉 Initial Release

The first production-ready version of Delivery Tracker with complete delivery management functionality.

### Added

#### Core Features
- **Dual Sheet System**: Separate collections for runsheets (deliveries) and pickup sheets (returns)
- **Realtime Status Tracking**: Live updates for picked, delivered, and failed parcels
- **Customer Management**: Full CRUD operations with edit history tracking
- **Call Logging**: Track customer contact attempts with timestamps
- **Status Change History**: Complete audit trail for all status modifications
- **Drag-and-Drop Reordering**: Prioritize customers by dragging cards

#### Analytics & Reporting
- **Comprehensive Analytics Screen**: Multi-chart dashboard with date filtering
- **Delivery Analytics**: Success rate tracking with line charts
- **Returns Analytics**: Pickup completion monitoring
- **Fuel Analytics**: Daily cost tracking and averages
- **Date Range Filters**: Today, Yesterday, Last 7 Days, Last 15 Days, Custom Range
- **Visual Graphs**: Line charts, bar charts, and pie charts using fl_chart
- **Success Rate Metrics**: Real-time calculation of delivery performance

#### User Interface
- **Custom Pull-to-Refresh**: Smooth animated refresh without default Flutter widgets
- **Custom Drop-up Menu**: Animated sheet selection interface from + button
- **Dynamic Customer Cards**: Color-coded status indicators (yellow/red/green/olive)
  - 🟡 Yellow: 3 calls or undelivered by any reason
  - 🔴 Red: 5+ calls
  - 🟢 Green: Delivered status
  - 🫒 Olive Green: Confirmed (will accept)
- **Sheet Completion Detection**: Auto-detect when all customers are processed
- **Close Sheet Button**: Appears when sheet is complete, enables analytics
- **Closed Sheet Badge**: Visual indicator for archived sheets
- **Read-Only Mode**: Prevent edits to closed sheets

#### Settings & Configuration
- **User Settings Screen**: Centralized configuration management
- **Dark Mode Toggle**: Theme switching (implementation ready)
- **Default Petrol Cost**: Pre-fill fuel expenses for new sheets
- **Earning Per Parcel**: Configurable rate for automatic earnings calculation (default: ₹15)
- **Enable Confirmations**: Toggle action confirmation dialogs
- **Settings Persistence**: Local + Firestore sync for settings

#### Data Management
- **JSON Bulk Import**: Rapid sheet creation with customer data
- **Smart Defaults**:
  - Missing phone → `+91 1234567890`
  - Missing date → Today's date
  - Petrol cost → From user settings
- **Batch Operations**: Optimized Firestore writes for bulk customer creation
- **Customer Edit Dialog**: Modify name, phone, address, area with timestamp tracking
- **One-Time Picked Count**: Set `picked` field to total customers at sheet creation

#### Performance Optimizations
- **Reduced Firestore Reads**: From ~15 to ~3 reads per home screen load (80% reduction)
- **Batch Writes**: ~40% reduction in write operations
- **Indexed Queries**: Optimized compound indexes for fast retrieval
- **Incremental Updates**: Status changes update only affected fields
- **Offline-First Architecture**: Aggressive caching for seamless offline access
- **Stream Optimization**: RxDart for efficient combined stream handling

#### Technical Implementation
- **Custom Widgets Only**: Zero default Flutter widgets, fully custom UI
- **Provider State Management**: Clean architecture with separation of concerns
- **Firebase Integration**: Firestore + Authentication
- **Collection Structure**: User-scoped data with `userId` field filtering
- **Security Rules**: User-only access to their own data
- **Realtime Listeners**: StreamBuilder for live data updates

### Fixed
- Sheet counts now update in realtime when customer status changes
- Earnings auto-calculate based on delivered count × earning per parcel
- Color state transitions are smooth and animated
- Drop-up menu no longer causes transparent screen overlay
- Customer edit dialog properly persists changes with `lastEditedAt` timestamp

### Technical Details

#### Status Classification Rules
- **Pending**: Initial state, doesn't count in metrics
- **Confirmed (will accept)**: Doesn't affect delivered/failed counts
- **Delivered**: Increments delivered count, calculates earnings
- **Failed States**: All statuses except Pending, Delivered, Confirmed count as failed
  - Not Responding
  - Cancelled with Code (RTO)
  - Heavy Load
  - Reschedule
  - Custom failure reasons

#### Firestore Schema Version
- **v1.0**: Initial schema with user-scoped collections
- Collections: `runsheets`, `pickupSheets`, `customers`, `callLogs`, `statusChanges`, `settings`
- Required indexes: `dayId + order`, `userId + date`

#### Dependencies
- `flutter: SDK`
- `firebase_core: ^2.24.0`
- `cloud_firestore: ^4.13.0`
- `firebase_auth: ^4.15.0`
- `provider: ^6.1.0`
- `intl: ^0.18.0`
- `rxdart: ^0.27.0`
- `fl_chart: ^0.66.0`

---

## [Unreleased]

### Planned Features
- Multi-language support (Hindi, English)
- PDF export for analytics reports
- Route optimization suggestions
- Push notifications for status updates
- Team collaboration features
- Advanced search and filtering
- Signature capture on delivery
- Photo proof of delivery
- Customer feedback collection

---

## Version History

- **1.0.0** (2026-01-15) - Initial production release

---

[1.0.0]: https://github.com/shahruhban01/delivery_tracker/releases/tag/v1.0.0
[Unreleased]: https://github.com/shahruhban01/delivery_tracker/compare/v1.0.0...HEAD

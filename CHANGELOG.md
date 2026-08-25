# Changelog

All notable changes to the Catering Booking App will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned Features
- Push notifications untuk order confirmation
- Payment gateway integration (Midtrans/Xendit)
- QR code untuk pickup verification
- Admin dashboard untuk manage menu
- Rating & review system
- Promo code functionality
- Order scheduling (preorder)
- Multiple delivery addresses

---

## [1.0.0] - 2026-08-24

### Added
- **Authentication System**
  - Phone number OTP authentication
  - User registration with additional info (name, jurusan, kelas)
  - Login/logout functionality
  - Test phone numbers for development

- **Menu Management**
  - Browse available catering menus
  - View menu details (name, description, price, image)
  - Real-time menu updates from Firebase

- **Shopping Cart**
  - Add menu items to cart
  - Adjust item quantities
  - Remove items from cart
  - Real-time cart total calculation
  - Cart persistence across sessions

- **Checkout System**
  - Review order before submission
  - Order confirmation
  - Save order to Firebase
  - Generate unique order ID

- **Order History**
  - View all past orders
  - Order details (items, total, date)
  - Order status tracking
  - Sorted by creation date (newest first)

- **User Profile**
  - View user information
  - Edit profile data (name, jurusan, kelas)
  - Logout functionality

- **Navigation**
  - Bottom navigation bar
  - GoRouter for routing
  - Deep linking support
  - Route guards for authentication

- **UI/UX**
  - Material Design 3
  - Responsive layouts
  - Loading states
  - Error handling with user feedback
  - Custom color scheme (maroon theme)

- **Firebase Integration**
  - Firebase Authentication (Phone)
  - Firebase Realtime Database
  - Security rules for data protection
  - Multi-platform support (Android, iOS, Web, Windows, macOS, Linux)

- **State Management**
  - Riverpod for state management
  - Provider pattern for services
  - Stream-based real-time updates

- **Documentation**
  - Comprehensive README
  - Firebase setup guide
  - API documentation
  - Code comments

### Technical Details
- **Framework:** Flutter 3.x
- **Language:** Dart
- **State Management:** Riverpod
- **Backend:** Firebase (Auth + Realtime Database)
- **Routing:** GoRouter
- **Min SDK:** Android 21, iOS 12.0

### Code Quality
- Flutter analyze: 0 issues
- Proper error handling
- Type safety
- Null safety enabled
- Consistent code formatting
- Super parameter syntax

---

## Development Notes

### Version History Format
- **[Major]**: Breaking changes, major feature additions
- **[Minor]**: New features, non-breaking changes
- **[Patch]**: Bug fixes, minor improvements

### How to Read Changes
- **Added**: New features
- **Changed**: Changes in existing functionality
- **Deprecated**: Soon-to-be removed features
- **Removed**: Removed features
- **Fixed**: Bug fixes
- **Security**: Security improvements

---

## Upgrade Guide

### From 0.x.x to 1.0.0
This is the initial release, no upgrade needed.

---

## Known Issues

### v1.0.0
- [ ] Payment integration is placeholder only
- [ ] No admin panel yet (menu management via Firebase Console)
- [ ] Order cancellation not implemented
- [ ] No email/receipt generation
- [ ] Limited error messages in some edge cases

---

## Future Roadmap

### v1.1.0 (Q4 2026)
- [ ] Payment gateway integration
- [ ] Push notifications
- [ ] Email receipts
- [ ] Order cancellation feature
- [ ] Improved error messages

### v1.2.0 (Q1 2027)
- [ ] Admin dashboard
- [ ] QR code verification
- [ ] Rating & review system
- [ ] Analytics dashboard

### v2.0.0 (Q2 2027)
- [ ] Multiple user types (student, teacher, staff)
- [ ] School credit/point system
- [ ] Subscription plans
- [ ] Group orders

---

## Contributing

When adding changes to this changelog:

1. Add changes under **[Unreleased]** section
2. Group changes by type (Added, Changed, Fixed, etc.)
3. Use present tense ("Add feature" not "Added feature")
4. Reference issue numbers when applicable
5. Keep changes user-focused and clear

Example:
```markdown
### Added
- User profile picture upload (#42)
- Dark mode support (#38)

### Fixed
- Cart not updating after item removal (#45)
- OTP verification timeout issue (#41)
```

---

## Support

For issues and feature requests, please create an issue on the repository.

---

**Maintainer:** Development Team  
**Repository:** [GitHub](https://github.com/your-username/dc_multiplatforms)  
**License:** MIT

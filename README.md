# 📦 Inventory Management System (InvApp)

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Hive](https://img.shields.io/badge/Hive-Database-orange?style=for-the-badge)

A powerful, robust, and user-friendly **Inventory Management Application** built with Flutter. This application creates a seamless experience for Admins to manage stock, suppliers, and users, while providing Users with tools for billing and product viewing.

---

## ✨ Key Features

### 🛡️ Admin Capabilities
- **Dashboard Overview**: Visual analytics using charts to track inventory status.
- **Product Management**: Add, update, delete, and view product details efficiently.
- **Supplier Management**: Keep track of your supply chain partners.
- **User Management**: Control user access and roles.
- **Activity & Reporting**:
  - Detailed **Activity Logs** to track system changes.
  - Generate and export **PDF Reports** for inventory and sales.

### 👤 User Capabilities
- **Product Catalog**: Browse and search through available inventory.
- **Billing System**: Integrated billing features for seamless transactions.
- **Supplier View**: Access authorized supplier information.

### 🌍 Global Reach
- **Multi-language Support**: Fully localized in:
  - 🇺🇸 English
  - 🇪🇸 Spanish
  - 🇫🇷 French
- **Theme Support**: Consistent and professional UI design.

---

## � Screenshots

| Login Screen | Admin Dashboard |
|:---:|:---:|
| <img src="assets/screenshots/login_screen.png" width="300" /> | <img src="assets/screenshots/admin_dashboard.png" width="300" /> |
| **Product Management** | **User Store** |
| <img src="assets/screenshots/product_management.png" width="300" /> | <img src="assets/screenshots/user_store.png" width="300" /> |

---

## �🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **Language**: [Dart](https://dart.dev/)
- **Database**: [Hive](https://docs.hivedb.dev/) (NoSQL, fast local storage)
- **Charts**: `fl_chart` for data visualization.
- **PDF & Printing**: `pdf` and `printing` packages for report generation.
- **Icons**: `cupertino_icons` & Google Fonts.

---

## 🚀 Getting Started

Follow these steps to run the project locally.

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- An IDE (VS Code, Android Studio) set up for Flutter development.

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/invapp.git
   cd invapp
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   Select your target device (Emulator or Physical Device) and run:
   ```bash
   flutter run
   ```

---

## 📂 Project Structure

```
lib/
├── config/          # App configuration & Themes
├── l10n/            # Localization files (en, es, fr)
├── models/          # Hive Data Models
├── pages/           # Application Screens
│   ├── admin/       # Admin-specific views (Reports, Management)
│   ├── user/        # User-specific views (Billing, Store)
│   └── ...          # Auth pages (Login, Register)
├── widgets/         # Reusable UI Components
└── main.dart        # Entry point
```

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/yourusername/invapp/issues).

---

Made with ❤️ using Flutter

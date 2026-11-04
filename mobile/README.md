# DailyMart Flutter Mobile Application

A shopping mobile application built with **Flutter**, designed to connect to the **DailyMart Node.js/Express REST API backend**.

---

## Features Implemented

1. **Authentication**:
   - Registration and Login screens with real-time form validation.
   - Persistent JWT session storage (`shared_preferences`).
   - Auto-login on launch via `SplashScreen`.
   - Side Drawer profile view & logout action.
   - Quick-fill demo account button for instant assessment testing.

2. **Product Catalogue & Details**:
   - 34 DailyMart organic grocery products across 7 categories.
   - Live search bar with instant keyword filtering.
   - Horizontal category filter chips (`Vegetables`, `Fruits`, `Drinks`, `Instant`, `Dairy`, `Bakery`, `Grains`).
   - Responsive 2-column product grid with discount badges, price calculation, and quick "+ Add" action.
   - Product Details screen with multi-image gallery, category color accents, stock status badges, detailed description, and delivery features.

3. **Shopping Cart**:
   - Live synchronization with backend `/api/cart`.
   - Stepper controls to increment/decrement quantities with stock limits.
   - Item removal and clear cart dialog.
   - Free delivery threshold banner (Free delivery unlocked over ₹500).
   - Price breakdown (Subtotal, Delivery Fee, Total).

4. **Checkout & Order Simulation**:
   - Validated delivery address form (Full Name, Phone, Street, City, State, Postal Code).
   - Payment method toggle (Cash on Delivery vs Online Simulated).
   - Server-side price verification and stock decrement upon order creation.
   - Confirmation dialog with order number, amount, and direct navigation to order details.

5. **Order History & Status Tracking**:
   - Real-time list of all placed orders.
   - Visual 4-step status progress tracker (`Pending` -> `Processing` -> `Shipped` -> `Delivered`).
   - Itemized product snapshots and delivery address review.

6. **Comprehensive UX States**:
   - Loading spinners & skeletons (`LoadingView`).
   - Clean empty states with custom illustrations (`EmptyView`).
   - Error banners with retry buttons (`ErrorView`).
   - SnackBar toasts for feedback.

---

## Project Structure

```
mobile/
├── assets/                     # Local DailyMart grocery assets & images
├── lib/
│   ├── core/
│   │   ├── constants/          # API endpoints, platform base URLs, colors
│   │   ├── network/            # HTTP API client, token interceptor, error parser
│   │   └── theme/              # Material 3 light theme configuration
│   ├── models/                 # UserModel, ProductModel, CartModel, OrderModel
│   ├── providers/              # AuthProvider, ProductProvider, CartProvider, OrderProvider
│   ├── services/               # REST API service calls (Auth, Products, Cart, Orders)
│   ├── screens/
│   │   ├── splash/             # Startup session check screen
│   │   ├── auth/               # Login & Registration screens
│   │   ├── catalog/            # Home shopping grid, search & details
│   │   ├── cart/               # Shopping cart & subtotal summary
│   │   ├── checkout/           # Delivery address form & placement
│   │   └── orders/             # Order history & timeline details
│   ├── widgets/                # CustomButton, CustomTextField, ProductCard, CategoryChip, etc.
│   └── main.dart               # MultiProvider initialization & app entry point
└── pubspec.yaml
```

---

## How to Run the Flutter App

### 1. Ensure the Backend is Running
Before starting the Flutter app, ensure the backend server is running on port 5000:
```bash
cd backend
npm start
```
*(The backend will run on `http://localhost:5000`)*.

### 2. Install Dependencies
Navigate into the `mobile/` directory:
```bash
cd mobile
flutter pub get
```

### 3. Launch on Your Preferred Platform

- **Run in Chrome / Edge (Web)**:
  ```bash
  flutter run -d chrome
  ```
- **Run on Android Emulator**:
  ```bash
  flutter run
  ```
  *(Note: The app automatically routes to `http://10.0.2.2:5000` on Android emulator to connect to your host machine)*.
- **Run on iOS Simulator / macOS**:
  ```bash
  flutter run
  ```

---

## Default Demo Credentials
- **Email**: `demo@dailymart.com`
- **Password**: `password123`
*(A "Quick Fill Demo Account" button is also provided on the Login screen)*.


# DailyMart — Full-Stack E-Commerce Platform

A production-ready full-stack grocery shopping platform built with a **Node.js/Express** REST API backend, backed by **MongoDB Atlas**, and a **Flutter** mobile client with Provider state management.

---

## Tech Stack

- **Backend**: Node.js, Express.js, MongoDB (Mongoose), JWT Authentication, bcryptjs, express-validator
- **Mobile Frontend**: Flutter, Dart, Provider (State Management), CachedNetworkImage, Shared Preferences
- **Database**: MongoDB Atlas (Cloud) / MongoDB Local with auto-seeding
- **API Testing**: Postman Collection (`postman/E-commerce.postman_collection.json`)

---

## Project Structure

```
E-commerce Platform/
├── backend/                               # Node.js + Express REST API Server
│   ├── src/
│   │   ├── config/                        # Database connection & memory fallback
│   │   ├── controllers/                   # Auth, Products, Cart, Orders controllers
│   │   ├── middlewares/                   # JWT verification, express-validator, error handler
│   │   ├── models/                        # Mongoose models (User, Product, Cart, Order)
│   │   ├── routes/                        # Express API routes
│   │   └── seeders/                       # 34 DailyMart sample products seeder
│   ├── .env                               # Environment configuration (git-ignored)
│   ├── .env.example                       # Example configuration
│   ├── server.js                          # Entry point (binds to 0.0.0.0:5000)
│   ├── test_api.js                        # 19 automated API tests suite
│   └── package.json
│
├── mobile/                                # Flutter Mobile Application
│   ├── android/                           # Android native project with DailyMart launcher icon
│   ├── assets/                            # Product images and promotional banner
│   ├── lib/
│   │   ├── core/                          # Theme, colors, API client, top-sliding toasts
│   │   ├── models/                        # User, Product, Cart, Order models
│   │   ├── providers/                     # State management (Auth, Products, Cart, Orders)
│   │   ├── screens/                       # Auth, Catalog, Details, Cart, Checkout, Orders
│   │   ├── services/                      # HTTP API services
│   │   ├── widgets/                       # Product card, status badges, custom buttons
│   │   └── main.dart                      # Flutter application entry point
│   ├── test/                              # Automated widget smoke tests
│   └── pubspec.yaml
│
├── postman/                               # Postman API Collection
│   └── E-commerce.postman_collection.json # Exported endpoints & tests
│
└── README.md
```

---

## Setup & Execution Guide

### Prerequisites
1. **Node.js**: v18.0.0 or higher
2. **Flutter SDK**: v3.27.0 or higher
3. **Android Device / Emulator**: USB Debugging enabled (or Android Studio Emulator)

---

### Part 1: Backend Setup & Execution

#### 1. Navigate to backend directory:
```bash
cd "E-commerce Platform/backend"
```

#### 2. Install dependencies:
```bash
npm install
```

#### 3. Configure `.env`:
Create or edit `backend/.env` with your settings:
```env
PORT=5000
NODE_ENV=development
MONGODB_URI=mongodb+srv://<username>:<password>@cluster0.vghypl8.mongodb.net/dailymart
JWT_SECRET=dailymart_super_secret_jwt_key_2026_secure
JWT_EXPIRES_IN=7d
USE_MEMORY_DB_IF_LOCAL_FAILS=true
```

#### 4. Run the backend server:
- **Development mode (with auto-reload via nodemon)**:
  ```bash
  npm run dev
  ```
- **Standard start**:
  ```bash
  npm start
  ```

Console output on startup:
```
MongoDB Connected successfully: <host>
Server running on port 5000
```

#### 5. Run automated backend tests (19 tests):
```bash
npm run test:api
```

#### Troubleshooting `EADDRINUSE: port 5000 already in use`:
If port 5000 is occupied by a background process, run in PowerShell:
```powershell
Get-Process -Id (Get-NetTCPConnection -LocalPort 5000).OwningProcess | Stop-Process -Force
```

---

### Part 2: Mobile (Flutter) Setup & Execution

#### 1. Navigate to mobile directory:
```bash
cd "E-commerce Platform/mobile"
```

#### 2. Install Flutter packages:
```bash
flutter pub get
```

#### 3. Configure API Base URL:
Check `lib/core/constants/api_constants.dart`:
- **Physical Device over USB**: Run `adb reverse tcp:5000 tcp:5000` on your PC, and the app connects to `127.0.0.1:5000`.
- **Physical Device over Wi-Fi**: Set `serverHost` to your PC's IP address (e.g. `192.168.1.14`).
- **Android Emulator**: Uses `10.0.2.2:5000`.

#### 4. Run the app on your connected device:
```bash
flutter run
```

---

## API Endpoints Reference

Import [`postman/E-commerce.postman_collection.json`](file:///c:/Users/sheet/Documents/E-commerce%20Platform/postman/E-commerce.postman_collection.json) directly into Postman to test all endpoints:

### Authentication (`/api/auth`)
| Method | Endpoint | Description | Access |
|---|---|---|---|
| `POST` | `/api/auth/register` | Register a new customer | Public |
| `POST` | `/api/auth/login` | Sign in & receive JWT token | Public |
| `POST` | `/api/auth/logout` | Sign out & invalidate session | Public |
| `GET` | `/api/auth/me` | Fetch authenticated user profile | Private |

### Product Catalog (`/api/products`)
| Method | Endpoint | Description | Access |
|---|---|---|---|
| `GET` | `/api/products` | Fetch all products (supports `?search=` and `?category=`) | Public |
| `GET` | `/api/products/categories` | Distinct categories with counts | Public |
| `GET` | `/api/products/:id` | Fetch single product details | Public |

### Shopping Cart (`/api/cart`)
| Method | Endpoint | Description | Access |
|---|---|---|---|
| `GET` | `/api/cart` | Get current user's cart | Private |
| `POST` | `/api/cart/items` | Add product to cart | Private |
| `PATCH` | `/api/cart/items/:id` | Update item quantity | Private |
| `DELETE` | `/api/cart/items/:id` | Remove item from cart | Private |
| `DELETE` | `/api/cart` | Clear entire cart | Private |

### Orders & Checkout (`/api/orders`)
| Method | Endpoint | Description | Access |
|---|---|---|---|
| `POST` | `/api/orders` | Place new order (backend validates stock & decrements) | Private |
| `GET` | `/api/orders` | Get user order history | Private |
| `GET` | `/api/orders/:id` | Get detailed order snapshot | Private |
| `PATCH` | `/api/orders/:id/status` | Update order delivery status | Private |

---

## Git Commands to Push to GitHub

From the project root (`E-commerce Platform/`):

```bash
git add .
git commit -m "Organized Postman collection into dedicated postman/ directory, refactored project structure"
git branch -M main
git push -u origin main
```

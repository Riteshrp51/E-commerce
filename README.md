# GreenCart — Full-Stack E-Commerce Platform

A production-ready full-stack grocery shopping platform built with a **Node.js/Express** REST API backend, backed by **MongoDB Atlas**, and a **Flutter** mobile client with Provider state management.

---

## Tech Stack

- **Backend**: Node.js, Express.js, MongoDB (Mongoose), JWT Authentication, bcryptjs, express-validator
- **Mobile Frontend**: Flutter, Dart, Provider (State Management), CachedNetworkImage, Shared Preferences
- **Database**: MongoDB Atlas (Cloud) / MongoDB Local with auto-seeding

---

## Project Structure

```
E-commerce Platform/
├── backend/                       # Node.js + Express REST API Server
│   ├── src/
│   │   ├── config/                # Database connection & memory fallback
│   │   ├── controllers/           # Auth, Products, Cart, Orders controllers
│   │   ├── middlewares/           # JWT verification, express-validator, error handler
│   │   ├── models/                # Mongoose models (User, Product, Cart, Order)
│   │   ├── routes/                # Express API routes
│   │   └── seeders/               # 34 GreenCart sample products seeder
│   ├── .env                       # Environment configuration
│   ├── .env.example               # Example configuration
│   ├── server.js                  # Entry point (binds to 0.0.0.0:5000 for LAN & Wi-Fi)
│   └── package.json
│
├── mobile/                        # Flutter Mobile Application
│   ├── android/                   # Android native project with GreenCart launcher icon
│   ├── assets/                    # Product images and promotional banner
│   ├── lib/
│   │   ├── core/                  # Theme, colors, API client, top-sliding toasts
│   │   ├── models/                # User, Product, Cart, Order models
│   │   ├── providers/             # State management (Auth, Products, Cart, Orders)
│   │   ├── screens/               # Auth, Catalog, Details, Cart, Checkout, Orders
│   │   ├── services/              # HTTP API services
│   │   ├── widgets/               # Product card, status badges, custom buttons
│   │   └── main.dart              # Flutter application entry point
│   └── pubspec.yaml
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
MONGODB_URI=mongodb+srv://<username>:<password>@cluster0.vghypl8.mongodb.net/
JWT_SECRET=greencart_super_secret_jwt_key_2026_secure
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

> **Auto-Seeding**: On startup, if the database is empty, the server automatically seeds 34 GreenCart products across 7 categories (`Vegetables`, `Fruits`, `Dairy`, `Drinks`, `Grains`, `Bakery`, `Instant`).

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
- **Physical Device over Wi-Fi**: Use your computer's Wi-Fi IP (e.g. `http://192.168.1.14:5000/api`)
- **Android Emulator**: Use `http://10.0.2.2:5000/api`

#### 4. Run the app on your connected device:
```bash
flutter run
```

---

## API Endpoints Reference

### Authentication (`/api/auth`)
| Method | Endpoint | Description | Access |
|---|---|---|---|
| `POST` | `/api/auth/register` | Register a new customer | Public |
| `POST` | `/api/auth/login` | Sign in & receive JWT token | Public |
| `POST` | `/api/auth/logout` | Sign out & invalidate session | Public |

### Product Catalog (`/api/products`)
| Method | Endpoint | Description | Access |
|---|---|---|---|
| `GET` | `/api/products` | Fetch all products (supports `?search=` and `?category=`) | Public |
| `GET` | `/api/products/:id` | Fetch single product details | Public |

### Shopping Cart (`/api/cart`)
| Method | Endpoint | Description | Access |
|---|---|---|---|
| `GET` | `/api/cart` | Get current user's cart | Private |
| `POST` | `/api/cart` | Add product to cart | Private |
| `PUT` | `/api/cart/:productId` | Update item quantity | Private |
| `DELETE` | `/api/cart/:productId` | Remove item from cart | Private |
| `DELETE` | `/api/cart` | Clear entire cart | Private |

### Orders & Checkout (`/api/orders`)
| Method | Endpoint | Description | Access |
|---|---|---|---|
| `POST` | `/api/orders` | Place new order (backend validates stock & decrements) | Private |
| `GET` | `/api/orders` | Get user order history | Private |
| `GET` | `/api/orders/:id` | Get detailed order snapshot | Private |

---

## Git Commands to Push to GitHub

From the project root (`E-commerce Platform/`):

```bash
# 1. Initialize git
git init

# 2. Stage all files (respects root .gitignore)
git add .

# 3. Commit changes
git commit -m "Implemented complete GreenCart e-commerce shopping platform with Flutter mobile app and Node.js backend"

# 4. Set default branch to main
git branch -M main

# 5. Link to your GitHub repository
git remote add origin <YOUR_GITHUB_REPO_URL>

# 6. Push to GitHub
git push -u origin main
```

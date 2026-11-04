# DailyMart — E-Commerce Grocery Platform

A full-stack grocery shopping application with a **Node.js/Express** backend (MongoDB Atlas) and a **Flutter** mobile client.

---

## Project Structure

- **`backend/`**: Express REST API server, authentication, product catalog, cart, and orders.
- **`mobile/`**: Flutter mobile app with product browsing, real-time stock tracking, and checkout.
- **`postman/`**: `E-commerce.postman_collection.json` containing ready-to-test API requests.

---

## 1. Backend Setup

### Prerequisites
- Node.js (v18+)
- MongoDB Atlas account (or local MongoDB)

### Steps
```bash
cd backend
npm install
```

Create a `backend/.env` file:
```env
PORT=5000
NODE_ENV=development
MONGODB_URI=mongodb+srv://<username>:<password>@cluster0.vghypl8.mongodb.net/dailymart
JWT_SECRET=dailymart_super_secret_jwt_key_2026_secure
JWT_EXPIRES_IN=7d
```

### Start Server
```bash
npm run dev
```

*The server starts on port `5000` and automatically connects to MongoDB.*

To run the automated test suite (19 tests):
```bash
npm run test:api
```

---

## 2. Mobile App Setup (Flutter)

### Prerequisites
- Flutter SDK (v3.27+)
- Android device or emulator with USB debugging enabled

### Steps
```bash
cd mobile
flutter pub get
```

### Connecting to Backend
- **Physical Phone via USB**: Run this command on your PC so the phone can reach port 5000:
  ```bash
  adb reverse tcp:5000 tcp:5000
  ```
- **Physical Phone via Wi-Fi**: Set your PC's Wi-Fi IP in `mobile/lib/core/constants/api_constants.dart`.
- **Android Emulator**: Automatically uses `10.0.2.2:5000`.

### Run the App
```bash
flutter run
```

---

## 3. Postman Collection

Import `postman/E-commerce.postman_collection.json` directly into Postman to test all endpoints (Auth, Products, Cart, Orders).

---

## 4. Git Push to GitHub

```bash
git add .
git commit -m "Updated permanent stock deduction on order, real-time stock UI, and simplified README"
git branch -M main
git push -u origin main
```

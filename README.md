<div align="center">

# 🌷 Bloom Flowers

### **A modern flower-commerce experience built with Flutter.**

*Discover beautiful flowers. Shop effortlessly. Deliver with care.*

<br>

[![Flutter](https://img.shields.io/badge/Flutter-3.44%2B-02569B?style=for-the-badge\&logo=flutter\&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.12%2B-0175C2?style=for-the-badge\&logo=dart\&logoColor=white)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-FFCA28?style=for-the-badge\&logo=firebase\&logoColor=black)](https://firebase.google.com/)
[![Cloudinary](https://img.shields.io/badge/Cloudinary-Media-3448C5?style=for-the-badge\&logo=cloudinary\&logoColor=white)](https://cloudinary.com/)
[![Material\_3](https://img.shields.io/badge/Material_3-Design-6750A4?style=for-the-badge)](https://m3.material.io/)

</div>

---

## 🌸 Overview

**Bloom Flowers** is a full-featured mobile flower-commerce application built with **Flutter and Dart**.

The app provides two connected experiences:

* 🌷 **Customer:** browse flowers, search and filter products, manage favourites and cart, checkout, and track orders.
* 🌿 **Admin:** manage products, categories, inventory, and customer orders.

Bloom was designed as a complete commerce workflow rather than a collection of independent screens.

---

## ✨ Features

### 🌷 Customer

* Authentication with Firebase
* Home and product discovery
* Search and category filtering
* Product details
* Favourites
* Cloud-synced shopping cart
* Inventory-aware checkout
* Order history and tracking
* Profile management
* Responsive UI
* Custom animations and loading states

### 🌿 Admin

* Admin dashboard
* Product management
* Category management
* Inventory management
* Order management
* Order status updates
* Revenue and pending-order overview

---

## 🧠 Key Engineering Decisions

### Transaction-Safe Inventory

Critical cart and checkout operations use **Firestore transactions** to validate and update inventory safely.

```text
Read Stock
    ↓
Validate Quantity
    ↓
Update Inventory
    ↓
Complete Operation
```

### Order Snapshots

When an order is created, product information such as **name, image, price, and quantity** is stored with the order.

This keeps historical orders accurate even if the original product is later changed or removed.

### Cloudinary Image Hosting

Product images are uploaded to **Cloudinary**, while Firestore stores only the resulting image URLs.

```text
Flutter → Cloudinary → Image URL → Firestore
```

### Role-Based Experience

Customers and administrators use the same application but are routed to different experiences based on their stored role.

```text
Authentication
      ↓
 ┌────┴────┐
 ↓         ↓
Customer  Admin
 ↓         ↓
User App  Admin App
```

### Layered Architecture

The project separates UI, business logic, and backend operations:

```text
Screens
   ↓
Services
   ↓
Firebase / Cloudinary
```

This keeps backend logic out of individual screens and makes the application easier to maintain and extend.

> **Screens render. Services perform. Models translate.**

---

## 🏗️ Project Structure

```text
lib/
├── models/
├── services/
├── screens/
│   ├── auth/
│   ├── onboarding/
│   ├── splash/
│   ├── user/
│   ├── admin/
│   └── profile/
├── widgets/
└── theme/
```

The main responsibilities are separated into reusable **models, services, screens, widgets, and theme components**.

---

## 🗃️ Data Model

Bloom uses **Cloud Firestore** as its primary application database.

```text
users/{uid}
├── cart/{productId}

products/{productId}

categories/{categoryId}

favorites/{userId_productId}

orders/{orderId}
```

### Core Data

**Users**

* name
* email
* role
* phone
* profile information
* address

**Products**

* name
* price
* description
* category
* quantity
* image URL

**Orders**

* customer information
* purchased items
* total amount
* status
* creation date

Order lifecycle:

```text
Pending
   ↓
Processing
   ↓
Out for Delivery
   ↓
Delivered
```

---

## 🎨 Design

Bloom uses a custom design system built with **Material 3**.

### Visual Language

* 🌿 Forest green
* 🌸 Coral
* 🤎 Ink
* 🏺 Terracotta
* 🤍 Cream

### Typography

* **Cormorant Garamond** — headings and brand identity
* **Poppins** — interface text

The UI also includes subtle animations, custom transitions, responsive layouts, loading states, and empty states.

---

## 🛠️ Tech Stack

| Technology                  | Purpose                           |
| --------------------------- | --------------------------------- |
| **Flutter**                 | Cross-platform mobile development |
| **Dart**                    | Application language              |
| **Firebase Authentication** | Authentication                    |
| **Cloud Firestore**         | Database & real-time data         |
| **Cloudinary**              | Image hosting                     |
| **SharedPreferences**       | Lightweight local storage         |
| **Material 3**              | UI foundation                     |
| **Google Fonts**            | Typography                        |
| **Image Picker**            | Image selection                   |
| **HTTP**                    | Network communication             |

---

## 🚀 Getting Started

### Prerequisites

* Flutter SDK
* Dart SDK
* Android Studio or Xcode
* Firebase project
* Cloudinary account
* Git

### Clone

```bash
git clone https://github.com/HebaRabaya/Bloom_app.git
cd Bloom_app
```

### Install Dependencies

```bash
flutter pub get
```

### Configure Firebase

Set up Firebase for the target platform and ensure the generated Firebase configuration is included in the project.

### Run

```bash
flutter run
```

---

## 📌 Project Status

**Active Development**

Bloom is currently a functional Flutter commerce application with customer and admin workflows powered by **Firebase and Cloudinary**.

---

<div align="center">

## 🌷 Bloom Flowers

*Fresh flowers. Softer days.*

**Designed with intention.
Built with Flutter.**

⭐ If you find the project interesting, consider giving the repository a star.

</div>

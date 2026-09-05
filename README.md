<div align="center">

# 🌷 Bloom Flowers

### **A modern flower-commerce experience built with Flutter.**

*Discover beautiful flowers. Shop effortlessly. Deliver with care.*

<br>

[![Flutter](https://img.shields.io/badge/Flutter-3.44%2B-02569B?style=for-the-badge\&logo=flutter\&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.12%2B-0175C2?style=for-the-badge\&logo=dart\&logoColor=white)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-FFCA28?style=for-the-badge\&logo=firebase\&logoColor=black)](https://firebase.google.com/)
[![Cloudinary](https://img.shields.io/badge/Cloudinary-Media-3448C5?style=for-the-badge\&logo=cloudinary\&logoColor=white)](https://cloudinary.com/)
[![Material 3](https://img.shields.io/badge/Material_3-Design-6750A4?style=for-the-badge)](https://m3.material.io/)

<br>

**Bloom is not just a flower catalog.**
It is a complete mobile commerce experience designed around discovery, trust, simplicity, and operational control.

</div>

---

## 🌸 What is Bloom?

**Bloom Flowers** is a full-featured mobile flower-commerce application built with **Flutter and Dart**.

The application connects two sides of the business inside one system:

* 🌷 **Customers** discover and purchase flowers.
* 🌿 **Administrators** manage products, categories, inventory, and orders.

The goal was to build more than a collection of screens.

Bloom was designed as a **real-world commerce workflow** where authentication, product data, inventory, cart operations, checkout, orders, and administration work together as one system.

---

## ⚡ At a Glance

| Area                | Implementation                               |
| ------------------- | -------------------------------------------- |
| Mobile Framework    | Flutter                                      |
| Language            | Dart                                         |
| Authentication      | Firebase Authentication                      |
| Database            | Cloud Firestore                              |
| Image Hosting       | Cloudinary                                   |
| Local Storage       | SharedPreferences                            |
| UI                  | Material 3 + Custom Design System            |
| Architecture        | Layered Architecture                         |
| State / Reactive UI | Flutter state management + Firestore streams |
| Platforms           | Android / iOS                                |
| User Roles          | Customer / Admin                             |

---

# ✨ Core Experience

Bloom is built around a simple journey:

```text
Discover
   ↓
Explore
   ↓
Choose
   ↓
Customize Cart
   ↓
Checkout
   ↓
Track Order
   ↓
Receive
```

At the same time, the admin side manages the operational workflow:

```text
Products
   ↓
Inventory
   ↓
Orders
   ↓
Processing
   ↓
Delivery
   ↓
Completed
```

---

# 🌷 Customer Experience

### 🏠 Home

A curated shopping experience where users can:

* Browse featured flowers
* Explore categories
* Discover products
* Navigate quickly through the store
* Access personalized shopping actions

---

### 🔎 Search & Categories

Users can discover products through:

* Product search
* Category filtering
* Product collections
* Dynamic Firestore data

The catalogue is not hardcoded into the UI.

---

### 🌹 Product Details

Each product provides:

* Product image
* Name
* Description
* Price
* Category
* Available quantity
* Add-to-cart functionality
* Favourite functionality

---

### 🛒 Smart Cart

The cart supports:

* Quantity management
* Product removal
* Automatic total calculation
* Inventory-aware operations
* Persistent cloud storage

Cart data is stored under the authenticated user's Firestore document:

```text
users/{uid}/cart/{productId}
```

This keeps cart data isolated per customer.

---

### 💳 Checkout

Checkout is treated as a **business transaction**, not simply a button press.

During checkout Bloom:

1. Reads the current cart.
2. Validates product availability.
3. Validates inventory.
4. Creates an order snapshot.
5. Decreases inventory.
6. Clears the user's cart.

This prevents inconsistent inventory states.

---

### 📦 Orders & Tracking

Customers can:

* View previous orders
* See order details
* Follow order status
* Review purchased products
* Track the delivery lifecycle

Order statuses:

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

### ❤️ Favourites

Users can save products for later.

Favourite records use deterministic IDs:

```text
{userId}_{productId}
```

This makes the operation predictable and prevents duplicate favourite records.

---

### 👤 Profile

Users can manage their personal information including:

* Name
* Phone
* Age
* Bio
* Address
* Profile image

Profile updates use partial Firestore writes so unrelated account data is not accidentally overwritten.

---

# 🌿 Admin Studio

Bloom also includes a dedicated administration experience.

The admin can manage the store without modifying application code.

### 📊 Dashboard

Provides a central view of the store's operational data, including:

* Orders
* Revenue
* Pending work
* Product information
* Inventory-related information

---

### 🌹 Product Management

Admins can:

* Add products
* Update products
* Manage prices
* Manage descriptions
* Assign categories
* Update inventory
* Upload product images

---

### 🌱 Category Management

Admins can create and manage the categories used by the customer catalogue.

---

### 📦 Order Management

Admins can:

* Review orders
* Inspect customer information
* Update order status
* Follow the delivery lifecycle
* Manage cancelled orders

When an order is cancelled, inventory can be restored appropriately.

---

# 🧠 Engineering Decisions

The most important part of Bloom is not the UI.

It is the engineering decisions behind the UI.

---

## 1. Transaction-Safe Inventory

A major challenge in e-commerce applications is inventory consistency.

A simple implementation might do:

```text
Read stock
↓
Decrease stock
↓
Save
```

But concurrent operations can produce incorrect inventory.

Bloom uses Firestore transactions for critical inventory operations.

Conceptually:

```text
Read current product state
        ↓
Validate available quantity
        ↓
Update inventory atomically
        ↓
Complete operation
```

This protects the integrity of stock during cart and checkout operations.

---

## 2. Order Snapshots

Orders do not depend on the current product catalogue.

When an order is created, Bloom stores the relevant product information inside the order:

```text
Order
 ├── product name
 ├── product image
 ├── price at purchase
 └── quantity
```

Therefore, if a product is renamed, repriced, or removed later, the historical order remains accurate.

This is an intentional **data snapshot strategy**.

---

## 3. Cloudinary for Product Images

Product images are hosted through **Cloudinary**, while Firestore stores the resulting URLs.

```text
Flutter
   ↓
Cloudinary
   ↓
Image URL
   ↓
Firestore
```

This keeps binary image data outside Firestore and lets the database focus on application data.

---

## 4. Role-Based Application

Bloom supports different experiences depending on the authenticated user's role.

```text
                 Authentication
                       │
             ┌─────────┴─────────┐
             ↓                   ↓
          Customer              Admin
             │                   │
             ↓                   ↓
        UserMainScreen      AdminMainScreen
```

The role is stored in the user's Firestore document and resolved after authentication.

---

## 5. Layered Architecture

Bloom separates responsibilities instead of placing Firebase logic directly inside every screen.

```text
┌─────────────────────────────┐
│           Screens           │
│     UI + User Interaction   │
└──────────────┬──────────────┘
               ↓
┌─────────────────────────────┐
│          Services           │
│ Authentication / Orders /   │
│ Profile / Business Logic    │
└──────────────┬──────────────┘
               ↓
┌─────────────────────────────┐
│        Firebase / API       │
│ Auth / Firestore / Cloudinary│
└─────────────────────────────┘
```

This makes the project easier to maintain and extend.

### Design principle

> **Screens render. Services perform. Models translate.**

---

# 🏗️ Project Structure

```text
lib/
│
├── main.dart
│
├── models/
│   ├── product.dart
│   ├── cart_item.dart
│   ├── order.dart
│   └── ...
│
├── services/
│   ├── auth_service.dart
│   ├── order_service.dart
│   ├── profile_service.dart
│   ├── product_service.dart
│   └── ...
│
├── screens/
│   │
│   ├── splash/
│   ├── onboarding/
│   │
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   │
│   ├── user/
│   │   ├── user_main_screen.dart
│   │   ├── user_home_screen.dart
│   │   ├── search_screen.dart
│   │   ├── product_details_screen.dart
│   │   ├── cart_screen.dart
│   │   ├── checkout_screen.dart
│   │   ├── favorites_screen.dart
│   │   └── my_orders_screen.dart
│   │
│   ├── admin/
│   │   ├── admin_main_screen.dart
│   │   ├── admin_home_screen.dart
│   │   ├── add_product_screen.dart
│   │   ├── categories_screen.dart
│   │   └── orders_screen.dart
│   │
│   └── profile/
│
├── widgets/
│   ├── bloom_logo.dart
│   ├── bloom_animations.dart
│   ├── bloom_auth_widgets.dart
│   └── ...
│
└── theme/
    ├── app_assets.dart
    ├── app_colors.dart
    └── app_theme.dart
```

---

# 🚀 Application Startup

Bloom has a controlled startup flow instead of immediately navigating to a random screen.

```text
App Launch
    ↓
Flutter Initialization
    ↓
Firebase Initialization
    ↓
Branded Splash
    ↓
Authentication Check
    ↓
Role Resolution
    ↓
┌───────────────┬────────────────┐
│               │                │
Admin         Customer        Guest
│               │                │
↓               ↓                ↓
Admin App     User App       Onboarding/Login
```

The splash experience also runs its visual animation while startup services are being resolved.

---

# 🔐 Authentication

Bloom uses **Firebase Authentication** for account management.

Current authentication flow includes:

* Email & password registration
* Email & password login
* Email verification support
* Password reset
* Persistent Firebase authentication session
* Role resolution after login

The application separates authentication logic from the UI through `AuthService`.

---

# 🗃️ Firestore Data Model

Bloom uses Firestore as its primary application database.

### Users

```text
users/{uid}
```

Example fields:

```text
name
email
role
phone
bio
age
imageUrl
address
```

---

### Cart

```text
users/{uid}/cart/{productId}
```

---

### Products

```text
products/{productId}
```

Example:

```text
name
price
description
category
quantity
imageUrl
createdAt
updatedAt
```

---

### Categories

```text
categories/{categoryId}
```

---

### Favourites

```text
favorites/{userId_productId}
```

---

### Orders

```text
orders/{orderId}
```

Example:

```text
userId
userName
userPhone
address
items[]
totalAmount
status
createdAt
```

---

# ⚡ Real-Time Data

Where real-time behaviour matters, Bloom uses Firestore streams.

This allows parts of the application to react to backend changes instead of relying entirely on manual refreshes.

Conceptually:

```text
Firestore
    │
    │ Stream
    ↓
Flutter
    │
    ↓
UI updates automatically
```

This is particularly useful for order-related and catalogue experiences.

---

# 🎨 Design System

Bloom uses a custom visual language instead of relying only on default Material widgets.

### Core Palette

| Token      | Purpose              |
| ---------- | -------------------- |
| Cream      | Main background      |
| Forest     | Primary brand colour |
| Ink        | Main text            |
| Terracotta | Supporting accent    |
| Coral      | Highlight / action   |

### Typography

**Cormorant Garamond**

Used for expressive headings and brand moments.

**Poppins**

Used for readable interface text and supporting information.

---

# ✨ Motion & Interaction

Bloom uses subtle motion to make the interface feel alive without overwhelming the user.

Examples include:

* Fade + slide entrance animations
* Press scale feedback
* Custom page transitions
* Animated splash experience
* Smooth navigation
* Loading states
* Empty states

The goal is:

> **Motion should communicate, not distract.**

---

# 📱 Responsive UI

The interface is designed with different screen sizes in mind.

Bloom uses reusable responsive helpers for:

* Grid column counts
* Page padding
* Text scaling
* Layout spacing
* Content density

The application also clamps text scaling where necessary to protect important UI layouts from extreme overflow.

---

# 💾 Local vs Cloud State

Bloom intentionally separates local and cloud responsibilities.

### Local

**SharedPreferences** is used for lightweight local state such as:

```text
hasSeenOnboarding
```

### Cloud

Firebase handles persistent application state such as:

```text
Authentication
Users
Products
Cart
Orders
Categories
Favourites
```

This separation keeps local storage lightweight while keeping business data synchronized.

---

# 🛍️ End-to-End Shopping Flow

A complete customer journey looks like this:

```text
Launch
  ↓
Onboarding
  ↓
Login / Sign Up
  ↓
Home
  ↓
Browse Categories
  ↓
Search Product
  ↓
Product Details
  ↓
Add to Cart
  ↓
Cart
  ↓
Checkout
  ↓
Order Created
  ↓
Order Tracking
  ↓
Delivered
```

Behind the scenes:

```text
Customer Action
      ↓
Flutter Screen
      ↓
Service Layer
      ↓
Firestore / Cloudinary
      ↓
Updated Application State
      ↓
UI
```

---

# 🛠️ Technology Stack

| Technology                  | Role                              |
| --------------------------- | --------------------------------- |
| **Flutter**                 | Cross-platform mobile development |
| **Dart**                    | Application language              |
| **Firebase Authentication** | User authentication               |
| **Cloud Firestore**         | Application database              |
| **Cloudinary**              | Image hosting                     |
| **SharedPreferences**       | Lightweight local persistence     |
| **Material 3**              | UI foundation                     |
| **Google Fonts**            | Typography                        |
| **Image Picker**            | Image selection                   |
| **HTTP**                    | Network communication             |
| **flutter_native_splash**   | Native launch screen              |

---

# 📦 Important Packages

```yaml
firebase_core
firebase_auth
cloud_firestore
shared_preferences
image_picker
google_fonts
flutter_native_splash
http
```

Each dependency has a specific responsibility rather than being added simply for convenience.

---

# 🧪 Data Integrity & Edge Cases

Bloom does not assume that every operation succeeds.

The application considers cases such as:

* Missing products
* Out-of-stock products
* Invalid quantities
* Empty cart
* Cancelled orders
* Authentication failures
* Network/database failures
* Missing profile data
* Loading states
* Empty states

The goal is to make failure states part of the product design, not an afterthought.

---

# 🔄 Checkout Logic

The checkout process can be summarized as:

```text
Start Transaction
       ↓
Read Cart
       ↓
Read Products
       ↓
Validate Products
       ↓
Validate Stock
       ↓
Create Order Snapshot
       ↓
Decrease Inventory
       ↓
Clear Cart
       ↓
Commit
```

If validation fails, the operation does not silently create an invalid order.

---

# 🧩 Why This Architecture?

The architecture was chosen with maintainability in mind.

For example, if the database layer changes in the future:

```text
Firestore
   ↓
New Backend
```

the goal is to keep the majority of the UI untouched.

Business logic lives in services instead of being duplicated across screens.

That makes the project easier to:

* Test
* Maintain
* Refactor
* Scale
* Extend

---

# 🚀 Getting Started

## Prerequisites

Make sure you have:

* Flutter SDK
* Dart SDK
* Android Studio or Xcode
* Firebase project
* Cloudinary account
* Git

Verify Flutter:

```bash
flutter doctor
```

---

## Clone the Repository

```bash
git clone https://github.com/HebaRabaya/Bloom_app.git
```

Then:

```bash
cd Bloom_app
```

---

## Install Dependencies

```bash
flutter pub get
```

---

## Firebase Configuration

Configure Firebase for your target platform and ensure the project contains the generated Firebase configuration.

The application expects Firebase services to be configured before running the full backend-powered experience.

---

## Run the Application

For Android:

```bash
flutter run
```

For a specific device:

```bash
flutter devices
flutter run -d <device-id>
```

---

# 🌱 First-Time Setup

A fresh installation follows:

```text
Install
  ↓
Launch
  ↓
Firebase Initialization
  ↓
Onboarding
  ↓
Create Account
  ↓
Explore Bloom
```

Administrators use the same application but are routed to the admin experience based on their stored role.

---

# 🔮 Future Improvements

Bloom is designed so additional capabilities can be added without redesigning the entire application.

Potential improvements include:

* 💳 Online payment integration
* 🔔 Push notifications
* 📍 Live delivery location
* 🗺️ Delivery address mapping
* 🎁 Gift notes and occasions
* 🌹 Personalized recommendations
* ⭐ Product reviews and ratings
* 📈 Advanced analytics dashboard
* 📊 Sales reporting
* 🧪 Automated unit and integration testing
* 🌐 Localization / multi-language support
* 🖼️ Richer media management
* 🔐 Stronger role and permission policies

---

# 🧠 Engineering Principles

Bloom follows a few principles throughout the project:

### Separation of Concerns

UI, business logic, and backend interaction are kept separate.

### Reusability

Common UI patterns are extracted into reusable widgets.

### Data Integrity

Critical inventory operations use transactional logic.

### Predictability

Deterministic IDs are used where they simplify data operations.

### Maintainability

Backend-specific logic is isolated inside services.

### User Experience

Loading, empty, success, and failure states are considered part of the interface.

### Scalability

The project structure is designed to allow additional features without turning screens into large monolithic files.

---

# 📈 What This Project Demonstrates

Bloom demonstrates practical experience with:

* Flutter application development
* Dart
* Firebase Authentication
* Cloud Firestore
* CRUD operations
* Firestore transactions
* Real-time streams
* Cloud image hosting
* Role-based application flows
* E-commerce architecture
* Inventory management
* Cart systems
* Checkout workflows
* Order management
* State-driven UI
* Responsive layouts
* Custom design systems
* Reusable widgets
* Service-based architecture
* Error and empty-state handling

---

# 🌷 Why Bloom?

A flower shop may sound simple.

Building a digital flower shop is not.

Behind a single **“Add to Cart”** button are questions about:

```text
Authentication
      ↓
Product availability
      ↓
Inventory
      ↓
Cart persistence
      ↓
Transactions
      ↓
Order creation
      ↓
Historical data
      ↓
Admin operations
      ↓
Customer experience
```

Bloom was built to solve those problems as one connected system.

---

# 👩‍💻 Team

Built as a collaborative software project.

### Contributors

* **Heba Rabaya**
* Project team members

Each team member contributed to the development of different parts of the application, from interface development to backend integration and application functionality.

---

# 📌 Project Status

**Active Development**

Bloom is currently a functional Flutter commerce application with customer and admin workflows implemented around Firebase and Cloudinary.

---

<div align="center">

## 🌷 Bloom Flowers

### *Fresh flowers. Softer days.*

**Designed with intention.
Built with Flutter.
Engineered for a real shopping experience.**

<br>

⭐ If you find the project interesting, consider giving the repository a star.

</div>

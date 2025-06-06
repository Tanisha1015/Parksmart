 # 🚗Parksmart

What is Parksmart?

**Park Smart** is a Flutter-based Android app that helps users find, reserve, and navigate to available parking spots in real time using Google Maps and Firebase.

## 🌟 Overview

Park Smart revolutionizes the way you park in urban environments. With a seamless interface and real-time data, users can:
- 🔍 **Discover** nearby parking lots on an interactive map
- 📊 **View live availability** of parking spots
- 🅿️ **Reserve a spot** instantly to avoid last-minute hassle
- 🗺️ **Navigate** to your reserved spot with turn-by-turn directions
- 🕒 **Track your parking history** for future reference

Built with Flutter, Firebase, and Google Maps, Park Smart is designed for reliability, speed, and ease of use—making city parking stress-free and efficient.

---

## ✨Features

- 🔐Google Sign-In Authentication
  
   Securely log in to the app using your Google account. This ensures a personalized experience and allows you to track your parking history and reservations.

  
- 📡Real-time Parking Spot Availability
  
   View live information about available parking lots and individual parking spots. The app updates availability in real time as spots are reserved or freed.

  
- 🗺️Interactive Google Map with Markers
  
   See all nearby parking lots displayed as markers on an interactive Google Map. Tap markers to view lot details, spot availability, and pricing.
  
  
- 🅿️Automatic or Manual Parking Spot Selection
  
   Choose to have the app automatically assign you the nearest available spot, or manually select your preferred spot from a list or grid.

  
- 🚦In-app Navigation to Reserved Spot
  
   Get turn-by-turn navigation from your current location to your reserved parking spot directly within the app, using Google Maps routing.

  
- 🕒Reservation History
  
   View a complete history of your past parking reservations, including lot names, spot numbers, reservation times, and prices.

- 🖼️ Screenshots



  <img src="https://github.com/user-attachments/assets/d412bea4-d7c3-4faa-affd-b26acfc98453" width="300" alt="Screenshot_2025-05-31-13-56-22-318_com android parksmart" />


  <img src="https://github.com/user-attachments/assets/306c5d8f-e6d9-4248-9fb0-132c060094ab" width="300" alt="Screenshot_2025-05-31-13-56-22-318_com android parksmart" />


  <img src="https://github.com/user-attachments/assets/fb0765df-a622-473a-8e3c-f4b90905c50e" width="300" alt="Screenshot_2025-05-31-13-56-22-318_com android parksmart" />


  <img src="https://github.com/user-attachments/assets/90b2d032-f1d3-46ae-b54c-1bd3eb125f20" width="300" alt="Screenshot_2025-05-31-13-56-22-318_com android parksmart" />


  <img src="https://github.com/user-attachments/assets/e2a8a97c-0df4-49fb-a673-10b32082561f" width="300" alt="Screenshot_2025-05-31-13-56-22-318_com android parksmart" />


  <img src="https://github.com/user-attachments/assets/129bc770-c394-4e89-9776-4879cc61c567" width="300" alt="Screenshot_2025-05-31-13-56-22-318_com android parksmart" />

## 🛠️Tech Stack Used-

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Firebase Project](https://console.firebase.google.com/)
- [Google Cloud Platform Project](https://console.cloud.google.com/)
- [Android Studio](https://developer.android.com/studio)

## 🚀Getting Started

#### 1️⃣Clone the Repository


```
git clone https://github.com/Tanisha1015/parksmart.git
cd parksmart
```


#### 2️⃣Install Dependencies

```
flutter pub get
```

#### 3️⃣Firebase Setup:

- Place `google-services.json` in `android/app/`

#### 4️⃣Generate Firebase config:

```
dart pub global activate flutterfire_cli
flutterfire configure
```

#### 5️⃣Google Maps API Key Setup (Android)

- `android/app/src/main/AndroidManifest.xml:`

```
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY"/>
```

#### 6️⃣Run the App

```
flutter run
```

### 📁Project Structure:

```
lib/
  main.dart
  models/
    parking_lot.dart
    parking_spot.dart
    reservation.dart
  providers/
    auth_provider.dart
    location_provider.dart
    parking_provider.dart
  screens/
    splash_screen.dart
    auth_screen.dart
    home_screen.dart
    map_screen.dart
    parking_lot_details_screen.dart
    reservation_confirmation_screen.dart
    navigation_screen.dart
    history_screen.dart
    profile_screen.dart
firebase_options.dart
```

## Happy Parking! 🚗

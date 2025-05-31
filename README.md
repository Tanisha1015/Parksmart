# Parksmart

What is Parksmart?
**Park Smart** is a Flutter-based Android app that helps users find, reserve, and navigate to available parking spots in real time using Google Maps and Firebase.

## Features

- Google Sign-In Authentication
  
  Securely log in to the app using your Google account. This ensures a personalized experience and allows you to track your parking history and reservations.
  
- Real-time Parking Spot Availability
  
  View live information about available parking lots and individual parking spots. The app updates availability in real time as spots are reserved or freed.
  
- Interactive Google Map with Markers
  
  See all nearby parking lots displayed as markers on an interactive Google Map. Tap markers to view lot details, spot availability, and pricing.
  
- Automatic or Manual Parking Spot Selection
  
  Choose to have the app automatically assign you the nearest available spot, or manually select your preferred spot from a list or grid.
  
- In-app Navigation to Reserved Spot
  
  Get turn-by-turn navigation from your current location to your reserved parking spot directly within the app, using Google Maps routing.
  
- Reservation History
  
  View a complete history of your past parking reservations, including lot names, spot numbers, reservation times, and prices.
  
- (Optional) Payment Integration
  
  Support for integrating payment gateways to handle parking fees securely within the app (implementation optional and customizable).

## Tech Stack Used-

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Firebase Project](https://console.firebase.google.com/)
- [Google Cloud Platform Project](https://console.cloud.google.com/)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)

## Getting Started

### Clone the Repository

First, clone this repository to your local machine using Git:


### Install Dependencies

Install all Flutter dependencies:


### Set Up Firebase and API Keys

- Add your `google-services.json` file to `android/app/`.
- Add your Google Maps API key to `android/app/src/main/AndroidManifest.xml` as described above.

### Run the App

Connect your Android device or start an emulator, then run:

undefined

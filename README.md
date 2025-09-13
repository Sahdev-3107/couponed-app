Couponed - Flutter & Node.js Technical Assessment
This repository contains the full-stack solution for the Couponed technical interview assessment. It includes a Flutter mobile application for the front end and a Node.js (Express) REST API for the back end.

Project Overview
The application is a simple coupon aggregator that displays a list of deals fetched from a custom backend. Users can browse, search, and filter coupons. The app also features state management to keep track of which coupons have been claimed.

Features
Dynamic Data: Coupons are fetched from a live Node.js backend.

State Management: Uses the provider package to manage claimed coupon states.

Responsive UI: Clean, responsive layout that works across different screen sizes.

Filtering & Searching: Users can filter coupons by category and search by brand, title, or description.

Custom Coupon Design: Features a unique ticket-style coupon card for a better user experience.

Directory Structure
The project is structured as a monorepo with two main directories:

/frontend: Contains the complete Flutter application.

/backend: Contains the Node.js and Express REST API.

How to Run
You will need to have Flutter and Node.js installed on your machine.

1. Running the Backend API
First, start the backend server to serve the coupon data.

# Navigate to the backend directory
cd backend

# Install dependencies
npm install

# Run the server
node server.js

The API will be available at http://localhost:3000/api/coupons.

2. Running the Frontend Flutter App
Once the backend is running, you can start the Flutter application.

# Navigate to the frontend directory
cd frontend

# Get Flutter packages
flutter pub get

# Run the app on an emulator or connected device
flutter run

Note: The app is configured to connect to http://http://localhost:3000/ (for the Android Emulator). If you are using an iOS Simulator or a physical device, please update the apiUrl in lib/main.dart to your computer's local IP address.

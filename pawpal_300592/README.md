# 🐾 PawPal Pet Adoption and Donation App

This repository contains the Flutter application and PHP backend API for the PawPal pet adoption and donation platform.

## Table of Contents

1.  [Setup & Installation](#-setup--installation)
2.  [API Explanation](#-api-explanation)
3.  [Sample JSON Responses](#-sample-json-responses)

---

## Setup & Installation

Follow these steps to set up the Flutter application and the PHP/MySQL backend on your local machine using **XAMPP**.

### A. Flutter Application Setup

1.  **Install Dependencies**
    To fetch all required Dart packages (like `http`), run the following command in the project root directory:

    ```bash
    flutter pub get
    ```

2.  **Configure IP Address**
    Open `lib/myconfig.dart` and change the `baseUrl` variable to match your computer's local IP address or the local IP address of your XAMPP server.

    ```dart
    // Example in lib/myconfig.dart
    class MyConfig {
        static const String baseUrl = "http://<YOUR_LOCAL_IP_ADDRESS>"; // e.g., [http://192.168.1.10](http://192.168.1.10)
        // ...
    }
    ```

3.  **Run the App**
    Run the application on a connected device or emulator:

    ```bash
    flutter run
    ```

### B. XAMPP Server Setup

1.  **Install XAMPP**
    Ensure you have XAMPP installed and running, with the **Apache** and **MySQL** services started.

2.  **Copy API Files**
    Copy the entire `pawpal` API folder (which contains the `api` and `uploads` subdirectories) into your XAMPP's web directory (usually `htdocs/`).

    > **Location Structure Example:** `C:\xampp\htdocs\pawpal\`

3.  **Database Import**
    Open your browser and go to **phpMyAdmin** (usually `http://localhost/phpmyadmin`).
    * Create a new database named **`pawpal_db`**.
    * Import the provided database file, **`pawpal_db.sql`**, into this new database.

---

## API Explanation

The backend consists of PHP scripts in the `api/` folder designed to handle all data interaction with the MySQL database.

| File | Purpose | Key Functionality |
| :--- | :--- | :--- |
| `dbconnect.php` | **Database Connection** | Handles the connection to the `pawpal_db` database. |
| `login.php` | **User Authentication** | Processes user login requests and verifies credentials against the stored records. |
| `register_user.php` | **User Registration** | Creates new user accounts, **encrypts the password**, and checks if the email is already registered. |
| `get_my_pets.php` | **Data Retrieval** | Loads all submission data for a specific user, including pet details and image paths. |
| `submit_pet.php` | **Data Submission** | Handles new pet submissions, saves pet details to the database, and manages **image file uploads** and path storage. |

---

## Sample JSON Responses

These examples illustrate the structure of data exchanged between the Flutter app and the PHP API.

### Example: `get_my_pets.php` (Expected Data Structure)

This API returns an array of pet submission objects for the authenticated user.

#### 1. Success Response 

```json
URL: http://10.29.106.140/pawpal/api/submit_pet.php
Status Code: 200
Body (Raw JSON): {"status":"success","message":"Pet submitted successfully","success":true}

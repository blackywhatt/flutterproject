# 🐾 PawPal Pet Adoption and Donation App

This repository contains the Flutter application and PHP backend API for the PawPal pet adoption and donation platform.

## Setup & Installation

Follow these steps to set up the Flutter application and the PHP/MySQL backend on your local machine using **XAMPP**.

### A. Flutter Application Setup

1.  **Install Dependencies**

2.  **Configure IP Address**

3.  **Run the App**

### B. XAMPP Server Setup

1.  **Install XAMPP**
    Ensure you have XAMPP installed and running, with the **Apache** and **MySQL** services started.

2.  **Copy API Files**
    Copy the entire `pawpal` API folder (which contains the `api` and `uploads` subdirectories) into your XAMPP's web directory (usually `htdocs/`).

3.  **Database Import**
    Open your browser and go to **phpMyAdmin** (usually `http://localhost/phpmyadmin`).
    * Create a new database named **`pawpal_db`**.
    * Import the provided database file, **`pawpal_db.sql`**, into this new database.

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
1. JSON Response (Login): {"status":"success","message":"Login successful","data":[{"user_id":"1","user_name":"Zaki Adib","user_email":"zakiadib4646@gmail.com","user_password":"a15ac34f197fa99cb250cb65e36fb3acd9b5226c","user_phone":"0164086242","user_regdate":"2025-11-25 21:31:30"}]}

2. URL: http://10.29.106.140/pawpal/api/submit_pet.php
Status Code: 200
Body (Raw JSON): {"status":"success","message":"Pet submitted successfully","success":true}

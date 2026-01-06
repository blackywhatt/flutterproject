<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    http_response_code(405);
    echo json_encode(['status' => 'failed', 'message' => 'Method Not Allowed']);
    exit();
}

// ---------- Get POST data ----------
$userid    = $_POST['user_id'] ?? '';
$name      = addslashes($_POST['user_name'] ?? '');
$phone     = addslashes($_POST['user_phone'] ?? '');
$image     = $_POST['image'] ?? ''; // Base64 string from Flutter

if (empty($userid)) {
    sendJsonResponse(['status' => 'failed', 'message' => 'User ID is required']);
    exit();
}

// ---------- SQL UPDATE (Name & Phone) ----------
$sqlupdateprofile = "UPDATE `tbl_users` SET 
    `user_name`  = '$name', 
    `user_phone` = '$phone' 
    WHERE `user_id` = '$userid'";

try {
    if ($conn->query($sqlupdateprofile) === TRUE) {
        
        // ---------- IMAGE UPLOAD LOGIC ----------
        if (!empty($image)) {
            $decoded_image = base64_decode($image);
            
            // Saving to your 'uploads/profile' folder
            // We use ../ to go out of 'api' folder, then into 'uploads/profile'
            $path = "../uploads/profile/" . $userid . ".jpg";
            
            file_put_contents($path, $decoded_image);
        }

        sendJsonResponse([
            'status' => 'success',
            'message' => 'Profile updated successfully'
        ]);
    } else {
        sendJsonResponse(['status' => 'failed', 'message' => 'Database error']);
    }
} catch (Exception $e) {
    sendJsonResponse(['status' => 'failed', 'message' => $e->getMessage()]);
}

function sendJsonResponse($sentArray) {
    echo json_encode($sentArray);
}
?>
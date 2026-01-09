<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    http_response_code(405);
    echo json_encode(['status' => 'failed', 'message' => 'Method Not Allowed']);
    exit();
}

// ---------- Get POST data from Flutter ----------
$userid = $_POST['user_id'];
$name   = addslashes($_POST['user_name']);
$phone  = $_POST['user_phone'];
$image  = $_POST['image']; // This is the base64 string

// ---------- SQL UPDATE (Updated for PawPal fields) ----------
$sqlupdateprofile = "UPDATE tbl_users SET user_name = '$name', user_phone = '$phone' WHERE user_id = '$userid'";

try {
    if ($conn->query($sqlupdateprofile) === TRUE) {
        
        // ---------- HANDLE IMAGE UPLOAD ----------
        if (!empty($image)) {
            $decoded_string = base64_decode($image);
            $path = "../uploads/profile/" . $userid . ".jpg";
            
            // Check if folder exists, if not, create it
            if (!is_dir("../uploads/profile/")) {
                mkdir("../uploads/profile/", 0755, true);
            }
            
            file_put_contents($path, $decoded_string);
        }

        sendJsonResponse([
            'status' => 'success',
            'message' => 'Profile updated successfully'
        ]);
    } else {
        sendJsonResponse([
            'status' => 'failed',
            'message' => 'Profile update failed'
        ]);
    }
} catch (Exception $e) {
    sendJsonResponse([
        'status' => 'failed',
        'message' => $e->getMessage()
    ]);
}

function sendJsonResponse($sentArray)
{
    echo json_encode($sentArray);
}
?>
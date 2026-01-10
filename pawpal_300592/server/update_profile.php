<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    http_response_code(405);
    echo json_encode(['status' => 'failed', 'message' => 'Method Not Allowed']);
    exit();
}

$userid = $_POST['user_id'];
$name   = addslashes($_POST['user_name']);
$phone  = $_POST['user_phone'];
$image  = $_POST['image']; 

$sqlupdateprofile = "UPDATE tbl_users SET user_name = '$name', user_phone = '$phone' WHERE user_id = '$userid'";

try {
    if ($conn->query($sqlupdateprofile) === TRUE) {
        
        if (!empty($image)) {
            $decoded_string = base64_decode($image);
            $path = "../uploads/profile/" . $userid . ".jpg";
            
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
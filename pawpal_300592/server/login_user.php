<?php
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

function sendJsonResponse($sentArray) {
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    if (!isset($_POST['email']) || !isset($_POST['password'])) {
        sendJsonResponse(array('status' => 'failed', 'message' => 'Bad Request', 'success' => false));
        exit();
    }
    
    // Sanitize inputs to prevent SQL Injection
    $email = $conn->real_escape_string($_POST['email']);
    $password = $_POST['password'];
    $hashedpassword = sha1($password);

    $sqllogin = "SELECT * FROM `tbl_users` WHERE `user_email` = '$email' AND `user_password` = '$hashedpassword'";
    $result = $conn->query($sqllogin);

    if ($result->num_rows > 0) {
        // Fetch single row as an associative array (Map)
        $userdata = $result->fetch_assoc(); 
        
        // Ensure 'success' key is present for Flutter logic
        $response = array(
            'status' => 'success', 
            'message' => 'Login successful', 
            'success' => true, 
            'data' => $userdata
        );
        sendJsonResponse($response);
    } else {
        $response = array(
            'status' => 'failed', 
            'message' => 'Invalid email or password', 
            'success' => false, 
            'data' => null
        );
        sendJsonResponse($response);
    }
} else {
    sendJsonResponse(array('status' => 'failed', 'message' => 'Method Not Allowed', 'success' => false));
}
?>
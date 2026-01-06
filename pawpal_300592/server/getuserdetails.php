<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include 'dbconnect.php';

if (!isset($_GET['userid'])) {
    echo json_encode(['status' => 'failed', 'message' => 'User ID missing']);
    exit();
}

$userid = $_GET['userid'];

$sqlgetuser = "SELECT * FROM `tbl_users` WHERE `user_id` = '$userid'";
$result = $conn->query($sqlgetuser);

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    
    // We create the user data object
    $userdata = array();
    $userdata['userId']   = $row['user_id'];
    $userdata['name']     = $row['user_name'];
    $userdata['email']    = $row['user_email'];
    $userdata['phone']    = $row['user_phone'];
    $userdata['regDate']  = $row['user_regdate'];
    
    // We add the image URL so the app knows where to find the profile pic
    // Note: We add a timestamp (?t=...) to avoid image caching issues
    $userdata['profileImage'] = "uploads/profile/" . $userid . ".jpg?t=" . time();

    echo json_encode(['status' => 'success', 'data' => $userdata]);
} else {
    echo json_encode(['status' => 'failed', 'message' => 'User not found']);
}
?>
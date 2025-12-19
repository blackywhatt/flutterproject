<?php
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

function sendJsonResponse($sentArray) {
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

// 1. Check if the Method is POST
if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    sendJsonResponse(array('status' => 'failed', 'message' => 'Invalid Request Method'));
    exit();
}

// 2. Capture and Sanitize Location Data
$user_id = $conn->real_escape_string($_POST['user_id']);
$pet_name = $conn->real_escape_string($_POST['pet_name']);
$lat = $conn->real_escape_string($_POST['lat']); // Grab Latitude
$lng = $conn->real_escape_string($_POST['lng']); // Grab Longitude
$pet_type = $conn->real_escape_string($_POST['pet_type']);
$category = $conn->real_escape_string($_POST['category']);
$description = $conn->real_escape_string($_POST['description']);

// 3. Insert into Database
$sqlinsert = "INSERT INTO `tbl_pets`(`user_id`, `pet_name`, `pet_type`, `category`, `description`, `lat`, `lng`) 
              VALUES ('$user_id', '$pet_name', '$pet_type', '$category', '$description', '$lat', '$lng')";

if ($conn->query($sqlinsert) === TRUE) {
    $pet_id = $conn->insert_id;
    // ... (Your image handling code remains here)
    
    // Final Success Response
    sendJsonResponse(array('status' => 'success', 'success' => true, 'message' => 'Pet added at location: ' . $lat));
} else {
    sendJsonResponse(array('status' => 'failed', 'message' => 'SQL Error: ' . $conn->error));
}
?>
<?php
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

// Lecturer's mandatory JSON utility function
function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

if ($_SERVER['REQUEST_METHOD'] != 'GET') {
    http_response_code(405);
    sendJsonResponse(array('status' => 'failed', 'message' => 'Method Not Allowed'));
    exit();
}

if (!isset($_GET['user_id'])) {
    sendJsonResponse(array('status' => 'failed', 'message' => 'Missing user ID'));
    exit();
}

$user_id = $conn->real_escape_string($_GET['user_id']);

// SQL query to fetch all pets submitted by the specific user
$sqlloadpets = "SELECT * FROM `tbl_pets` WHERE `user_id` = '$user_id' ORDER BY `created_at` DESC";

$result = $conn->query($sqlloadpets);

if ($result && $result->num_rows > 0) {
    $petdata = array();
    while ($row = $result->fetch_assoc()) {
        $petdata[] = $row;
    }
    $response = array('status' => 'success', 'data' => $petdata);
    sendJsonResponse($response);
} else {
    // Mandatory: Return status failed if no records
    $response = array('status' => 'failed', 'message' => 'No submissions found.', 'data' => null);
    sendJsonResponse($response);
}
?>
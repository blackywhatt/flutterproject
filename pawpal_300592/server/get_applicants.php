<?php
include_once("dbconnect.php");

$owner_id = $_GET['owner_id'];

// Get all requests where the logged-in user is the owner
$sql = "SELECT a.*, u.user_name AS requester_name, p.pet_name 
        FROM tbl_adoptions a 
        JOIN tbl_users u ON a.requester_id = u.user_id 
        JOIN tbl_pets p ON a.pet_id = p.pet_id 
        WHERE a.owner_id = '$owner_id' AND a.status = 'Pending'";

$result = $conn->query($sql);
if ($result->num_rows > 0) {
    $response = array();
    while ($row = $result->fetch_assoc()) {
        array_push($response, $row);
    }
    echo json_encode(['status' => 'success', 'data' => $response]);
} else {
    echo json_encode(['status' => 'failed']);
}
?>
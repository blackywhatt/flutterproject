<?php
if (!isset($_GET['user_id'])) {
    echo json_encode(['status' => 'failed', 'message' => 'User ID missing']);
    die();
}

include_once("dbconnect.php");

$user_id = $_GET['user_id'];

$sqlget = "SELECT d.*, p.pet_name 
           FROM `tbl_donations` d 
           JOIN `tbl_pets` p ON d.pet_id = p.pet_id 
           WHERE d.user_id = '$user_id' 
           ORDER BY d.date_donated DESC";

$result = $conn->query($sqlget);

if ($result->num_rows > 0) {
    $donations = array();
    while ($row = $result->fetch_assoc()) {
        $donations[] = $row;
    }
    echo json_encode(['status' => 'success', 'data' => $donations]);
} else {
    echo json_encode(['status' => 'failed', 'message' => 'No donation history found']);
}
?>
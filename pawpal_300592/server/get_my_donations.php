<?php
// Changed to POST to match your Flutter code
if (!isset($_POST['user_id'])) {
    echo json_encode(['status' => 'failed', 'message' => 'User ID missing']);
    die();
}

include_once("dbconnect.php");

$user_id = $_POST['user_id'];

// Use Prepared Statements for security
$sqlget = "SELECT d.*, p.pet_name 
           FROM `tbl_donations` d 
           JOIN `tbl_pets` p ON d.pet_id = p.pet_id 
           WHERE d.user_id = ? 
           ORDER BY d.date_donated DESC";

$stmt = $conn->prepare($sqlget);
$stmt->bind_param("s", $user_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $donations = array();
    while ($row = $result->fetch_assoc()) {
        $donations[] = $row;
    }
    echo json_encode(['status' => 'success', 'data' => $donations]);
} else {
    // Return an empty array on success so Flutter doesn't crash on 'failed' status
    echo json_encode(['status' => 'success', 'data' => []]);
}
?>
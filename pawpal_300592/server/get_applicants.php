<?php
include_once("dbconnect.php");

$owner_id = $_GET['owner_id'] ?? null;
$pet_id = $_GET['pet_id'] ?? null;

if (!$owner_id) {
    echo json_encode(['status' => 'failed', 'message' => 'Owner ID missing']);
    exit();
}

$sql = "SELECT a.*, u.user_name AS requester_name, p.pet_name 
        FROM tbl_adoptions a 
        JOIN tbl_users u ON a.requester_id = u.user_id 
        JOIN tbl_pets p ON a.pet_id = p.pet_id 
        WHERE a.owner_id = ? AND a.status = 'Pending'";

if ($pet_id) {
    $sql .= " AND a.pet_id = ?";
}

$stmt = $conn->prepare($sql);

if ($pet_id) {
    $stmt->bind_param("ss", $owner_id, $pet_id);
} else {
    $stmt->bind_param("s", $owner_id);
}

$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $response = array();
    while ($row = $result->fetch_assoc()) {
        $response[] = $row;
    }
    echo json_encode(['status' => 'success', 'data' => $response]);
} else {
    echo json_encode(['status' => 'failed', 'message' => 'No pending requests']);
}
?>
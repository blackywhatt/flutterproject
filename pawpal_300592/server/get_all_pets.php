<?php
include_once("dbconnect.php");

$search = isset($_GET['search']) ? $_GET['search'] : '';
$type = isset($_GET['type']) ? $_GET['type'] : '';

// "WHERE 1" is a trick that lets us add "AND" conditions easily
$sql = "SELECT * FROM tbl_pets WHERE 1";

if (!empty($search)) {
    $sql .= " AND pet_name LIKE '%$search%'";
}

if (!empty($type)) {
    $sql .= " AND pet_type = '$type'";
}

$sql .= " ORDER BY created_at DESC";

$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $pets = array();
    while ($row = $result->fetch_assoc()) {
        $pets[] = $row;
    }
    echo json_encode(['status' => 'success', 'data' => $pets]);
} else {
    echo json_encode(['status' => 'failed', 'message' => 'No pets found']);
}
?>
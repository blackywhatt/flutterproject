<?php
include_once("dbconnect.php");

if (!isset($_POST['pet_id']) || !isset($_POST['user_id'])) {
    echo json_encode(['status' => 'failed', 'message' => 'Missing data']);
    die();
}

$petid = $conn->real_escape_string($_POST['pet_id']);
$userid = $conn->real_escape_string($_POST['user_id']);

$sqlselect = "SELECT image_paths FROM tbl_pets WHERE pet_id = '$petid' AND user_id = '$userid'";
$result = $conn->query($sqlselect);

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    $image_paths = json_decode($row['image_paths'], true);

    if (is_array($image_paths)) {
        foreach ($image_paths as $path) {
            $filename = basename($path); 
            $physical_path = "../uploads/pets/" . $filename;
            
            if (file_exists($physical_path)) {
                unlink($physical_path);
            }
        }
    }

    $sqldelete = "DELETE FROM tbl_pets WHERE pet_id = '$petid'";
    if ($conn->query($sqldelete) === TRUE) {
        echo json_encode(['status' => 'success']);
    } else {
        echo json_encode(['status' => 'failed', 'message' => 'Database error']);
    }
} else {
    echo json_encode(['status' => 'failed', 'message' => 'Unauthorized or record not found']);
}
?>
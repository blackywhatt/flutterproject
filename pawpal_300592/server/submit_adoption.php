<?php
include 'dbconnect.php';

$pet_id = (int)$_POST['pet_id'];
$requester_id = (int)$_POST['requester_id'];
$owner_id = (int)$_POST['owner_id'];
$message = $conn->real_escape_string($_POST['message']); 

$sqlinsert = "INSERT INTO `tbl_adoptions`(`pet_id`, `requester_id`, `owner_id`, `message`) 
              VALUES ('$pet_id', '$requester_id', '$owner_id', '$message')";

if ($conn->query($sqlinsert) === TRUE) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'failed']);
}
?>
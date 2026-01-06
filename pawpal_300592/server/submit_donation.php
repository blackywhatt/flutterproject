<?php
if (!isset($_POST)) {
    echo json_encode(['status' => 'failed', 'message' => 'No data received']);
    die();
}

include_once("dbconnect.php");

$user_id = $_POST['user_id'];
$pet_id = $_POST['pet_id'];
$type = $_POST['donation_type']; // 'Money', 'Food', or 'Medical'
$amount = isset($_POST['amount']) ? $_POST['amount'] : 0.00;
$description = isset($_POST['description']) ? $_POST['description'] : '';

$sqlinsert = "INSERT INTO `tbl_donations` (`user_id`, `pet_id`, `donation_type`, `amount`, `description`) 
              VALUES ('$user_id', '$pet_id', '$type', '$amount', '$description')";

if ($conn->query($sqlinsert) === TRUE) {
    $response = array('status' => 'success', 'data' => null);
    echo json_encode($response);
} else {
    $response = array('status' => 'failed', 'data' => null);
    echo json_encode($response);
}
?>
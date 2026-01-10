<?php
include_once("dbconnect.php");

$adoption_id = $_POST['adoption_id'];
$status = $_POST['status']; // 'Approved' or 'Rejected'

// Update the status in tbl_adoptions
$sqlupdate = "UPDATE `tbl_adoptions` SET `status` = '$status' WHERE `adoption_id` = '$adoption_id'";

if ($conn->query($sqlupdate) === TRUE) {
    // If approved, we should also update the pet status in tbl_pets
    if ($status == "Approved") {
        $sqlgetpet = "SELECT pet_id FROM `tbl_adoptions` WHERE `adoption_id` = '$adoption_id'";
        $result = $conn->query($sqlgetpet);
        $row = $result->fetch_assoc();
        $pet_id = $row['pet_id'];
        
        // Mark the pet as Adopted so it doesn't show in the main list
        $conn->query("UPDATE `tbl_pets` SET `status` = 'Adopted' WHERE `pet_id` = '$pet_id'");
    }
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'failed']);
}
?>
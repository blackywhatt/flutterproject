<?php
include_once("dbconnect.php");
header('Content-Type: application/json');

$adoption_id = $_POST['adoption_id'] ?? null;
$status = $_POST['status'] ?? null;

if (!$adoption_id || !$status) {
    echo json_encode(['status' => 'failed', 'message' => 'Missing data']);
    exit();
}

$conn->begin_transaction();

try {
    $stmt1 = $conn->prepare("UPDATE `tbl_adoptions` SET `status` = ? WHERE `adoption_id` = ?");
    $stmt1->bind_param("ss", $status, $adoption_id);
    $stmt1->execute();

    if ($status == "Approved") {
        $stmt2 = $conn->prepare("SELECT pet_id FROM `tbl_adoptions` WHERE `adoption_id` = ?");
        $stmt2->bind_param("s", $adoption_id);
        $stmt2->execute();
        $row = $stmt2->get_result()->fetch_assoc();
        
        if ($row) {
            $pet_id = $row['pet_id'];

            $stmt3 = $conn->prepare("UPDATE `tbl_pets` SET `pet_status` = 'Adopted' WHERE `pet_id` = ?");
            $stmt3->bind_param("s", $pet_id);
            $stmt3->execute();

            $stmt4 = $conn->prepare("UPDATE `tbl_adoptions` SET `status` = 'Rejected' WHERE `pet_id` = ? AND `adoption_id` != ? AND `status` = 'Pending'");
            $stmt4->bind_param("ss", $pet_id, $adoption_id);
            $stmt4->execute();
        }
    }

    $conn->commit();
    echo json_encode(['status' => 'success']);
} catch (Exception $e) {
    $conn->rollback();
    echo json_encode(['status' => 'failed', 'message' => $e->getMessage()]);
}
?>
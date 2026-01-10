<?php
include 'dbconnect.php';

$donor_id = $_POST['user_id'];
$pet_id = $_POST['pet_id'];
$donation_type = $_POST['donation_type']; 
$amount = isset($_POST['amount']) ? floatval($_POST['amount']) : 0;
$description = $_POST['description'];

$conn->begin_transaction();

try {
    if ($donation_type == 'Money') {
        $stmtOwner = $conn->prepare("SELECT user_id FROM tbl_pets WHERE pet_id = ?");
        $stmtOwner->bind_param("s", $pet_id);
        $stmtOwner->execute();
        $owner_res = $stmtOwner->get_result()->fetch_assoc();
        $owner_id = $owner_res['user_id'];

        if ($donor_id == $owner_id) {
            echo json_encode(['status' => 'failed', 'message' => 'You cannot donate to your own pet']);
            exit();
        }

        $stmtBalance = $conn->prepare("SELECT user_credit FROM tbl_users WHERE user_id = ?");
        $stmtBalance->bind_param("s", $donor_id);
        $stmtBalance->execute();
        $row = $stmtBalance->get_result()->fetch_assoc();
        $current_balance = $row['user_credit'];

        if ($current_balance < $amount) {
            echo json_encode(['status' => 'failed', 'message' => 'Insufficient balance (Current: RM' . number_format($current_balance, 2) . ')']);
            exit();
        }

        $stmtDeduct = $conn->prepare("UPDATE tbl_users SET user_credit = user_credit - ? WHERE user_id = ?");
        $stmtDeduct->bind_param("ds", $amount, $donor_id);
        $stmtDeduct->execute();

        $stmtAdd = $conn->prepare("UPDATE tbl_users SET user_credit = user_credit + ? WHERE user_id = ?");
        $stmtAdd->bind_param("ds", $amount, $owner_id);
        $stmtAdd->execute();
    }

    $stmtInsert = $conn->prepare("INSERT INTO tbl_donations (user_id, pet_id, amount, description, donation_type) VALUES (?, ?, ?, ?, ?)");
    $stmtInsert->bind_param("ssdss", $donor_id, $pet_id, $amount, $description, $donation_type);
    $stmtInsert->execute();

    $conn->commit();
    echo json_encode(['status' => 'success', 'message' => 'Donation of RM' . number_format($amount, 2) . ' successful']);

} catch (Exception $e) {
    $conn->rollback();
    echo json_encode(['status' => 'failed', 'message' => 'Database error: ' . $e->getMessage()]);
}
?>
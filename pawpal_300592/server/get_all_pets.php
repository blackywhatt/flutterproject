<?php
include_once("dbconnect.php");

$results_per_page = 8;
$pageno = isset($_GET['pageno']) ? (int)$_GET['pageno'] : 1;
$start_from = ($pageno - 1) * $results_per_page;

$search = isset($_GET['search']) ? $_GET['search'] : '';
$type = isset($_GET['type']) ? $_GET['type'] : '';

$where_clause = " WHERE 1";
if (!empty($search)) {
    $where_clause .= " AND p.pet_name LIKE '%$search%'";
}
if (!empty($type)) {
    $where_clause .= " AND p.pet_type = '$type'";
}

$sql_count = "SELECT COUNT(*) AS total FROM tbl_pets p" . $where_clause;
$result_count = $conn->query($sql_count);
$row_count = $result_count->fetch_assoc();
$total_records = $row_count['total'];
$numofpage = ceil($total_records / $results_per_page);

$sql = "SELECT p.*, u.user_name AS owner_name 
        FROM tbl_pets p 
        INNER JOIN tbl_users u ON p.user_id = u.user_id" 
        . $where_clause . 
        " ORDER BY p.created_at DESC LIMIT $start_from, $results_per_page";

$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $pets = array();
    while ($row = $result->fetch_assoc()) {
        $pets[] = $row;
    }
    echo json_encode([
        'status' => 'success', 
        'numofpage' => $numofpage,
        'numberofresults' => $total_records,
        'data' => $pets
    ]);
} else {
    echo json_encode(['status' => 'failed', 'message' => 'No pets found', 'numofpage' => 1]);
}
?>
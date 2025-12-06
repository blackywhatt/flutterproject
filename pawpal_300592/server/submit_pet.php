<?php
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    http_response_code(405);
    sendJsonResponse(array('status' => 'failed', 'message' => 'Method Not Allowed'));
    exit();
}

if (!isset($_POST['user_id']) || !isset($_POST['pet_name']) || !isset($_POST['category']) || !isset($_POST['description']) || !isset($_POST['lat']) || !isset($_POST['lng']) || !isset($_POST['pet_type'])) {
    sendJsonResponse(array('status' => 'failed', 'message' => 'Missing required fields'));
    exit();
}

// Sanitize inputs
$user_id = $conn->real_escape_string($_POST['user_id']);
$pet_name = $conn->real_escape_string($_POST['pet_name']);
$pet_type = $conn->real_escape_string($_POST['pet_type']);
$category = $conn->real_escape_string($_POST['category']);
$description = $conn->real_escape_string($_POST['description']);
$lat = $conn->real_escape_string($_POST['lat']);
$lng = $conn->real_escape_string($_POST['lng']);

$image_paths = array();
$base_upload_dir = "../uploads/pets/"; 

$sqlinsert = "INSERT INTO `tbl_pets` (`user_id`, `pet_name`, `pet_type`, `category`, `description`, `lat`, `lng`, `image_paths`) 
              VALUES ('$user_id', '$pet_name', '$pet_type', '$category', '$description', '$lat', '$lng', '')"; 

try {
    if ($conn->query($sqlinsert) === TRUE) {
        $pet_id = $conn->insert_id;
        $file_base_name = "pet_" . $pet_id;

        for ($i = 1; $i <= 3; $i++) {
            $image_key = 'image_' . $i;
            if (isset($_POST[$image_key]) && !empty($_POST[$image_key])) {
                $encoded_image = $_POST[$image_key];
                $decoded_image = base64_decode($encoded_image);

                $filename = $file_base_name . "_$i.png";
                $path = $base_upload_dir . $filename;

                file_put_contents($path, $decoded_image);

                $image_paths[] = "pawpal/uploads/pets/" . $filename; 
            }
        }

        $image_paths_json = json_encode($image_paths); 
        $sqlupdate = "UPDATE `tbl_pets` SET `image_paths` = '$image_paths_json' WHERE `pet_id` = '$pet_id'";

        if ($conn->query($sqlupdate) === TRUE) {
            $response = array('status' => 'success', 'message' => 'Pet submitted successfully', 'success' => true);
            sendJsonResponse($response);
        } else {
             $conn->query("DELETE FROM `tbl_pets` WHERE `pet_id` = '$pet_id'"); 
            $response = array('status' => 'failed', 'message' => 'Submission failed (DB Update Error)');
            sendJsonResponse($response);
        }

    } else {
        $response = array('status' => 'failed', 'message' => 'Submission failed (DB Insert Error)');
        sendJsonResponse($response);
    }
} catch (Exception $e) {
    $response = array('status' => 'failed', 'message' => 'An exception occurred: ' . $e->getMessage());
    sendJsonResponse($response);
}
?>
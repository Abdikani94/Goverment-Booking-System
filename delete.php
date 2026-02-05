<?php
require "db.php";

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    flash_set("danger", "Invalid request method.");
    header("Location: index.php");
    exit;
}

$id = isset($_POST["id"]) ? (int)$_POST["id"] : 0;
if ($id <= 0) {
    flash_set("danger", "Invalid student ID.");
    header("Location: index.php");
    exit;
}

$stmt = $conn->prepare("DELETE FROM students WHERE id=?");
$stmt->bind_param("i", $id);
$stmt->execute();

flash_set("success", "Student deleted successfully ✅");
header("Location: index.php");
exit;

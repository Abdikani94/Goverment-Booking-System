<?php
// db.php
declare(strict_types=1);

mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

$DB_HOST = "localhost";
$DB_USER = "root";
$DB_PASS = "";
$DB_NAME = "school_db";

try {
    $conn = new mysqli($DB_HOST, $DB_USER, $DB_PASS, $DB_NAME);
    $conn->set_charset("utf8mb4");
} catch (Exception $e) {
    die("Database connection failed: " . htmlspecialchars($e->getMessage()));
}

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// Flash messages
function flash_set(string $type, string $msg): void {
    $_SESSION["flash"] = ["type" => $type, "msg" => $msg];
}
function flash_get(): ?array {
    if (!isset($_SESSION["flash"])) return null;
    $f = $_SESSION["flash"];
    unset($_SESSION["flash"]);
    return $f;
}

// Basic sanitize for output
function e(string $s): string {
    return htmlspecialchars($s, ENT_QUOTES, "UTF-8");
}

// Input cleanup
function clean_str(string $s): string {
    return trim($s);
}

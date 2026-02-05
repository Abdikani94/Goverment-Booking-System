<?php
require "db.php";

$id = isset($_GET["id"]) ? (int)$_GET["id"] : 0;
if ($id <= 0) {
    flash_set("danger", "Invalid student ID.");
    header("Location: index.php");
    exit;
}

$stmt = $conn->prepare("SELECT id, fullname, class, age FROM students WHERE id=?");
$stmt->bind_param("i", $id);
$stmt->execute();
$student = $stmt->get_result()->fetch_assoc();

if (!$student) {
    flash_set("danger", "Student not found.");
    header("Location: index.php");
    exit;
}

$errors = [];
$fullname = $student["fullname"];
$class = $student["class"];
$age = (string)$student["age"];

if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $fullname = clean_str((string)($_POST["fullname"] ?? ""));
    $class    = clean_str((string)($_POST["class"] ?? ""));
    $age      = clean_str((string)($_POST["age"] ?? ""));

    if ($fullname === "" || strlen($fullname) < 3) $errors[] = "Full name must be at least 3 characters.";
    if ($class === "" || strlen($class) < 1)       $errors[] = "Class is required.";
    if ($age === "" || !ctype_digit($age))         $errors[] = "Age must be a valid number.";
    else {
        $ageInt = (int)$age;
        if ($ageInt < 3 || $ageInt > 120) $errors[] = "Age must be between 3 and 120.";
    }

    if (!$errors) {
        $stmt = $conn->prepare("UPDATE students SET fullname=?, class=?, age=? WHERE id=?");
        $ageInt = (int)$age;
        $stmt->bind_param("ssii", $fullname, $class, $ageInt, $id);
        $stmt->execute();

        flash_set("success", "Student updated successfully ✅");
        header("Location: index.php");
        exit;
    }
}
?>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Edit Admission</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<div class="container py-4">
  <div class="d-flex align-items-center justify-content-between mb-3">
    <h4 class="mb-0">Edit Student (ID: <?= $id ?>)</h4>
    <a href="index.php" class="btn btn-outline-secondary">Back</a>
  </div>

  <div class="card shadow-sm">
    <div class="card-body">

      <?php if ($errors): ?>
        <div class="alert alert-danger">
          <ul class="mb-0">
            <?php foreach ($errors as $er): ?>
              <li><?= e($er) ?></li>
            <?php endforeach; ?>
          </ul>
        </div>
      <?php endif; ?>

      <form method="POST" class="row g-3">
        <div class="col-md-6">
          <label class="form-label">Full Name</label>
          <input name="fullname" class="form-control" value="<?= e($fullname) ?>" required>
        </div>

        <div class="col-md-4">
          <label class="form-label">Class</label>
          <input name="class" class="form-control" value="<?= e($class) ?>" required>
        </div>

        <div class="col-md-2">
          <label class="form-label">Age</label>
          <input type="number" name="age" class="form-control" value="<?= e($age) ?>" required>
        </div>

        <div class="col-12 d-flex gap-2">
          <button class="btn btn-warning" type="submit">Update</button>
          <a href="index.php" class="btn btn-light border">Cancel</a>
        </div>
      </form>

    </div>
  </div>
</div>

</body>
</html>

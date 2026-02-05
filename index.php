<?php
include 'db.php';

$q = $_GET['q'] ?? "";

/* Total Registers */
$totalQ = $conn->query("SELECT COUNT(*) AS total FROM students");
$total = $totalQ->fetch_assoc()['total'];

/* Fetch students */
if ($q) {
    $like = "%$q%";
    $stmt = $conn->prepare("SELECT * FROM students WHERE fullname LIKE ? OR class LIKE ? ORDER BY id DESC");
    $stmt->bind_param("ss", $like, $like);
    $stmt->execute();
    $students = $stmt->get_result();
} else {
    $students = $conn->query("SELECT * FROM students ORDER BY id DESC");
}
?>
<!DOCTYPE html>
<html>
<head>
<title>University Admission</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
body{
  min-height:100vh;
  background:
    radial-gradient(1200px 600px at 10% 10%, rgba(13,110,253,.25), transparent 60%),
    radial-gradient(900px 500px at 90% 20%, rgba(25,135,84,.20), transparent 60%),
    linear-gradient(135deg,#0b1220,#101b33,#0f2a2a);
  color:#eef1ff;
}
.glass{
  background:rgba(255,255,255,.08);
  backdrop-filter:blur(12px);
  border-radius:18px;
  border:1px solid rgba(255,255,255,.15);
  box-shadow:0 20px 40px rgba(0,0,0,.35);
}
.table{color:#fff}
.badge-soft{
  background:rgba(255,255,255,.12);
  padding:8px 16px;
  border-radius:20px;
}
input{
  background:rgba(255,255,255,.1)!important;
  color:#fff!important;
}
input::placeholder{color:#ddd}
</style>
</head>

<body>

<div class="container py-5">
  <div class="glass p-4">

    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h3 class="fw-bold mb-1">University Admission</h3>
        <small class="text-light opacity-75">
          Student Registration & Management System
        </small>
      </div>
      <a href="create.php" class="btn btn-primary fw-semibold">
        + New Admission
      </a>
    </div>

    <!-- Search + Total -->
    <div class="d-flex flex-wrap gap-3 justify-content-between align-items-center mb-3">
      <span class="badge-soft">
        Total Registers: <b><?= $total ?></b>
      </span>

      <form class="d-flex gap-2">
        <input name="q" class="form-control" style="min-width:250px"
               placeholder="Search student or class..." value="<?= htmlspecialchars($q) ?>">
        <button class="btn btn-light">Search</button>
        <?php if($q): ?>
          <a href="index.php" class="btn btn-danger">Clear</a>
        <?php endif; ?>
      </form>
    </div>

    <!-- Table -->
    <div class="table-responsive">
      <table class="table table-bordered table-striped align-middle">
        <thead class="table-dark">
          <tr>
            <th>ID</th>
            <th>Student Name</th>
            <th>Program / Class</th>
            <th>Age</th>
            <th width="200">Actions</th>
          </tr>
        </thead>
        <tbody>
        <?php if($students->num_rows == 0): ?>
          <tr>
            <td colspan="5" class="text-center opacity-75">
              No records found
            </td>
          </tr>
        <?php endif; ?>

        <?php while($s = $students->fetch_assoc()): ?>
          <tr>
            <td><?= $s['id'] ?></td>
            <td><?= htmlspecialchars($s['fullname']) ?></td>
            <td>
              <span class="badge bg-primary">
                <?= htmlspecialchars($s['class']) ?>
              </span>
            </td>
            <td><?= $s['age'] ?></td>
            <td class="d-flex gap-2">
              <a href="edit.php?id=<?= $s['id'] ?>" class="btn btn-warning btn-sm">Edit</a>
              <a href="delete.php?id=<?= $s['id'] ?>" 
                 onclick="return confirm('Delete this record?')"
                 class="btn btn-danger btn-sm">Delete</a>
            </td>
          </tr>
        <?php endwhile; ?>
        </tbody>
      </table>
    </div>

    <div class="text-center mt-3 opacity-75">
      University Admission System • Vanilla PHP & Bootstrap
    </div>

  </div>
</div>

</body>
</html>

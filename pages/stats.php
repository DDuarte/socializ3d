<?php

if (!isset($BASE_DIR))
    include_once("../../config/init.php");

$memberId = getLoggedId();

if ($memberId == null) {
    http_response_code(403);
    exit('Not authenticated.');
}

if (!isAdmin($memberId)) {
    http_response_code(403);
    exit('Not an admin.');
}

global $conn;
$stmt = $conn->prepare("SELECT * FROM get_counts_per_month_year(:startDate, :endDate)");
$stmt->execute(array(':startDate' => '2014/01/01', ':endDate' => '2015/01/01'));
$result = $stmt->fetchAll();

if ($result == false) return false;

$smarty->assign('stats', $result);
$smarty->display('admin/stats.tpl');

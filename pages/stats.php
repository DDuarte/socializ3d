<?php

if (!isset($BASE_DIR))
    include_once("../../config/init.php");

$memberId = getLoggedId();

if ($memberId == null) {
    header('HTTP/1.0 403 Forbidden');
    exit('Not authenticated.');
}

if (!isAdmin($memberId)) {
    header('HTTP/1.0 403 Forbidden');
    exit('Not an admin.');
}

global $conn;
$stmt = $conn->prepare("SELECT * FROM get_counts_per_month_year(:startDate, :endDate)");
$stmt->execute(array(':startDate' => '2014/01/01', ':endDate' => '2015/01/01'));
$result = $stmt->fetchAll();

if ($result == false) return false;

$smarty->assign('stats', $result);
$smarty->display('admin/stats.tpl');

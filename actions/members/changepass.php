<?php

include_once('../../config/init.php');
include_once($BASE_DIR . 'database/users.php');

global $BASE_DIR;
global $smarty;

$memberId = getLoggedId();
if ($memberId == null) {
    header('HTTP/1.1 403 Forbidden');
    exit;
}

if (!isset($_POST['old_pass']) || !isset($_POST['new_pass'])) {
    header('HTTP/1.1 400 Bad Request');
    exit;
}

$oldPassword = $_POST['old_pass'];
$newPassword = $_POST['new_pass'];

$verifyOld = checkPassword($memberId, $oldPassword);
if (!$verifyOld) {
    header('HTTP/1.1 401 Wrong password');
    exit;
}

updateMemberPassword($memberId, $newPassword);
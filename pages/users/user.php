<?php

include_once('../../config/init.php');
include_once($BASE_DIR . 'database/users.php');

if (!$_GET['id']) {
    $_SESSION['error_messages'][] = 'Undefined user';
    header("Location: $BASE_URL");
    exit;
}

$id = $_GET['id'];

$model = getUser($id);

$smarty->assign("user", $model);
$smarty->display('users/user.tpl');
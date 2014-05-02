<?php

if (!isset($BASE_DIR))
    include_once("../../config/init.php");

$memberId = getLoggedId();

if ($memberId == null) {
    exit("Not authenticated.");
}

$userInfo = getUserSidebarInfo($memberId);

$smarty->assign('userInfo', $userInfo);
$smarty->display('upload.tpl');

<?php

if (!isset($BASE_DIR))
    include_once('../../config/init.php');

include_once($BASE_DIR .'database/notifications.php');

$memberId = getLoggedId();

if ($memberId == null) {
    header('HTTP/1.0 403 Forbidden');
    exit('Not authenticated.');
}

$notifications = getMemberNotifications(/*$memberId*/ 2, '2010-01-01', 1000); // TODO: pagination

$smarty->assign('notifications', $notifications);
$smarty->display('notifications.tpl');

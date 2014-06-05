<?php

if (!isset($BASE_DIR))
    include_once('../../config/init.php');

include_once($BASE_DIR .'database/notifications.php');

$memberId = getLoggedId();

if ($memberId == null) {
    http_response_code(403);
    return;
}

$notifications = getMemberNotifications($memberId, '2010-01-01', 1000); // TODO: pagination

$smarty->assign('notifications', $notifications);
$smarty->display('notifications.tpl');

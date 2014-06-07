<?php
    include_once($BASE_DIR . 'database/users.php');
    include_once($BASE_DIR . 'database/notifications.php');

    $userInfo = getUserSidebarInfo(getLoggedId());
    $userUnreadNots = getMemberUnreadNotifications($userInfo['userId'], '2010-01-01', 101);
    if (!$userUnreadNots)
        $userUnreadNots = array();
    $smarty->assign('userInfo', $userInfo);
    $smarty->assign('userUnreadNots', $userUnreadNots);
    $smarty->display("common/navbar.tpl");

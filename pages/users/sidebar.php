<?php
    if (!isset($BASE_DIR))
        include_once('../../config/init.php');

    include_once($BASE_DIR .'database/users.php');

    $userInfo = getUserSidebarInfo(getLoggedId());
    $smarty->assign('userInfo', $userInfo);
    $smarty->display('common/sidebar.tpl');

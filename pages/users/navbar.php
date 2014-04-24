<?php
    include_once($BASE_DIR .'database/users.php');

    $userInfo = getUserSidebarInfo(getLoggedId());
    $smarty->assign('userInfo', $userInfo);
    $smarty->display("common/navbar.tpl");

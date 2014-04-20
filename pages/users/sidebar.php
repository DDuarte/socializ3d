<?php
    include_once('../../config/init.php');
    include_once($BASE_DIR .'database/users.php');

    $id = $_GET['id'];
    $userInfo = getUserSidebarInfo($id);
    $smarty->assign('userInfo', $userInfo);
    $smarty->display("common/sidebar.tpl");

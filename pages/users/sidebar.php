<?php
    include_once($BASE_DIR .'database/users.php');

    $id = $_SESSION['id'];
    $userInfo = getUserSidebarInfo($id);
    $smarty->assign('userInfo', $userInfo);
    $smarty->display("common/sidebar.tpl");

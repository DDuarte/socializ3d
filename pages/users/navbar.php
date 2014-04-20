<?php
    include_once('../../config/init.php');
    include_once($BASE_DIR .'database/users.php');

    $id = $_GET['id'];
    $userInfo = getUserNavbarInfo($id);
    $smarty->assign('userInfo', $userInfo);
    $smarty->display("common/navbar.tpl");

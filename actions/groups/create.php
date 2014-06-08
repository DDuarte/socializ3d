<?php

class GroupCreateHandler
{

    function get()
    {
        if (getLoggedId() == null) {
            http_response_code(403);
            return;
        }

        global /** @noinspection PhpUnusedLocalVariableInspection */
        $smarty;
        global $BASE_DIR;
        include($BASE_DIR . 'pages/common/header.php');
        $smarty->display('groups/create.tpl');
        include($BASE_DIR . 'pages/common/footer.php');
    }

    function get_xhr()
    {
        if (getLoggedId() == null) {
            http_response_code(403);
            return;
        }

        global /** @noinspection PhpUnusedLocalVariableInspection */
        $smarty;
        global $BASE_DIR;
        $smarty->display('groups/create.tpl');
    }

    function post() {

        global $BASE_URL;
        $loggedUserId = getLoggedId();
        if ($loggedUserId == null) {
            http_response_code(403);
            exit;
        }

        if (!isset($_POST['about']) || !isset($_POST['cover']) || !isset($_POST['avatar']) || !isset($_POST['name']) || !isset($_POST['visibility'])) {
            http_response_code(400);
            exit;
        }
        if (strlen($_POST['name']) < 1) {
            http_response_code(400);
            exit;
        }
        if ($_POST['visibility'] != 'Public' && $_POST['visibility'] != 'Private') {
            http_response_code(400);
            exit;
        }

        $aboutInfo = trim($_POST['about']);
        if (strlen($aboutInfo) < 1024)
            $aboutInfo = $_POST['about'];
        else
            $aboutInfo = substr($_POST['about'], 0, 1024);

        $coverImg = trim($_POST['cover']);
        if (strlen($coverImg) === 0)
            $coverImg = 'http://placehold.it/1150x200';
        else if (strlen($coverImg) < 255)
            $coverImg = $_POST['cover'];
        else
            $coverImg = substr($coverImg, 0, 255);


        $avatarImg = trim($_POST['avatar']);
        if (strlen($avatarImg) === 0)
            $avatarImg = 'http://placehold.it/250x250';
        else if (strlen($avatarImg) < 255)
            $avatarImg = $_POST['avatar'];
        else
            $avatarImg = substr($avatarImg, 0, 255);

        $groupName = trim($_POST['name']);
        if (strlen($groupName) < 70)
            $groupName = $_POST['name'];
        else
            $groupName = substr($groupName, 0, 70);

        $visibility = strtolower($_POST['visibility']);

        $groupId = createGroup($loggedUserId, $groupName, $aboutInfo, $coverImg, $avatarImg, $visibility);
        header("Location: {$BASE_URL}groups/$groupId");
    }
}

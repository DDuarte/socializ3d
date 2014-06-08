<?php

include_once($BASE_DIR . 'database/groups.php');

function getGroupPage($group) {
    global $smarty;
    $memberId = getLoggedId();
    $member = array('id' => $memberId);
    $member['lastaccess'] = getMemberLastAccess($group['id'], $memberId);
    $smarty->assign('group', $group);
    $smarty->assign('visitor', $member);
    $smarty->display('groups/group.tpl');
}

function updateLastAccess($group, $memberId) {
    global $conn;

    $stmt = $conn->prepare("UPDATE GroupUser SET lastAccess = now()::timestamp(0) WHERE idGroup = ? AND idMember = ?");
    $stmt->execute(array($group, $memberId));
}

class GroupHandler {
    function get($groupId) {
        global $smarty;
        global $BASE_DIR;
        global $conn;

        $memberId = getLoggedId();

        if (!isGroupVisibleToMember($groupId, $memberId)) {
            http_response_code(404);
            return;
        }

        $group = getGroup($groupId);
        if ($group == false) {
            http_response_code(404);
            return;
        }

        include($BASE_DIR . 'pages/common/header.php');
        getGroupPage($group);
        include($BASE_DIR . 'pages/common/footer.php');

        updateLastAccess($groupId, $memberId);
    }

    function get_xhr($groupId) {
        global $BASE_DIR;
        global $smarty;
        global $conn;

        $memberId = getLoggedId();

        if (!isGroupVisibleToMember($groupId, $memberId)) {
            http_response_code(404);
            exit;
        }

        $group = getGroup($groupId);
        if ($group == false) {
            http_response_code(404);
            exit;
        }

        getGroupPage($group);
        updateLastAccess($groupId, $memberId);
        exit;
    }

    function post($id) {
        $loggedUserId = getLoggedId();
        if (!isGroupAdmin($id, $loggedUserId) && !isAdmin($loggedUserId)) {
            http_response_code(403);
            exit;
        }

        if (!isset($_POST['about']) || !isset($_POST['cover']) || !isset($_POST['avatar'])) {
            http_response_code(400);
            return;
        }

        $aboutInfo = trim($_POST['about']);
        if (strlen($aboutInfo) < 1024)
            $aboutInfo = $_POST['about'];
        else
            $aboutInfo = substr($_POST['about'], 0, 1024);

        $coverImg = trim($_POST['cover']);
        if (strlen($coverImg) < 255)
            $coverImg = $_POST['cover'];
        else
            $coverImg = substr($coverImg, 0, 255);


        $avatarImg = trim($_POST['avatar']);
        if (strlen($avatarImg) < 255)
            $avatarImg = $_POST['avatar'];
        else
            $avatarImg = substr($avatarImg, 0, 255);

        updateGroupInfo($id, $aboutInfo, $coverImg, $avatarImg);
    }
}

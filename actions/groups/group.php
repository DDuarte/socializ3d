<?php

include_once($BASE_DIR . 'database/groups.php');

function getGroupPage($group) {
    global $smarty;
    $memberId = getLoggedId();
    $member = array();
    if ($memberId)
        $member['id'] = $memberId;
    else
        $member['id'] = -1;
    $member['lastaccess'] = getMemberLastAccess($group['id'], $memberId);
    $group['models'] = array_reverse($group['models']);
    $member['groupShares'] = array();
    if ($group['isGroupAdmin'])
        $member['groupShares'] = $group['models'];
    else {
        foreach ($group['models'] as $mod) {
            if ($mod['idauthor'] === $memberId)
                $member['groupShares'][] = $mod;
        }
    }
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

        if (!$memberId)
            $memberId = -1;
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

        if (!isset($_POST['about']) || !isset($_POST['cover']) || !isset($_POST['avatar']) || !isset($_POST['visibility'])) {
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

        $visibility = strtolower($_POST['visibility']);

        updateGroupInfo($id, $aboutInfo, $coverImg, $avatarImg, $visibility);
    }
}

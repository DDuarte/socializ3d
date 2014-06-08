<?php

include_once($BASE_DIR . 'database/users.php');

function getMemberPage($member) {
    global $smarty;
    $userInfo = getUserSidebarInfo(getLoggedId());
    $differentGroups = array();
    if ($userInfo){
        foreach ($userInfo['groups'] as $g1) {
            $otherIsInGroup = false;
            foreach ($member['groups'] as $g2) {
                if ($g1['groupid'] == $g2['id']) {
                    $otherIsInGroup = true;
                    break;
                }
            }
            if (!$otherIsInGroup)
                $differentGroups[] = $g1;
        }
    }
    $smarty->assign('userInfo', $userInfo);
    $smarty->assign('member', $member);
    $smarty->assign('diffGroups', $differentGroups);
    $smarty->display('members/member.tpl');
}

class MemberHandler {
    function get_xhr($memberId) {
        global $smarty;

        $member = getMember($memberId, getLoggedId());
        if ($member == false) {
            http_response_code(404);
            return;
        }
        getMemberPage($member);
    }

    function get($memberId) {
        global $BASE_DIR;
        global $smarty;

        $member = getMember($memberId, getLoggedId());
        if ($member == false) {
            http_response_code(404);
            return;
        }

        include($BASE_DIR . 'pages/common/header.php');
        getMemberPage($member);
        include($BASE_DIR . 'pages/common/footer.php');
    }

    function post($memberId) {
        global $BASE_DIR;
        global $smarty;

        $loggedUserId = getLoggedId();
        if ($memberId != $loggedUserId && !loggedIsAdmin()) {
            http_response_code(403);
            return;
        }

        if (!isset($_POST['about']) || !isset($_POST['interests'])) {
            http_response_code(400);
            return;
        }

        $aboutInfo = htmlspecialchars(stripslashes((trim($_POST['about']))));
        if (strlen($aboutInfo) < 1024)
            $aboutInfo = $_POST['about'];
        else
            $aboutInfo = substr($_POST['about'], 0, 1024);

        updateUserAbout($memberId, $aboutInfo);

        $interestsArray = explode(',', $_POST['interests']);
        foreach($interestsArray as $key => $value) {
            $interestsArray[$key] = stripslashes(strip_tags(trim($value)));
        }

        $prevInterests = getMemberInterests($memberId);
        $toDelete = array_diff($prevInterests, $interestsArray);
        deleteUserInterests($memberId, $toDelete);

        $toInsert = array_diff($interestsArray, $prevInterests);
        insertUserInterests($memberId, $toInsert);
    }
}

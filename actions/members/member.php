<?php

include_once($BASE_DIR . 'database/users.php');

function getMemberPage($member) {
    global $smarty;
    $userInfo = getUserSidebarInfo(getLoggedId());
    $smarty->assign('userInfo', $userInfo);
    $smarty->assign('member', $member);
    $smarty->display('members/member.tpl');
}

class MemberHandler {
    function get_xhr($memberId) {
        global $smarty;

        $member = getMember($memberId, getLoggedId());
        if ($member == false) {
            $smarty->display("common/404.tpl");
            exit;
        }
        getMemberPage($member);
    }

    function get($memberId) {
        global $BASE_DIR;
        global $smarty;

        $member = getMember($memberId, getLoggedId());
        if ($member == false) {
            include($BASE_DIR . "pages/404.php");
            exit;
        }

        include($BASE_DIR . 'pages/common/header.php');
        getMemberPage($member);
        include($BASE_DIR . 'pages/common/footer.php');
    }

    function post($memberId) {
        global $BASE_DIR;
        global $smarty;

        $loggedUserId = getLoggedId();
        if ($memberId != $loggedUserId) {
            header('HTTP/1.1 403 Forbidden');
            exit;
        }

        if (!isset($_POST['about']) || !isset($_POST['interests'])) {
            header('HTTP/1.1 400 Bad Request');
            exit;
        }

        $aboutInfo = trim($_POST['about']);
        if (strlen($aboutInfo) < 1024)
            $aboutInfo = $_POST['about'];
        else
            $aboutInfo = substr($_POST['about'], 0, 1024);

        updateUserAbout($memberId, $aboutInfo);

        $interestsArray = explode(',', $_POST['interests']);
        foreach($interestsArray as $key => $value) {
            $interestsArray[$key] = trim($value);
        }

        $prevInterests = getMemberInterests($memberId);
        $toDelete = array_diff($prevInterests, $interestsArray);
        deleteUserInterests($memberId, $toDelete);

        $toInsert = array_diff($interestsArray, $prevInterests);
        insertUserInterests($memberId, $toInsert);
    }
}

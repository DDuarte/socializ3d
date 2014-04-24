<?php

include_once($BASE_DIR . 'database/users.php');

function getMemberPage($member) {
    global $smarty;
    $smarty->assign("member", $member);
    $smarty->display('members/member.tpl');
}

class MemberHandler {
    function get_xhr($memberId) {
        global $smarty;

        $member = getMember($memberId);
        if ($member == false) {
            $smarty->display("common/404.tpl");
            exit;
        }
        getMemberPage($member);
    }

    function get($memberId) {
        global $BASE_DIR;
        global $smarty;

        $member = getMember($memberId);
        if ($member == false) {
            include($BASE_DIR . "pages/404.php");
            exit;
        }

        include($BASE_DIR . 'pages/common/header.php');
        getMemberPage($member);
        include($BASE_DIR . 'pages/common/footer.php');
    }
}
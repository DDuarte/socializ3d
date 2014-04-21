<?php

include_once($BASE_DIR . 'database/users.php');

function getMemberPage($memberId) {
    global $smarty;
    $member = getMember($memberId);
    $smarty->assign("member", $member);
    $smarty->display('members/member.tpl');
}

class MemberHandler {
    function get($memberId) {
        getMemberPage($memberId);
    }
}

class CompleteMemberHandler {
    function get($memberId) {
        global $smarty;
        global $BASE_DIR;
        include($BASE_DIR . 'pages/common/header.php');
        getMemberPage($memberId);
        include($BASE_DIR . 'pages/common/footer.php');
    }
}
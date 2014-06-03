<?php

include_once($BASE_DIR . 'database/groups.php');

function getGroupPage($group) {
    global $smarty;
    $smarty->assign('group', $group);
    $smarty->display('groups/group.tpl');
}

class GroupHandler {
    function get($groupId) {
        global $smarty;
        global $BASE_DIR;

        if (!isGroupVisibleToMember($groupId, getLoggedId())) {
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
    }

    function get_xhr($groupId) {
        global $BASE_DIR;
        global $smarty;

        if (!isGroupVisibleToMember($groupId, getLoggedId())) {
            http_response_code(404);
            return;
        }

        $group = getGroup($groupId);
        if ($group == false) {
            http_response_code(404);
            return;
        }

        getGroupPage($group);
    }
}

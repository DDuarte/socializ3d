<?php

include_once($BASE_DIR . 'database/users.php');
include_once($BASE_DIR . 'database/groups.php');


class GroupMemberHandler {
    function post($groupId, $otherMemberId) {
        global $BASE_DIR;
        global $smarty;

        $memberId = getLoggedId();
        if ($memberId == null) {
            http_response_code(403);
            exit;
        }

        if (!isGroupAdmin($groupId, $memberId)) {
            http_response_code(403);
            exit;
        }

        if (!isGroupMember($groupId, $otherMemberId)) {
            http_response_code(404);
            exit;
        }

        if (!isset($_POST['adm'])) {
            http_response_code(400);
            exit;
        }

        $value = filter_var($_POST['adm'], FILTER_VALIDATE_BOOLEAN);
        updateGroupUserStatus($groupId, $otherMemberId, $value == 1);
    }

    function delete($groupId, $otherMemberId) {
        global $BASE_DIR;
        global $smarty;

        $memberId = getLoggedId();
        if ($memberId == null) {
            http_response_code(403);
            exit;
        }

        if (!isGroupAdmin($groupId, $memberId)) {
            http_response_code(403);
            exit;
        }

        if (!isGroupMember($groupId, $otherMemberId)) {
            http_response_code(404);
            exit;
        }

        if (isGroupAdmin($groupId, $otherMemberId)) {
            http_response_code(401);
            exit;
        }

        removeGroupUser($groupId, $otherMemberId);
    }
}
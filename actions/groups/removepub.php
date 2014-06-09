<?php

include_once($BASE_DIR . 'database/users.php');
include_once($BASE_DIR . 'database/groups.php');


class PublicationHandler {
    function delete($groupId, $pubId) {
        global $BASE_DIR;
        global $smarty;

        $memberId = getLoggedId();
        if ($memberId == null) {
            http_response_code(403);
            exit;
        }

        $pub = getGroupPub($groupId, $pubId);
        if (!$pub) {
            http_response_code(404);
            exit;
        }

        if (!isGroupAdmin($groupId, $memberId) && $memberId !== $pub['idauthor'] && !isAdmin($memberId)) {
            http_response_code(403);
            exit;
        }

        removeGroupPublication($groupId, $pubId);
    }
}
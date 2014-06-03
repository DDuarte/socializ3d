<?php

include_once($BASE_DIR . 'database/models.php');

class VotesHandler {
    function post($modelId) { // TODO: xhr
        global $BASE_DIR;
        global $smarty;

        $loggedUserId = getLoggedId();
        if ($loggedUserId == null) {
            http_response_code(403);
            return;
        }


        if (!isset($_POST['vote'])) {
            http_response_code(400);
            return;
        }

        $value = filter_var($_POST['vote'], FILTER_VALIDATE_BOOLEAN);
        $currentVote = getUserVote($loggedUserId, $modelId);
        if ($currentVote === null) {
            insertUserVote($loggedUserId, $modelId, $value == 1);
        }
        else {
            changeUserVote($loggedUserId, $modelId, $value == 1);
        }
    }
}

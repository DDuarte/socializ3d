<?php

include_once($BASE_DIR . 'database/models.php');

class VotesHandler {
    function post($modelId) { // TODO: xhr
        global $BASE_DIR;
        global $smarty;

        $loggedUserId = getLoggedId();
        if ($loggedUserId == null) {
            header('HTTP/1.1 403 Forbidden');
            exit;
        }


        if (!isset($_POST['vote'])) {
            header('HTTP/1.1 400 Bad Request');
            exit;
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

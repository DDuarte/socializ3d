<?php

include_once($BASE_DIR . 'database/models.php');

function getComments($comments) {
    global $smarty;
    $smarty->assign("comments", $comments);
    $smarty->display('models/comments.tpl');
}

class CommentsHandler {
    function post($modelId) { // TODO: xhr
        global $BASE_DIR;
        global $smarty;

        $memberId = getLoggedId();
        if (!$memberId) {
            http_response_code(403);
            return;
        }

        if (isset($_POST['content']) && strlen($_POST['content']) > 0)
            insertComment($memberId, $modelId, htmlspecialchars(stripslashes($_POST['content'])));

        header('Location: ' . $_SERVER['HTTP_REFERER'] . '#tab_comments');
    }

    function delete($modelId, $commentId) {
        global $BASE_DIR;
        global $smarty;

        $comment = getComment($commentId);
        if($comment == null) {
            http_response_code(404);
            return;
        }
        if (getLoggedId() != $comment['idmember']) {
            http_response_code(403);
            return;
        }

        deleteComment($modelId, $commentId);
    }
}

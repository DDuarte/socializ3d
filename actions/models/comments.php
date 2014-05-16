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

        if (isset($_POST['content']) && strlen($_POST['content']) > 0)
            insertComment(getLoggedId(), $modelId, $_POST['content']);

        header('Location: ' . $_SERVER['HTTP_REFERER'] . '#tab_comments');
    }

    function delete($modelId, $commentId) {
        global $BASE_DIR;
        global $smarty;


        $comment = getComment($commentId);
        if($comment == null) {
            header('HTTP/1.1 404 Not Found');
            exit;
        }
        if (getLoggedId() != $comment['idmember']) {
            header('HTTP/1.1 403 Forbidden');
            exit;
        }

        deleteComment($modelId, $commentId);
    }
}

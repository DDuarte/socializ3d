<?php

include_once('/opt/lbaw/lbaw1313/public_html/proto/database/models.php');

function getComments($comments) {
    global $smarty;
    $smarty->assign("comments", $comments);
    $smarty->display('models/comments.tpl');
}

class CommentsHandler {
    function post($modelId) { // TODO: xhr
        global $BASE_DIR;
        global $smarty;
        echo $BASE_DIR . 'hi';
        
        insertComment(getLoggedId(), $modelId, $_POST['content']);

        header('Location: ' . $_SERVER['HTTP_REFERER']);
    }
}

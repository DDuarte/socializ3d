<?

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

        insertComment(getLoggedId(), $modelId, $_POST['content']);

        header('Location: ' . $_SERVER['HTTP_REFERER']);
    }
}

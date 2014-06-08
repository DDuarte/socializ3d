<?php

include_once('users.php');

function getModel($id)
{
    global $conn;
    $stmt = $conn->prepare("SELECT * FROM get_model_info(?)");
    $stmt->execute(array($id));
    $result = $stmt->fetch();

    if ($result == false) return false;

    $result['id'] = $id;
    $result['hash'] = getMemberHash($result['idauthor']);
    $result['comments'] = getModelComments($id);
    $result['numComments'] = count($result['comments']);
    $result['tagsArray'] = getModelTags($id);

    $loggedUserId = getLoggedId();
    if ($loggedUserId != null) {
        $result['userVote'] = getUserVote($loggedUserId, $id);
    }
    else
        $result['userVote'] = null;

    $tagsNames = array();
    foreach($result['tagsArray'] as $tag)
        array_push($tagsNames, $tag['name']);

    $result['tags'] = implode(', ', $tagsNames);
    return $result;
}

function getModelComments($id)
{
    global $conn;
    $stmt = $conn->prepare("SELECT * FROM get_model_comments(?)");
    $stmt->execute(array($id));
    $comments = $stmt->fetchAll();
    foreach ($comments as $key => $comment) {
        $comments[$key]['createdate'] = date(DATE_ISO8601, strtotime($comment['createdate']));
        $comments[$key]['idmodel'] = $id;
    }
    return $comments;
}

function isModelVisibleToMember($modelId, $memberId) {
    global $conn;
    $stmt = $conn->prepare("SELECT 1 FROM get_all_visibile_models(:memberId) WHERE id = :modelId");
    $stmt->execute(array(":memberId" => $memberId, ":modelId" => $modelId));
    return $stmt->fetch() != false;
}

function getModelTags($id)
{
    global $conn;
    $stmt = $conn->prepare("SELECT * FROM model_tags WHERE idModel = ?");
    $stmt->execute(array($id));
    return $stmt->fetchAll();
}

function insertUserVote($userId, $modelId, $newVote)
{
    global $conn;
    $stmt = $conn->prepare("INSERT INTO Vote(idMember, idModel, upVote) VALUES (?, ?, ?);");
    $stmt->execute(array($userId, $modelId, $newVote ? "true" : "false"));
}

function getUserVote($loggedUserId, $modelId)
{
    global $conn;
    $stmt = $conn->prepare("SELECT * FROM Vote WHERE idModel = ? AND idMember = ?");
    $stmt->execute(array($modelId, $loggedUserId));
    $result = $stmt->fetchAll();
    if (count($result) > 0)
        return $result[0]['upvote'] ? 1 : 0; //or else it would return null when false
    return null;
}

function changeUserVote($userId, $modelId, $newVote)
{
    global $conn;
    $stmt = $conn->prepare("UPDATE Vote SET upVote = ? WHERE idModel = ? AND idMember = ?");
    $stmt->execute(array($newVote ? "true" : "false", $modelId, $userId));
}

function getComment($id)
{
    global $conn;
    $stmt = $conn->prepare("SELECT * FROM TComment WHERE id = ?");
    $stmt->execute(array($id));
    $result = $stmt->fetchAll();
    if (count($result) > 0)
        return $result[0];
    return null;
}

function deleteComment($idModel, $idComment)
{
    global $conn;
    $stmt = $conn->prepare("UPDATE TComment SET deleted = true WHERE idModel = ? AND id = ?");
    $stmt->execute(array($idModel, $idComment));
}

function _getModels($func, $memberId, $numModels, $numSkip) {
    global $conn;
    global $BASE_DIR;
    $stmt = $conn->prepare("SELECT * FROM " . $func . "(?, ?, ?)");
    $stmt->execute(array($numModels, $numSkip, $memberId));
    $modelIds = $stmt->fetchAll();
    $models = array();

    foreach($modelIds as $modelId) {
        $model_stmt = $conn->prepare("SELECT *, (get_thumbnail_information(Model.id)).*, get_user_hash(Model.idAuthor) AS authorHash FROM Model WHERE Model.id = ?");
        $model_stmt->execute(array($modelId['modelid']));
        array_push($models, $model_stmt->fetch());
    }

    foreach ($models as $key => $model) {
        $models[$key]['hasThumbnail'] = file_exists($BASE_DIR . "/thumbnails/" . $model['id'] . ".png");
    }

    return $models;
}

function getTopRatedModels($memberId, $numModels, $numSkip) {
    return _getModels('get_top_rated_models', $memberId, $numModels, $numSkip);
}

function getWhatsHotModels($memberId, $numModels, $numSkip) {
    return _getModels('get_whats_hot_models', $memberId, $numModels, $numSkip);
}

function getNewModels($memberId, $numModels, $numSkip) {
    return _getModels('get_new_models', $memberId, $numModels, $numSkip);
}

function getRandomModels($memberId, $numModels, $numSkip) {
    return _getModels('get_random_models', $memberId, $numModels, $numSkip);
}

function insertComment($memberId, $modelId, $content) {
    global $conn;
    $stmt = $conn->prepare("INSERT INTO TComment(idMember, idModel, content) VALUES (?, ?, ?)");
    $stmt->execute(array($memberId, $modelId, $content));
}


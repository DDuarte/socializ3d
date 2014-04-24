<?php

include_once('users.php');

function getModel($id)
{
    global $conn;
    $stmt = $conn->prepare("SELECT * FROM get_model_info(?)");
    $stmt->execute(array($id));
    $result = $stmt->fetch();

    if ($result == false) return false;

    $result['createdate'] = date(DATE_ISO8601, strtotime($result['createdate']));
    $result['hash'] = getMemberHash($result['idauthor']);
    $result['comments'] = getModelComments($id);
    $result['numComments'] = count($result['comments']);
    $result['tags'] = getModelTags($id);
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
    }
    return $comments;
}

function getModelTags($id)
{
    global $conn;
    $stmt = $conn->prepare("SELECT * FROM model_tags WHERE idModel = ?");
    $stmt->execute(array($id));
    return $stmt->fetchAll();
}

function _getModels($func, $memberId, $numModels, $numSkip) {
    global $conn;
    $stmt = $conn->prepare("SELECT * FROM " . $func . "(?, ?, ?)");
    $stmt->execute(array($numModels, $numSkip, $memberId));
    $modelIds = $stmt->fetchAll();
    $models = array();

    foreach($modelIds as $modelId) {
        $model_stmt = $conn->prepare("SELECT *, (get_thumbnail_information(Model.id)).*, get_user_hash(Model.idAuthor) AS authorHash FROM Model WHERE Model.id = ?");
        $model_stmt->execute(array($modelId['modelid']));
        array_push($models, $model_stmt->fetch());
    }

    return $models;
}

function getTopRatedModels($memberId, $numModels, $numSkip) {
    return _getModels('get_top_rated_models', $memberId, $numModels, $numSkip);
}

function getWhatsHotModels($memberId, $numModels, $numSkip) {
    return _getModels('get_whats_hot_models', $memberId, $numModels, $numSkip);
}

function getPopularModels($memberId, $numModels, $numSkip) {
    return _getModels('get_new_models', $memberId, $numModels, $numSkip);
}

function getRandomModels($memberId, $numModels, $numSkip) {
    return _getModels('get_random_models', $memberId, $numModels, $numSkip);
}
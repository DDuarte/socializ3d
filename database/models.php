<?php

include_once('users.php');

function getModel($id)
{
    global $conn;
    $stmt = $conn->prepare("SELECT * FROM get_model_info(?)");
    $stmt->execute(array($id));
    $result = $stmt->fetch();

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
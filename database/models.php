<?php

include_once('users.php');

function getModel($id)
{
    global $conn;
    $stmt = $conn->prepare("SELECT * FROM get_model_info(?)");
    $stmt->execute(array($id));
    $result = $stmt->fetch();
    $result['hash'] = getUserHash($result['idauthor']);
    $result['comments'] = getModelComments($id);
    $result['numComments'] = count($result['comments']);
    return $result;
}

function getModelComments($id)
{
    global $conn;
    $stmt = $conn->prepare("SELECT * FROM get_model_comments(?)");
    $stmt->execute(array($id));
    return $stmt->fetchAll();
}
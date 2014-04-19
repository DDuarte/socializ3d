<?php

function getUser($id)
{
    return null;
}

function getUserHash($id)
{
    global $conn;
    $stmt = $conn->prepare("SELECT * FROM get_user_hash(?)");
    $stmt->execute(array($id));
    $result = $stmt->fetch();
    return $result['get_user_hash'];
}

function getUserInfo($id) {
    global $conn;
    $stmt = $conn->prepare("SELECT Member.name FROM Member WHERE Member.id = ?");
    $stmt->execute(array($id));
    $username = $stmt->fetchAll()[0];

    $stmt = $conn->prepare("SELECT * FROM get_complete_friends_of_member(?)");
    $stmt->execute(array($id));
    $friends = $stmt->fetchAll();

    $stmt = $conn->prepare("SELECT * FROM get_complete_groups_of_member(?)");
    $stmt->execute((array($id)));
    $groups = $stmt->fetchAll();

    $result['userId'] = $id;
    $result['username'] = $username;
    $result['friends'] = $friends;
    $result['groups'] = $groups;

    return $result;
}

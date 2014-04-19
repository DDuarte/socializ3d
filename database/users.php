<?php

function getUserHash($id)
{
    global $conn;
    $stmt = $conn->prepare("SELECT * FROM get_user_hash(?)");
    $stmt->execute(array($id));
    $result = $stmt->fetch();
    return $result['get_user_hash'];
}
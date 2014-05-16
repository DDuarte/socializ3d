<?php

// include_once('users.php');

function getGroup($id)
{
    global $conn;
    $stmt = $conn->prepare("SELECT * FROM get_group_profile(?, ?)");
    $stmt->execute(array(getLoggedId(), $id));
    $result = $stmt->fetch();

    if ($result == false) return false;

    $result['id'] = $id;

    return $result;
}

function isGroupVisibleToMember($groupId, $memberId) {
    global $conn;
    $stmt = $conn->prepare("SELECT 1 FROM get_group_profile(:memberId, :groupId)");
    try {
        $stmt->execute(array(":memberId" => $memberId, ":groupId" => $groupId));
        $stmt->fetch();
        return true;
    } catch (PDOException $e) {
        return false;
    }
}

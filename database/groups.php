<?php

// include_once('users.php');

function getGroup($id) {
    global $conn;
    $stmt = $conn->prepare("SELECT * FROM get_group_profile(?, ?)");
    $stmt->execute(array(getLoggedId(), $id));
    $result = $stmt->fetch();

    if ($result == false) return false;

    $result['id'] = $id;
    $result['models'] = getGroupModels($id);

    return $result;
}

function getGroupModels($id) {
    $loggedId = getLoggedId();

    global $conn;
    $stmt = $conn->prepare("SELECT *, (get_thumbnail_information(Model.id)).*, get_user_hash(Model.idAuthor) AS authorHash FROM Model JOIN get_group_models(1000, 0, :logged_id, :id) ON (Model.id = modelId)");
    $stmt->execute(array(':id' => $id, ':logged_id' => $loggedId));
    return $stmt->fetchAll();
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

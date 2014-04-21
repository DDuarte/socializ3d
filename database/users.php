<?php

function getMember($id)
{
    global $conn;
    $stmt = $conn->prepare("SELECT Member.name,
                                   Member.about,
                                   Member.birthDate,
                                   get_user_hash(:id) AS hash
                            FROM Member
                            WHERE Member.id = :id");
    $stmt->execute(array(':id' => $id));
    $result = $stmt->fetch();
    $result['models'] = getMemberModels($id);
    $result['friends'] = getFriendsOfMember($id);
    $result['groups'] = getGroupsOfMember($id);
    return $result;
}

function getFriendsOfMember($id)
{
    global $conn;
    $stmt = $conn->prepare("SELECT memberid AS id, membername AS name, hash, about FROM get_complete_friends_of_member(:id)");
    $stmt->execute(array(':id' => $id));
    $result = $stmt->fetchAll();

    foreach ($result as $key => $value) {
        $result[$key]['isFriend'] = true;
    }

    return $result;
}

function getGroupsOfMember($id)
{
    global $conn;
    $stmt  = $conn->prepare("SELECT groupid AS id, groupname AS name, about, coverimg FROM get_complete_groups_of_member(:id)");
    $stmt->execute(array(':id' => $id));
    $result = $stmt->fetchAll();

    foreach ($result as $key => $value) {
        $result[$key]['memberInGroup'] = true;
    }

    return $result;
}

function getMemberModels($id)
{
    global $conn;
    $stmt = $conn->prepare("SELECT *, (get_thumbnail_information(Model.id)).*, get_user_hash(Model.idAuthor) AS authorHash FROM Model WHERE idAuthor = :id");
    $stmt->execute(array(':id' => $id));
    return $stmt->fetchAll();
}

function getMemberHash($id)
{
    global $conn;
    $stmt = $conn->prepare("SELECT * FROM get_user_hash(?)");
    $stmt->execute(array($id));
    $result = $stmt->fetch();
    return $result['get_user_hash'];
}

function getUserSidebarInfo($id) {
    global $conn;
    $stmt = $conn->prepare("SELECT Member.name FROM Member WHERE Member.id = ?");
    $stmt->execute(array($id));
    $username = $stmt->fetch()['name'];

    $stmt = $conn->prepare("SELECT * FROM get_complete_friends_of_member(?)");
    $stmt->execute(array($id));
    $friends = $stmt->fetchAll();

    $stmt = $conn->prepare("SELECT * FROM get_complete_groups_of_member(?)");
    $stmt->execute((array($id)));
    $groups = $stmt->fetchAll();

    $userHash = getMemberHash($id);

    $result['userId'] = $id;
    $result['username'] = $username;
    $result['userHash'] = $userHash;
    $result['friends'] = $friends;
    $result['groups'] = $groups;

    return $result;
}

function getUserNavbarInfo($id) {
    global $conn;
    $stmt = $conn->prepare("SELECT Member.name FROM Member WHERE Member.id = ?");
    $stmt->execute(array($id));
    $username = $stmt->fetch()['name'];

    $userHash = getMemberHash($id);

    $result['userId'] = $id;
    $result['username'] = $username;
    $result['userHash'] = $userHash;

    return $result;
}

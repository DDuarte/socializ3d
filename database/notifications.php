<?php

function getMemberNotifications($id, $dateLimit, $numLimit)
{
    global $conn;
    $stmt = $conn->prepare("SELECT * FROM get_member_notifications(:id, :date, :limit)");
    $stmt->execute(array(
        ':id' => $id,
        ':date' => $dateLimit,
        ':limit' => $numLimit
    ));

    $result = $stmt->fetchAll();

    if ($result == false) return false;

    $newResult = Array();
    foreach ($result as $r) {
        $date = $r['createdate'];
        $day = date('d M. Y', strtotime($date));
        $newResult[$day][] = $r;
    }

    return $newResult;
}

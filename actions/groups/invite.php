<?php

include_once($BASE_DIR . 'database/users.php');
include_once($BASE_DIR . 'database/groups.php');


class InvitationHandler {
    function post($groupId, $newMemberId) {
        global $BASE_DIR;
        global $smarty;

        $memberId = getLoggedId();
        if ($memberId == null) {
            http_response_code(403);
            exit;
        }

        $otherMember = getMember($newMemberId, $memberId);
        if ($otherMember == null) {
            http_response_code(404); // Member not found
            exit;
        }

        $groupMembers = getMembersOfGroup($groupId);
        $thisIsMember = false;
        $otherIsMember = false;
        foreach ($groupMembers as $mem) {
            if ($mem['memberid'] == $memberId)
                $thisIsMember = true;
            if ($mem['memberid'] == $newMemberId)
                $otherIsMember = true;
        }

        if (!$thisIsMember) {
            http_response_code(403);
            exit;
        }
        if ($otherIsMember) {
            http_response_code(409); //other is member
            exit;
        }


        $otherRequests = getUnansweredGroupInvitesOfMember($newMemberId);
        $alreadySent = false;
        foreach ($otherRequests as $key => $value) {
            if ($otherRequests[$key]['idgroup'] == $groupId) {
                $alreadySent = true;
                break;
            }
        }
        if ($alreadySent) {
            http_response_code(409); // Member has already received a request to join this group
            exit;
        }

        createGroupInvite($memberId, $newMemberId, $groupId);
        echo 'done';
    }

    function delete($otherMemberId) {
        global $BASE_DIR;
        global $smarty;

        //TODO
    }
}
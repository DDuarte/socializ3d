<?php
if (!isset($BASE_DIR))
    include_once('../../config/init.php');

include_once($BASE_DIR . 'database/users.php');
require_once($BASE_DIR . 'lib/PHPMailer/class.phpmailer.php');

function getPassChangePage($member, $memHash) {
    global $smarty;

    $smarty->assign('member', $member);
    $smarty->assign('memHash', $memHash);
    $smarty->display('members/passchange.tpl');
}

class ForgotPassHandler
{
    function get ($id)
    {
        global $BASE_DIR;
        global $smarty;

        if (!isset($_GET['usrhash'])) {
            http_response_code(400);
            return;
        }

        $memHash = getMemberPassChangeHash($id);
        if (!$memHash) {
            http_response_code(404);
            return;
        }

        if ($memHash != $_GET['usrhash']) {
            http_response_code(400);
            return;
        }

        $member = getSimpleMember($id, 0);
        if (!$member) {
            http_response_code(404);
            return;
        }

        getPassChangePage($member, $memHash);

    }

    function post($id) {
        global $BASE_URL;
        if ($id === null) {
            http_response_code(400);
            return;
        }

        $memberHash = getMemberPassChangeHash($id);
        if (!$memberHash) {
            http_response_code(404);
            return;
        }

        if (!isset($_POST['password']) || !isset($_POST['password2']) || !isset($_GET['usrhash'])) {
            http_response_code(400);
            return;
        }

        $oldPassword = $_POST['password'];
        $newPassword = $_POST['password2'];
        if ($oldPassword !== $newPassword || $memberHash !== $_GET['usrhash']) {
            http_response_code(400);
            return;
        }

        updateMemberPassword($id, $newPassword);
        $_SESSION['error_messages'][] = 'Password changed successfully!';
        header("Location: $BASE_URL" . "login.php");
    }

    function put($id) {
        global $BASE_URL;
        if(!isset($_GET['email'])) {
            http_response_code(400);
            exit;
        }
        $memEmail = $_GET['email'];
        $member = getMemberFromEmail($memEmail);
        $memHash = getMemberPassChangeHash($member['id']);

        if (!$member || !$memHash) {
            http_response_code(404);
            exit;
        }

        $memRecoveryURL = $BASE_URL . 'members/' . $member['id'] . '/forgotpass?usrhash=' . $memHash;
        $memRec = "<a href=\"$memRecoveryURL\">$memRecoveryURL</a>";

        $message = 'Hello ' . $member['username'] . '!<br/><br/>We are sending you this email' .
            ' because someone requested a password reset for your account. If it was not you who did this, please disregard it.' .
            '<br/><br/>Click the following link to reset your password:<br/>' . $memRec . '<br/><br/>See you soon,<br/>The Socializ3d team';



        $mail = new PHPMailer(); // defaults to using php "mail()"

        $mail->IsSMTP();

        $mail->SMTPAuth   = true;                  // enable SMTP authentication
        $mail->SMTPSecure = "tls";                 // sets the prefix to the server
        $mail->Host       = "smtp.gmail.com";      // sets GMAIL as the SMTP server
        $mail->Port       = 587;                   // set the SMTP port for the GMAIL server
        $mail->Username   = "vectorialsecret.socializ3d@gmail.com";  // GMAIL username
        $mail->Password   = "sM553sn4";            // GMAIL password

        $mail->AddReplyTo("vectorialsecret.socializ3d@gmail.com","Socializ3d Team");

        $mail->SetFrom("vectorialsecret.socializ3d@gmail.com","Socializ3d Team");

        $mail->AddAddress($memEmail, $member['username']);

        $mail->Subject    = 'Socializ3d account recovery';

        $mail->AltBody    = "To view the message, please use an HTML compatible email viewer!"; // optional, comment out and test

        $mail->MsgHTML($message);

        if(!$mail->Send()) {
            http_response_code(500);
            exit;
        }
    }
}
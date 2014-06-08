<?php

class UploadHandler
{
    function page($is_xhr)
    {
        global $smarty;
        global $BASE_DIR;

        $memberId = getLoggedId();

        if ($memberId == null) {
            http_response_code(403);
            return;
        }

        $userInfo = getUserSidebarInfo($memberId);

        if (! $is_xhr)
            include($BASE_DIR . 'pages/common/header.php');

        $smarty->assign('userInfo', $userInfo);
        $smarty->display('upload.tpl');

        if (! $is_xhr)
            include($BASE_DIR . 'pages/common/footer.php');
    }

    function get()
    {
        $this->page(false);
    }

    function get_xhr()
    {
        $this->page(true);
    }

    function post()
    {
        global $smarty;
        global $BASE_DIR;
        global $BASE_URL;
        global $MODELS_FOLDER;

        $memberId = getLoggedId();

        if ($memberId == null) {
            http_response_code(403);
            return;
        }

        if (!isset($_POST['name']) || !isset($_POST['description']) || !isset($_POST['to']) || !isset($_POST['tags'])) {
            http_response_code(400);
            return;
        }

        $name = stripslashes(strip_tags($_POST['name']));
        $description = stripslashes(strip_tags($_POST['description']));
        $visibility = strtolower($_POST['to']);
        $tags = trim($_POST['tags']);


        if (isset($_POST['groups']))
            $groups = $_POST['groups'];
        else
            $groups = array();

        $tagsArray = empty($tags) ? Array() : explode(',', $tags);
        error_log(json_encode($tagsArray));

        $archive_dir = $BASE_DIR . $MODELS_FOLDER ."/";

        $date = new DateTime();
        $time_stamp = $date->format('U');

        if (!isset($_FILES["file"]["error"]) || is_array($_FILES["file"]["error"])) {
            http_response_code(400);
            return;
        }

        switch ($_FILES["file"]["error"]) {
            case UPLOAD_ERR_OK:
                break;
            case UPLOAD_ERR_NO_FILE:
                http_response_code(400);
                return;
            case UPLOAD_ERR_INI_SIZE:
            case UPLOAD_ERR_FORM_SIZE:
                http_response_code(400);
                return;
            default:
                http_response_code(400);
                return;
        }

        if ($_FILES["file"]["size"] > (100 * 1024 * 1024)) { // MAX File Size 100 MB
            http_response_code(400);
            return;
        }

        $content_type = mime_content_type($_FILES["file"]['tmp_name']);
        error_log($content_type);
        if (false === $ext = array_search(
                $content_type,
                array(
                    'obj' => 'text/plain',
                    'stl' => 'text/plain',
                ),
                true
            )) {
            http_response_code(400);
            return;
        }

        global $conn;
        $conn->beginTransaction();

        $fileName = $archive_dir . hash('sha256', $memberId . $name . $_FILES['file']['name'] . $time_stamp);

        if (!file_exists($archive_dir)) {
            mkdir($archive_dir);
        }

        $stmt = $conn->prepare('INSERT INTO Model(idAuthor, name, description, userFileName, fileName, visibility) VALUES (:idAuthor, :name, :description, :userFileName, :fileName, :visibility)');
        $result = $stmt->execute(array(
            ':idAuthor' => $memberId,
            ':name' => $name,
            ':description' => $description,
            ':userFileName' => $_FILES['file']['name'],
            ':fileName' => $fileName,
            ':visibility' => $visibility
        ));

        $modelId = $conn->lastInsertId('model_id_seq');

        if (!move_uploaded_file($_FILES["file"]["tmp_name"], $fileName)) {
            $conn->rollBack();
            http_response_code(500);
            return;
        }

        if (count($tagsArray) > 0) {
            $stmt = $conn->prepare('INSERT INTO model_tags VALUES (?, ?)');
            foreach ($tagsArray as $newTag) {
                $stmt->execute(array($modelId, $newTag));
            }
        }

        if (count($groups) > 0) {
            $ifStmt = $conn->prepare('SELECT 1 FROM final.GroupUser WHERE idMember = ? AND idGroup = ?');
            $stmt = $conn->prepare('INSERT INTO GroupModel (idGroup, idModel) VALUES (?, ?)');
            foreach ($groups as $groupId) {
                $ifStmt->execute(array($memberId, $groupId));
                if (count($ifStmt->fetchAll()) < 1) {
                    $conn->rollBack();
                    http_response_code(403);
                    return;
                }

                $stmt->execute(array($groupId, $modelId));
            }
        }

        $conn->commit();

        header("Location: {$BASE_URL}models/$modelId");
    }
}

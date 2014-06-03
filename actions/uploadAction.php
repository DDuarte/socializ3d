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
            header('HTTP/1.1 403 Forbidden');
            exit;
        }

        if (!isset($_POST['name']) || !isset($_POST['description']) || !isset($_POST['to']) || !isset($_POST['tags'])) {
            header('HTTP/1.1 400 Bad Request');
            exit;
        }

        $name = strip_tags($_POST['name']);
        $description = strip_tags($_POST['description']);
        $visibility = strtolower($_POST['to']);
        $tags = $_POST['tags'];

        if (isset($_POST['groups']))
            $groups = $_POST['groups'];
        else
            $groups = array();

        $tagsArray = explode(',', $tags);

        $archive_dir = $BASE_DIR . $MODELS_FOLDER ."/";

        $date = new DateTime();
        $time_stamp = $date->format('U');

        // TODO validate model file

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
            header('HTTP/1.1 500 Internal Server Error');
            exit;
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
                $stmt->execute(array($memberId, $groupId));
                if (count($stmt->fetchAll()) < 1) {
                    $conn->rollBack();
                    header('HTTP/1.1 403 Forbidden');
                    exit;
                }

                $stmt->execute(array($groupId, $modelId));
            }
        }

        $conn->commit();

        header("Location: {$BASE_URL}models/$modelId");
    }
}

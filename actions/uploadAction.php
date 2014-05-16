<?php

class UploadHandler
{
    function get()
    {
        global $smarty;
        global $BASE_DIR;
        include($BASE_DIR . 'pages/common/header.php');
        include($BASE_DIR . 'pages/upload.php');
        include($BASE_DIR . 'pages/common/footer.php');
    }

    function get_xhr()
    {
        global $smarty;
        global $BASE_DIR;
        include($BASE_DIR . 'pages/upload.php');
    }

    function post()
    {
        global $smarty;
        global $BASE_DIR;
        global $BASE_URL;

        $memberId = getLoggedId();

        if ($memberId == null) {
            return; // TODO message & status code
        }

        if (!isset($_POST['name']) || !isset($_POST['description']) || !isset($_POST['to']) || !isset($_POST['tags'])) {
            return; // TODO message & status code
        }

        $name = $_POST['name'];
        $description = $_POST['description'];
        $to = $_POST['to'];
        $tags = $_POST['tags'];
        $tagsArray = explode(',', $tags);

        // TODO validate data

        global $conn;
        $stmt = $conn->prepare('INSERT INTO Model(idAuthor, name, description, userFileName, fileName, visibility) VALUES (:idAuthor, :name, :description, :userFileName, :fileName, :visibility)');
        $result = $stmt->execute(array(
            ':idAuthor' => $memberId,
            ':name' => $name,
            ':description' => $description,
            ':userFileName' => 'PLACEHOLDER_UFN', // FIXME pls
            ':fileName' => 'PLACEHOLDER_FN', // FIXME pls
            ':visibility' => 'public' // FIXME & TODO insert into groupuser if a group is selected
        ));

        $modelId = $conn->lastInsertId('model_id_seq');

        // TODO insert tags
        /* if (count($tagsArray) > 0) {
            $stmt = $conn->prepare('INSERT INTO model_tags VALUES (?, ?)');
            foreach ($tagsArray as $newTag) {
                $stmt->execute(array($modelId, $newTag));
            }
        } */

        header("Location: {$BASE_URL}models/$modelId");
    }
}

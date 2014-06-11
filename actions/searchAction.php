<?php

class SearchHandler
{
    function getResults($userId, $query, $limit) {
        global $conn;

        $stmt = $conn->prepare(
"SELECT
  *
FROM
  (SELECT
     id,
     'group'::TEXT                                                                          AS type,
     ts_rank_cd(to_tsvector('english', name), plainto_tsquery(lower(:searchTerm))) * 0.7 +
     ts_rank_cd(to_tsvector('english', about), plainto_tsquery(lower(:searchTerm))) * 0.3 AS score,
     TGroup.name,
     TGroup.avatarimg,
     TGroup.about
   FROM TGroup
   WHERE visibility = 'public' OR EXISTS(SELECT 1 FROM registeredUser WHERE registeredUser.id = :userId AND registeredUser.isAdmin = TRUE) OR (TGRoup.id IN (SELECT get_groups_of_member.groupid FROM get_groups_of_member(:userId)))
   ) AS gro
  NATURAL FULL JOIN
  (SELECT
     id,
     'member' ::TEXT                                                                            AS type,
     ts_rank_cd(to_tsvector('english', name), plainto_tsquery(lower(:searchTerm))) * 0.35 +
     ts_rank_cd(to_tsvector('english', username), plainto_tsquery(lower(:searchTerm))) * 0.35 +
     (SELECT SUM(ts_rank_cd(to_tsvector('english', user_tags.name), plainto_tsquery(lower(:searchTerm))) / coalesce(numTags, 0))  FROM user_tags WHERE idMember = Member.id) * 0.1 +
     ts_rank_cd(to_tsvector('english', about), plainto_tsquery(lower(:searchTerm))) * 0.2 AS score,
     member.name,
     member.about,
     get_user_hash(member.id) AS hash,
     (member.id IN (SELECT * FROM get_friends_of_member(:userId))) AS isFriend,
     (EXISTS (SELECT 1 FROM FriendshipInvite WHERE idSender = :userId AND idReceiver = member.id AND accepted IS NULL)) AS sentRequest
   FROM Member JOIN registeredUser USING (id) LEFT JOIN (SELECT idMember as id, COUNT(*) as numTags FROM user_tags GROUP BY id) AS Num_tags USING(id) WHERE Member.deleteDate IS NULL) AS mem
  NATURAL FULL JOIN
  (SELECT
     Model.id,
     'model'  ::TEXT                                                                                  AS type,
     ts_rank_cd(to_tsvector('english', name), plainto_tsquery(lower(:searchTerm))) * 0.5 +
     (SELECT SUM(ts_rank_cd(to_tsvector('english', model_tags.name), plainto_tsquery(lower(:searchTerm))) / coalesce(numTags, 0))  FROM model_tags WHERE idModel = Model.id) * 0.2 +
     ts_rank_cd(to_tsvector('english', description), plainto_tsquery(lower(:searchTerm))) * 0.3 AS score,
     model.name, model.description, model.createdate
   FROM get_all_visibile_models(:userId) JOIN Model USING(id) LEFT JOIN (SELECT idModel as id, COUNT(*) as numTags FROM model_tags GROUP BY id) AS Num_tags USING(id)
  ) AS mo

WHERE score <> 0
ORDER BY score DESC
LIMIT :limit;", array(PDO::ATTR_EMULATE_PREPARES => true));

        $stmt->execute(Array(":searchTerm" => $query, ":userId" => $userId, ":limit" => $limit));
        $results = $stmt->fetchAll();

        /*foreach ($results as $key => $result) {
            if ($result['type'] === 'model') {
                $results[$key]['value'] = getModel($result['id']);
            } else if ($result['type'] === 'group') {
                $results[$key]['value'] = getSimpleGroup($result['id']);
            } else if ($result['type'] === 'member') {
                $results[$key]['value'] = getSimpleMember($result['id'], $userId);
            }
        }*/

        return $results;
    }


    function get()
    {
        global /** @noinspection PhpUnusedLocalVariableInspection */
        $smarty;
        global $BASE_DIR;

        if (!isset($_GET['q']) || empty($_GET['q'])) {
            http_response_code(400);
            return;
        }

        $query = $_GET['q'];

        $memberId = getLoggedId();

        $limit = 20;

        $results = $this->getResults($memberId, $query, $limit);

        include($BASE_DIR . 'pages/common/header.php');
        $smarty->assign("results", $results);
        $smarty->display('search/search.tpl');
        include($BASE_DIR . 'pages/common/footer.php');

    }

    function get_xhr()
    {
        global /** @noinspection PhpUnusedLocalVariableInspection */
        $smarty;

        if (!isset($_GET['q']) || empty($_GET['q'])) {
            http_response_code(400);
            return;
        }

        $query = $_GET['q'];
        $memberId = getLoggedId();
        $limit = 20;

        $results = $this->getResults($memberId, $query, $limit);

        $smarty->assign("results", $results);
        $smarty->display('search/search.tpl');
    }
}

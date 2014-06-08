<?php

class StatisticsHandler
{
    function processDates($start, $end)
    {
        global $conn;
        $stmt = $conn->prepare("SELECT * FROM get_counts_per_month_year(:startDate, :endDate)");
        $stmt->execute(array(':startDate' => $start, ':endDate' => $end));
        $result = $stmt->fetchAll();

        return json_encode($result);
    }

    function get_stats_page() {
        global /** @noinspection PhpUnusedLocalVariableInspection */
        $smarty;
        global $conn;
        $stmt = $conn->prepare("SELECT * FROM get_counts_per_month_year(:startDate, :endDate)");
        $stmt->execute(array(':startDate' => '2014/01/01', ':endDate' => '2015/01/01'));
        $result = $stmt->fetchAll();

        if ($result == false) return false;

        $smarty->assign('stats', $result);
        $smarty->display('admin/stats.tpl');
    }

    function get()
    {
        if (isset($_GET['startDate']) && isset($_GET['endDate'])) {
            echo $this->processDates($_GET['startDate'], $_GET['endDate']);
            return;
        }

        $memberId = getLoggedId();

        if ($memberId == null) {
            http_response_code(403);
            return;
        }

        if (!isAdmin($memberId)) {
            http_response_code(403);
            return;
        }

        global $smarty;
        global $BASE_DIR;
        include($BASE_DIR . 'pages/common/header.php');
        $this->get_stats_page();
        include($BASE_DIR . 'pages/common/footer.php');
    }

    function get_xhr()
    {
        if (isset($_GET['startDate']) && isset($_GET['endDate'])) {
            echo $this->processDates($_GET['startDate'], $_GET['endDate']);
            return;
        }

        $this->get_stats_page();
    }
}

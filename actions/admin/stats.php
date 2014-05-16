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

    function get()
    {
        if (isset($_GET['startDate']) && isset($_GET['endDate'])) {
            echo $this->processDates($_GET['startDate'], $_GET['endDate']);
            return;
        }

        global /** @noinspection PhpUnusedLocalVariableInspection */
        $smarty;
        global $BASE_DIR;
        include($BASE_DIR . 'pages/common/header.php');
        include($BASE_DIR . 'pages/stats.php');
        include($BASE_DIR . 'pages/common/footer.php');
    }

    function get_xhr()
    {
        if (isset($_GET['startDate']) && isset($_GET['endDate'])) {
            echo $this->processDates($_GET['startDate'], $_GET['endDate']);
            return;
        }

        global /** @noinspection PhpUnusedLocalVariableInspection */
        $smarty;
        global $BASE_DIR;
        include($BASE_DIR . 'pages/stats.php');
    }
}

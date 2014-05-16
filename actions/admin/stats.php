<?php

class StatisticsHandler
{
    function get()
    {
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
            $start = $_GET['startDate'];
            $end = $_GET['endDate'];

            global $conn;
            $stmt = $conn->prepare("SELECT * FROM get_counts_per_month_year(:startDate, :endDate)");
            $stmt->execute(array(':startDate' => $start, ':endDate' => $end));
            $result = $stmt->fetchAll();

            echo json_encode($result);
            return;
        }

        global /** @noinspection PhpUnusedLocalVariableInspection */
        $smarty;
        global $BASE_DIR;
        include($BASE_DIR . 'pages/stats.php');
    }
}

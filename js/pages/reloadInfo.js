var inProgress = false;
function reloadNotificationsNow() {
    if (inProgress)
        return;
    inProgress = true;
    $.ajax({
        url: Socializ3d.BASE_URL + 'pages/users/navbar.php',
        type: 'GET',
        success: function (a) {

            var newH = $(a);
            $('#noti-count-st').html(newH.find('#noti-count-st').html());

            $('#noti-menu-st').html(newH.find('#noti-menu-st').html());

            inProgress = false;
        },
        error: function (a, b, c) {
            inProgress = false;
        }
    });
}

function reloadSchedule() {
    (function poll(){
        if (inProgress)
            return;
        inProgress = true;
        reloadSidebar();
        $.ajax({
            url: Socializ3d.BASE_URL + 'pages/users/navbar.php',
            type: 'GET',
            success: function (a) {

                var newH = $(a);
                $('#noti-count-st').html(newH.find('#noti-count-st').html());

                $('#noti-menu-st').html(newH.find('#noti-menu-st').html());

                inProgress = false;
            },
            error: function (a, b, c) {
                inProgress = false;
            },
            complete: function() {
                // Schedule the next request when the current one's complete
                setTimeout(poll, 30000);
            },
            timeout: 30000
        });
    })();
}

var sideInProgress = false;
function reloadSidebar() {
    if (sideInProgress)
        return;
    sideInProgress = true;
    $.ajax({
        url: Socializ3d.BASE_URL + 'pages/users/sidebar.php',
        type: 'GET',
        success: function (a) {
            var newH = $(a);

            $('#groups-listing').html(newH.find('#groups-listing').html());

            $('#friends-listing').html(newH.find('#friends-listing').html());

            sideInProgress = false;
        },
        error: function (a, b, c) {
            sideInProgress = false;
        },
        timeout: 30000
    });
}
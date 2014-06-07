var inProgress = false;
function reloadNotifications() {
    if (inProgress)
        return;
    inProgress = true;
    $.ajax({
        url: '../../pages/users/navbar.php',
        type: 'GET',
        success: function (a) {
            $('#navbar-header').replaceWith(a);
            inProgress = false;
        },
        error: function (a, b, c) {
            inProgress = false;
        }
    });
}
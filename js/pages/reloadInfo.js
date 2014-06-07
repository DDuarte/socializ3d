var inProgress = false;
function reloadNotificationsNow() {
    if (inProgress)
        return;
    inProgress = true;
    $.ajax({
        url: '../../pages/users/navbar.php',
        type: 'GET',
        success: function (a) {
            var isOpen = false;
            var dropToggles = $('#drop-down-toggler');
            if (dropToggles)
                isOpen = dropToggles.hasClass('open');

            var newH = $(a);
            if (isOpen)
                newH.find('#drop-down-toggler').addClass('open');
            if (newH.html() !== $('#navbar-header').html())
                $('#navbar-header').replaceWith(newH);

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
        $.ajax({
            url: '../../pages/users/navbar.php',
            type: 'GET',
            success: function (a) {
                var isOpen = false;
                var dropToggles = $('#drop-down-toggler');
                if (dropToggles)
                    isOpen = dropToggles.hasClass('open');

                var newH = $(a);
                if (isOpen)
                    newH.find('#drop-down-toggler').addClass('open');
                if (newH.html() !== $('#navbar-header').html())
                    $('#navbar-header').replaceWith(newH);

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
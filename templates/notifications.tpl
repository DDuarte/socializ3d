<section class="content-header">
    <h1 id="myh122">
        Notifications
    </h1>
</section>

<section class="content">
    <div class="row">
        <div class="col-md-8 col-md-offset-2">
            <div class="box box-primary">
                <div class="box-body notifications-box">
                    <ul class="timeline">
                        {foreach $notifications as $date => $nots}
                            <li class="time-label">
                                <span class="bg-red">
                                    {$date}
                                </span>
                                {foreach $nots as $notification}
                                    <li id="elem_{$notification.idnotification}">
                                        <i class="{$notification.icon}"></i>
                                        <div class="timeline-item">
                                            <span class="time"><time class="timeago" datetime="{$notification.createdate}">{$notification.createdate}</time></span>
                                            {if $notification.text|count_characters:true}
                                                <h3 class="timeline-header" {if !$notification.seen}style="font-weight: bolder"{/if}>{$notification.title}</h3>
                                                <div class="timeline-body">
                                                    {$notification.text}
                                                </div>
                                            {else}
                                                <h3 class="timeline-header no-border" {if !$notification.seen}style="font-weight: bolder"{/if}>{$notification.title}</h3>
                                            {/if}
                                            {if $notification.subtext|count_characters:true}
                                                <div class="timeline-footer">
                                                    {$notification.subtext}
                                                </div>
                                            {/if}
                                        </div>
                                    </li>
                                {/foreach}
                            </li>
                        {/foreach}
                    </ul>
                </div>
            </div>
        </div>
    </div>
</section>


<script src="{$BASE_URL}js/plugins/bootstrap3-dialog/bootstrap-dialog.min.js" type="text/javascript"></script>
<script>
    var busy = false;

    function friendshipReply(btn, answer) {
        if (busy) {
            return;
        }
        busy = true;
        var thisButton = $(btn);
        var userId = thisButton.attr('name');
        var reqType = answer ? 'POST' : 'DELETE';
        thisButton.addClass('disabled');
        thisButton.prepend('<span class="bootstrap-dialog-button-icon glyphicon glyphicon-asterisk icon-spin"></span>');

        $.ajax({
            url: '{$BASE_URL}members/friend/' + userId,
            type: reqType,
            success: function (a) {
                BootstrapDialog.alert({
                    title: 'Success!',
                    message: 'Reply sent.'
                });
                var textReply = answer ? 'accepted' : 'declined';
                thisButton.parent().replaceWith('<div class="timeline-footer">You '+ textReply +' this request.</div>');
                busy = false;
            },
            error: function (a, b, c) {
                BootstrapDialog.alert({
                    title: 'Oops!',
                    message: 'Could not process your request at this time. :(\nError: ' + c});
                thisButton.find('span').remove();
                thisButton.removeClass('disabled');
                busy = false;
            }
        });
    }

    function groupApplicationReply(btn, answer) {
        if (busy) {
            return;
        }
        busy = true;
        var thisButton = $(btn);
        var groupId = thisButton.attr('name').split(' ')[0];
        var userId = thisButton.attr('name').split(' ')[1];
        var reqType = answer ? 'POST' : 'DELETE';
        thisButton.addClass('disabled');
        thisButton.prepend('<span class="bootstrap-dialog-button-icon glyphicon glyphicon-asterisk icon-spin"></span>');

        $.ajax({
            url: '{$BASE_URL}groups/' + groupId + '/application/' + userId,
            type: reqType,
            success: function (a) {
                BootstrapDialog.alert({
                    title: 'Success!',
                    message: 'Reply sent.'
                });
                var textReply = answer ? 'accepted' : 'declined';
                thisButton.parent().replaceWith('<div class="timeline-footer">This request was '+ textReply +'.</div>');
                busy = false;
            },
            error: function (a, b, c) {
                BootstrapDialog.alert({
                    title: 'Oops!',
                    message: 'Could not process your request at this time. :(\nError: ' + c});
                thisButton.find('span').remove();
                thisButton.removeClass('disabled');
                busy = false;
            }
        });
    }

    function groupInviteReply(btn, answer) {
        if (busy) {
            return;
        }
        busy = true;
        var thisButton = $(btn);
        var groupId = thisButton.attr('name');
        var reqType = answer ? 'POST' : 'DELETE';
        thisButton.addClass('disabled');
        thisButton.prepend('<span class="bootstrap-dialog-button-icon glyphicon glyphicon-asterisk icon-spin"></span>');

        $.ajax({
            url: '{$BASE_URL}groups/' + groupId + '/invite/{$member.id}',
            type: reqType,
            success: function (a) {
                BootstrapDialog.alert({
                    title: 'Success!',
                    message: 'Reply sent.'
                });
                var textReply = answer ? 'accepted' : 'rejected';
                thisButton.parent().replaceWith('<div class="timeline-footer">You ' + textReply + ' this request</div>');
                busy = false;
            },
            error: function (a, b, c) {
                BootstrapDialog.alert({
                    title: 'Oops!',
                    message: 'Could not process your request at this time. :(\nError: ' + c});
                thisButton.find('span').remove();
                thisButton.removeClass('disabled');
                busy = false;
            }
        });
    }
</script>
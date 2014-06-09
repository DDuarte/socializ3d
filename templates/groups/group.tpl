<section class="content">
    <div class="row" style="padding-top:10px">
        <div class="col-md-12">
            <div class="thumbnail">
                <img id="group-cover-img" src="{$group.coverimg}" alt="Group cover image">
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-md-4">
            <div class="nav-tabs-custom">
                <ul class="nav nav-tabs">
                    <li class="active" id="tab-about">
                        <a href="#tab_about" data-toggle="tab">About</a>
                    </li>
                    <li id="tab-activity">
                        <a href="#tab_activity" data-toggle="tab">Recent Activity</a>
                    </li>
                    {if !$group.isMember && $IS_LOGGED_IN}
                    <li class="pull-left">
                        <button id="apply-to-group-btn" class="btn bg-blue btn-primary">
                            <i class="fa fa-plus-square-o"></i>
                            <span>Apply to Group</span>
                        </button>
                    </li>
                    {elseif $IS_LOGGED_IN}
                    <li class="pull-left">
                        <button id="leave-group-btn" class="btn btn-danger pull-right" onclick="excludeMember(this, {$visitor.id});">
                            <span>Leave</span>
                        </button>
                    </li>
                    {/if}
                    {if $group.isGroupAdmin}
                    <li class="pull-right">
                        <a href="#tab_settings" data-toggle="tab">
                            <i class="fa fa-gear"></i>
                        </a>
                    </li>
                    {/if}
                </ul>
                <div class="tab-content">
                    <div class="tab-pane active" id="tab_about">
                        <div class="thumbnail">
                            <img id="group-avatar-img" src="{$group.avatarimg}" alt="Group avatar image">
                        </div>
                        <p id="group-about-content">{$group.about}</p>
                    </div>
                    <!-- /.tab-pane -->
                    <div class="tab-pane" id="tab_activity">
                        <ul class="media-list">
                            {foreach $group.activity as $activ}
                                <li class="media">
                                    <a class="pull-left" href="#">
                                        <img class="media-object" src="{$activ.img}" alt="Activity image">
                                    </a>
                                    <div class="media-body">
                                        <h4 class="media-heading" {if $group.isMember && $activ.createdate > $visitor.lastaccess}style="font-weight: bolder"{/if}>
                                            {$activ.text}
                                        </h4>
                                        <span class="time"><time class="timeago" datetime="{$activ.createdate}">{$activ.createdate}</time></span>
                                    </div>
                                </li>
                            {/foreach}
                        </ul>
                    </div>
                    {if $group.isGroupAdmin}
                    <div class="tab-pane" id="tab_settings">
                        <div class="form-group">
                            <label for="cover-img-url">Cover URL:</label>
                            <input type="text" class="form-control" id="cover-img-url" placeHolder="Cover img URL here" value="{$group.coverimg}"/>
                            <label for="avatar-img-url">Avatar URL:</label>
                            <input type="text" class="form-control" id="avatar-img-url" placeHolder="Avatar img URL here" value="{$group.avatarimg}" />
                            <label for="about-me-field">About:</label>
                            <textarea class="form-control" id="about-me-field" placeHolder="Enter your text here">{$group.about}</textarea>
                            <label for="visibility-field">Visibility:</label>
                            <select name="visibility" class="form-control" id="visibility-field">
                                <option {if $group.visibility == 'public'}selected{/if}>Public</option>
                                <option {if $group.visibility == 'private'}selected{/if}>Private</option>
                            </select>
                            <span class="help-block">Public: everyone can see your group; Private: invitation only</span>
                        </div>
                        <button id="confirm-changes-btn" class="btn btn-success" >
                            <span>Confirm Changes</span>
                        </button>
                        <!--
                        <button id="delete-group-btn" class="btn btn-danger" >
                            <span>Delete Group</span>
                        </button>
                        -->
                    </div>
                    {/if}
                    <!-- /.tab-settings -->
                    <!-- /.tab-pane -->
                </div>
                <!-- /.tab-content -->
            </div>
        </div>
        <div class="col-md-8">
            <div class="nav-tabs-custom">
                <ul class="nav nav-tabs pull-right">
                    <li class="active" id="tab-gallery">
                        <a href="#tab_gallery" data-toggle="tab">Gallery</a>
                    </li>
                    <li id="tab-members">
                        <a href="#tab_members" data-toggle="tab">Members</a>
                    </li>
                    {if $group.isGroupAdmin}
                    <li id="tab-notifications">
                        <a href="#tab_notifications" data-toggle="tab">Notifications</a>
                    </li>
                    {/if}
                    {if $visitor.groupShares|@count > 0}
                    <li id="tab-publications">
                        <a href="#tab_publications" data-toggle="tab">Publications</a>
                    </li>
                    {/if}
                    <li class="pull-left header">
                        <i class="fa fa-group"></i>{$group.name}</li>
                </ul>
                <div class="tab-content" id="right-tab-content">
                    <div class="tab-pane active" id="tab_gallery">
                        <div class="row">
                            {foreach $group.models as $model}
                                <div id="model_{$model.id}" class="col-md-4">
                                    {include file="models/thumbnail.tpl" model=$model }
                                </div>
                            {/foreach}
                        </div>
                    </div>
                    <!-- /.tab-pane -->
                    <div class="tab-pane" id="tab_members">
                        <div class="box box-solid">
                            <div class="box-header">
                                <h3 class="box-title">Members</h3>
                                <div class="box-tools">
                                    <div class="input-group">
                                        <input type="text" name="table_search" id="table_search" class="form-control input-sm pull-right" style="width: 150px;" placeholder="Filter members" />
                                        <div class="input-group-btn">
                                            <button class="btn btn-sm btn-default">
                                                <i class="fa fa-search"></i>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <!-- /.box-header -->
                            <div class="box-body table-responsive">
                                <table class="table table-hover" id="member_table">
                                    <tr>
                                        <th>User</th>
                                        <th>Last Activity</th>
                                        <th>Role</th>
                                        {if $group.isGroupAdmin}
                                            <th><span class="pull-right">Tools</span></th>
                                        {/if}
                                    </tr>
                                    {foreach $group.members as $member}
                                    <tr class="member_row">
                                        <td>
                                            <a class="dynamic_load" href="{$BASE_URL}{$MEMBERS}/{$member.memberid}">{$member.membername}</a>
                                        </td>
                                        <td>
                                            <time class="timeago" datetime="{{$member.lastaccess}}">{{$member.lastaccess}}</time>
                                        </td>
                                        <td class="mem-role-description">
                                            {if $member.isadmin}
                                            <span class="label label-success">Admin</span>
                                            {else}
                                            <span class="label label-primary">Member</span>
                                            {/if}
                                        </td>
                                        {if $group.isGroupAdmin}
                                        <td>
                                            {if $member.memberid != $visitor.id}
                                            <button class="btn btn-sm btn-flat btn-default pull-right" onclick="excludeMember(this, {$member.memberid});">
                                                <i class="fa fa-times"></i>
                                            </button>
                                            {/if}
                                            <button class="btn btn-sm btn-flat btn-default pull-right" onclick="roleSelect(this, {$member.memberid}, {if $member.isadmin}true{else}false{/if});">
                                                <i class="fa fa-sort-down"></i>
                                            </button>
                                        </td>
                                        {/if}
                                    </tr>
                                    {/foreach}
                                </table>
                            </div>
                            <!-- /.box-body -->
                        </div>
                        <!-- /.box -->
                    </div>
                    {if $group.isGroupAdmin}
                    <div class="tab-pane" id="tab_notifications">
                        <div class="box box-primary">
                            <div class="box-body notifications-box">
                                <ul class="todo-list notifications-list">
                                    {foreach $group.groupMemberApplications as $appli}
                                    <li class="notification-item notification-group-item">
                                        <span class="handle">
                                            <i class="fa fa-comments-o"></i>
                                        </span>
                                        <span class="text"> The user '<a href="{$BASE_URL}members/{$appli.id}" class="notification-group-name">{$appli.username}</a>' wants to join the group</span>
                                        <span class="pull-right">
                                            <button name="{$appli.id}" onclick="replyToApplication(this, true);" class="btn btn-primary btn-xs">Accept</button>
                                            <button name="{$appli.id}" onclick="replyToApplication(this, false);" class="btn btn-danger btn-xs">Decline</button>
                                        </span>
                                    </li>
                                    {/foreach}
                                </ul>
                            </div>
                        </div>
                    </div>
                    {/if}
                    {if $visitor.groupShares|@count > 0}
                    <div class="tab-pane" id="tab_publications">
                        <div class="box box-primary">
                            <div class="box-body notifications-box">
                                <ul class="todo-list notifications-list">
                                    {foreach $visitor.groupShares as $myShare}
                                    <li class="notification-item notification-group-item">
                                        <span class="handle">
                                            <i class="fa fa-comments-o"></i>
                                        </span>
                                                <span class="text"><a href="{$BASE_URL}members/{$myShare.idauthor}" class="notification-group-name">{$myShare.authorname}</a> shared <a href="{$BASE_URL}models/{$myShare.id}" class="notification-group-name">{$myShare.name}</a> with the group.</span>
                                        <span class="pull-right">
                                            <button name="{$myShare.id}" onclick="removePublication(this);" class="btn btn-danger btn-xs">Remove</button>
                                        </span>
                                    </li>
                                    {/foreach}
                                </ul>
                            </div>
                        </div>
                    </div>
                    {/if}
                    <!-- /.tab-pane -->
                </div>
                <!-- /.tab-content -->
            </div>
            <!-- nav-tabs-custom -->
        </div>
    </div>
</section>

<script src="{$BASE_URL}js/plugins/bootstrap3-dialog/bootstrap-dialog.min.js" type="text/javascript"></script>
<script>
    $('#table_search').keyup(function(){
        var valThis = $(this).val().toLowerCase();
        if (valThis == ""){
            $('#member_table > tbody > .member_row').show();
        } else {
            $('#member_table > tbody > .member_row').each(function(){
                var text = $(this).text().toLowerCase();
                (text.indexOf(valThis) >= 0) ? $(this).show() : $(this).hide();
            });
        }
    });

    function removePublication(btn) {
        var thisButton = $(btn);
        var pubid = thisButton.attr('name');
        thisButton.addClass('disabled');
        thisButton.prepend('<span class="bootstrap-dialog-button-icon glyphicon glyphicon-asterisk icon-spin"></span>');

        $.ajax({
            url: '{$BASE_URL}groups/{$group.id}/removepub/'+pubid,
            type: 'DELETE',
            success: function (a) {
                BootstrapDialog.alert({
                    title: 'Success!',
                    message: 'Publication removed.'
                });
                thisButton.parent().parent().remove();
                var modelElem = $('#model_' + pubid);
                if (modelElem)
                    modelElem.remove();
            },
            error: function (a, b, c) {
                BootstrapDialog.alert({
                    title: 'Oops!',
                    message: 'Could not process your request at this time. :(\nError: ' + (c === 'Conflict' ? 'Member is already in group or has application pending.' : c)});
                thisButton.find('span').remove();
                thisButton.removeClass('disabled');
            }
        });
    }

    function replyToApplication(btn, answer) {
        var thisButton = $(btn);
        var memid = thisButton.attr('name');
        var reqType = answer ? 'POST' : 'DELETE';
        thisButton.addClass('disabled');
        thisButton.prepend('<span class="bootstrap-dialog-button-icon glyphicon glyphicon-asterisk icon-spin"></span>');

        $.ajax({
            url: '{$BASE_URL}groups/{$group.id}/application/'+memid,
            type: reqType,
            success: function (a) {
                BootstrapDialog.alert({
                    title: 'Success!',
                    message: 'Reply sent.'
                });
                var textReply = answer ? 'accepted' : 'rejected';
                thisButton.parent().parent().remove();
            },
            error: function (a, b, c) {
                BootstrapDialog.alert({
                    title: 'Oops!',
                    message: 'Could not process your request at this time. :(\nError: ' + (c === 'Conflict' ? 'Member is already in group or has application pending.' : c)});
                thisButton.find('span').remove();
                thisButton.removeClass('disabled');
            }
        });
    }

    function excludeMember(btn, memId) {
        var thisButton = $(btn);
        BootstrapDialog.show({
            message: memId == {$visitor.id} ? 'Are you sure you want to leave this group?' : 'Are you sure you want to kick out this member?',
            buttons: [{
                label: memId == {$visitor.id} ? 'Leave' : 'Exclude member',
                cssClass: 'btn-danger',
                autospin: true,
                action: function(dialogRef){
                    var thisRef = dialogRef;
                    dialogRef.enableButtons(false);
                    dialogRef.setClosable(false);
                    $.ajax({
                        url: '{$BASE_URL}groups/{$group.id}/members/' + memId,
                        type: 'DELETE',
                        success: function (a) {
                            thisRef.close();
                            if (memId == {$visitor.id})
                                window.location.reload(true);
                            else
                                thisButton.parent().parent().remove();
                        },
                        error: function (a, b, c) {
                            BootstrapDialog.alert({
                                title: 'Oops!',
                                message: 'Could not process your request at this time. :(\nError: ' + (c === 'Unauthorized' ? 'Member is still an Admin, you need to demote him/her first.' : c)});
                            thisRef.enableButtons(true);
                            thisRef.setClosable(true);
                        }
                    });
                }
            }, {
                label: 'Cancel',
                action: function(dialogRef){
                    dialogRef.close();
                }
            }]
        });
    }

    function roleSelect(btn, memId, isAdmin) {
        var thisButton = $(btn);
        BootstrapDialog.show({
            message: isAdmin ? 'This member is currently an Admin' : 'This is a regular member',
            buttons: [{
                label: isAdmin ? 'Demote to member' : 'Promote to Admin',
                cssClass: isAdmin ? 'btn-danger' : 'btn-success',
                autospin: true,
                action: function(dialogRef){
                    var thisRef = dialogRef;
                    dialogRef.enableButtons(false);
                    dialogRef.setClosable(false);

                    $.ajax({
                        url: '{$BASE_URL}groups/{$group.id}/members/' + memId,
                        type: 'POST',
                        data: {literal}{adm: isAdmin ? 'false' : 'true'}{/literal},
                        success: function (a) {
                            var innerSpan = !isAdmin ? '<span class="label label-success">Admin</span>' : '<span class="label label-primary">Member</span>';
                            thisButton.parent().parent().find('.mem-role-description').replaceWith('<td class="mem-role-description">' + innerSpan + '</td>');
                            thisButton.attr('onclick','roleSelect(this, '+ memId + ', ' + (isAdmin ? 'false' : 'true') +');');
                            thisRef.close();
                        },
                        error: function (a, b, c) {
                            BootstrapDialog.alert({
                                title: 'Oops!',
                                message: 'Could not process your request at this time. :(\nError: ' + (c === 'Unauthorized' ? 'You are the last admin of the group, please make someone else an Admin first' : c)});
                            thisRef.enableButtons(true);
                            thisRef.setClosable(true);
                        }
                    }
                    );
                }
            }, {
                label: 'Close',
                action: function(dialogRef){
                    dialogRef.close();
                }
            }]
        });
    }

    $(function () {

        // Instance the tour
        function startIntro(){
            var intro = introJs();
            var options = { steps: [] };

            options.steps.push({ intro: "Welcome to the group page, here you can access the latest publications from your peers." });

            options.steps.push({
                element: document.querySelector('#tab-about'),
                intro: "Access the general group information."
            });
            options.steps.push({
                element: document.querySelector('#tab-activity'),
                intro: "See the latest activities from your group peers."
            });
            options.steps.push({
                element: document.querySelector('#tab-members'),
                intro: "Access the group's members information.",
                tooltipPosition: 'bottom-left-aligned'
            });

            if ($('#tab-publications').length > 0) {
                options.steps.push({
                    element: document.querySelector('#tab-publications'),
                    intro: "Access the latest model publications in the group.",
                    tooltipPosition: 'bottom-left-aligned'
                });
            }

            if ($('#tab-notifications').length > 0) {
                options.steps.push({
                    element: document.querySelector('#tab-notifications'),
                    intro: "Accept member applications.",
                    tooltipPosition: 'bottom-left-aligned'
                });
            }

            intro.setOptions(options);

            intro.start();
        };

        $('#helpBtn').off().show().click(function(event) {
            startIntro();
        });

        $('#apply-to-group-btn').click(function (event) {
            event.preventDefault();
            var thisButton = $(this);
            thisButton.addClass('disabled');
            thisButton.prepend('<span class="bootstrap-dialog-button-icon glyphicon glyphicon-asterisk icon-spin"></span>');
            $.ajax({
                url: '{$BASE_URL}groups/{$group.id}/application/{$visitor.id}',
                type: 'POST',
                success: function (a) {
                    BootstrapDialog.alert({
                        title: 'Success!',
                        message: 'Applied to join this group!'
                    });
                    thisButton.parent().remove();
                },
                error: function (a, b, c) {
                    BootstrapDialog.alert({
                        title: 'Oops!',
                        message: 'Could not process your request at this time. :(\nError: ' + (c === 'Conflict' ? 'Member is already in group or has application pending.' : c)});
                    thisButton.find('span.bootstrap-dialog-button-icon').remove();
                    thisButton.removeClass('disabled');
                }
            });
        });

        $('#confirm-changes-btn').click(function (event) {
            event.preventDefault();
            var thisButton = $(this);
            thisButton.addClass('disabled');
            thisButton.prepend('<span class="bootstrap-dialog-button-icon glyphicon glyphicon-asterisk icon-spin"></span>');
            $.ajax({
                url: '{$BASE_URL}groups/{$group.id}',
                type: 'POST',
                data: {literal}{ about: $('#about-me-field').val(), cover: $('#cover-img-url').val(), avatar: $('#avatar-img-url').val(), visibility: $('#visibility-field').val() }{/literal},
                success: function (a) {
                    BootstrapDialog.alert({
                        title: 'Success!',
                        message: 'Updated successfully!'
                    });
                    $('#group-about-content').text($('#about-me-field').val());
                    $('#group-cover-img').attr('src',$('#cover-img-url').val());
                    $('#group-avatar-img').attr('src',$('#avatar-img-url').val());
                    thisButton.find('span.bootstrap-dialog-button-icon').remove();
                    thisButton.removeClass('disabled');
                },
                error: function (a, b, c) {
                    BootstrapDialog.alert({
                        title: 'Oops!',
                        message: 'Could not process your request at this time. :(\nError: ' + (c === 'Conflict' ? 'Member is already in group or has application pending.' : c)});
                    thisButton.find('span.bootstrap-dialog-button-icon').remove();
                    thisButton.removeClass('disabled');
                }
            });
        });


    });
</script>

<!-- Content Header (Page header) -->
<!-- Main content -->
<section class="content">
    <div class="row" style="padding-top:10px">
        <div class="col-md-4">
            <div class="nav-tabs-custom">
                <ul class="nav nav-tabs">
                    <li class="active" id="tab-about">
                        <a href="#tab_about" data-toggle="tab">About me</a>
                    </li>
                    {if $IS_LOGGED_IN}
                        <li id="tab-info">
                            <a href="#tab_info" data-toggle="tab">Info</a>
                        </li>
                    {/if}
                    {if $LOGGED_ID == $member.id || $IS_ADMIN}
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
                            <img src="{$GRAVATAR_URL}{$member.hash}?s=250&amp;d=identicon" alt="...">
                        </div>
                        <p id="member-about-content">{$member.about}</p>
                    </div>
                    <!-- /.tab-pane -->
                    {if $IS_LOGGED_IN}
                        <div class="tab-pane" id="tab_info">
                            <h4>Full Name:</h4>

                            <p>{$member.name}</p>
                            <h4>Date of Birth:</h4>
                            {$member.birthdate}
                            <h4>Interests:</h4>

                            <p id="member-interests-content">
                                {$member.interests}
                            </p>
                        </div>
                    {/if}
                    <!-- /.tab-pane -->
                    {if $LOGGED_ID == $member.id || $IS_ADMIN}
                        <div class="tab-pane" id="tab_settings">
                            <div class="form-group">
                                <label for="about-me-field">About me:</label>
                                <textarea class="form-control" id="about-me-field" placeHolder="Enter your text here"
                                          name="about">{$member.about}</textarea>
                            </div>
                            <div class="form-group">
                                <label for="interests-field">Interests:</label>
                                <br/>
                                <input type="text" class="form-control" id="interests-field"
                                       value="{$member.interests}" data-role="tagsinput"
                                       name="interests" placeholder="Add interests"/>
                            </div>
                            <div class="callout callout-info hidden" id="tags-info">
                                <h4>To add an interest</h4>

                                <p>After writing each interest you want to add (or several comma-separated interests),
                                    press enter.
                                    <br/>Once finished you can click the confirm button.</p>
                            </div>
                            <div id="processing_submit_section" class="box box-solid box-success hidden">
                                <div class="box-header">
                                    <h3 class="box-title">Processing your request...</h3>
                                </div>
                                <div class="box-body">
                                    <div class="progress progress-striped active">
                                        <div class="progress-bar progress-bar-green" style="width: 100%;"></div>
                                    </div>
                                </div>
                            </div>
                            {if !$IS_ADMIN}
                                <p style="text-align: right;">
                                    <a id="open-password-menu" href="#">Change password.</a>
                                </p>
                            {/if}
                            <button type="submit" class="btn bg-olive btn-block" id="confirm-button">Confirm</button>
                        </div>
                    {/if}
                    <!-- /.tab-settings -->
                </div>
                <!-- /.tab-content -->
            </div>
            <!-- nav-tabs-custom -->
        </div>
        <div class="col-md-8">
            <div class="nav-tabs-custom">
                <ul class="nav nav-tabs pull-right">
                    <li class="active" id="tab-gallery">
                        <a href="#tab_gallery" data-toggle="tab">Gallery</a>
                    </li>
                    <li id="tab-friends">
                        <a href="#tab_friends" data-toggle="tab">Friends</a>
                    </li>
                    <li id="tab-groups">
                        <a href="#tab_groups" data-toggle="tab">Groups</a>
                    </li>
                    <li class="pull-left header">
                        {$member.username}'s Profile
                    </li>
                    {if $IS_LOGGED_IN}
                        {if $LOGGED_ID != $member.id}
                            <li class="pull-left">
                            {if $diffGroups|@count > 0}
                                <button id="add-to-group-btn" class="btn bg-blue btn-primary">
                                    <i class="fa fa-plus-square-o"></i>
                                    <span>Invite to group</span>
                                </button>
                            {/if}
                            {if $member.myFriend}
                                <button id="unfriend-btn" class="btn bg-blue btn-primary">
                                    <i class="fa fa-times"></i>
                                    <span>Unfriend</span>
                                </button>
                            {elseif !$member.sentRequest}
                                <button class="btn btn-primary" id="friend-add-button">
                                    <i class="fa fa-user"></i>
                                    <span>Add friend<span>
                                </button>
                            {/if}
                        {/if}
                        {if $IS_ADMIN}
                            <button id="delete-btn" class="btn bg-red btn-danger">
                                <i class="fa fa-trash-o"></i>
                                <span>Delete</span>
                            </button>
                        {/if}
                        </li>
                    {/if}
                </ul>
                <div class="tab-content">
                    <div class="tab-pane active" id="tab_gallery">
                        <div class="row">

                            {foreach $member.models as $model}
                                <div class="col-md-4">
                                    {include file="models/thumbnail.tpl" model=$model }
                                </div>
                            {/foreach}

                        </div>
                    </div>
                    <!-- /.tab-pane -->
                    <div class="tab-pane" id="tab_groups">
                        {foreach $member.groups as $group}
                            {include file="members/groupComp.tpl" group=$group }
                        {/foreach}
                    </div>
                    <div class="tab-pane" id="tab_friends">
                        {foreach $member.friends as $friend}
                            {include file="members/friendComp.tpl" member=$friend }
                        {/foreach}
                    </div>
                </div>
                <!-- /.tab-content -->
            </div>
            <!-- nav-tabs-custom -->
        </div>
    </div>
</section>
<!-- /.content -->

<script src="{$BASE_URL}js/bootstrap-tagsinput.min.js" type="text/javascript"></script>
<script src="{$BASE_URL}js/plugins/bootstrap3-dialog/bootstrap-dialog.min.js" type="text/javascript"></script>
<script type="text/javascript">
function inviteToGroup(btn) {
    var thisButton = $(btn);
    var groupId = thisButton.attr('name');
    thisButton.addClass('disabled');
    thisButton.prepend('<span class="bootstrap-dialog-button-icon glyphicon glyphicon-asterisk icon-spin"></span>');

    $.ajax({
        url: '{$BASE_URL}groups/' + groupId + '/invite/{$member.id}',
        type: 'POST',
        success: function (a) {
            BootstrapDialog.alert({
                title: 'Success!',
                message: 'Invited this member to join your group!'
            });
            thisButton.parent().remove();
        },
        error: function (a, b, c) {
            BootstrapDialog.alert({
                title: 'Oops!',
                message: 'Could not process your request at this time. :(\nError: ' + (c === 'Conflict' ? 'Member is already in group or has invitation pending.' : c)});
            thisButton.find('span').remove();
            thisButton.removeClass('disabled');
        }
    });
}
var groupSettings = '<div class="form-group">' +
        '{foreach $diffGroups as $group}<p style="min-height:45px; border-bottom:1px solid gray;" ><span>{$group.groupname}</span>' +
        '<button class="btn btn-primary" onclick="inviteToGroup(this);" style="float: right;" name="{$group.groupid}" >Invite</button></p>' +
        '{/foreach}</div>';

var accountSettings =
        '<div class="form-group" ><p><input type="password" class="form-control" id="old-pass" placeholder="Old password"/></p></div>' +
        '<div class="form-group" ><p><input type="password" id="new-pass" class="form-control" placeholder="New password"/></p>' +
        '<p><input type="password" class="form-control" id="confirm-new" placeholder="Confirm"/></p></div>';
$(function () {
    $('#delete-btn').click(function () {
        BootstrapDialog.confirm('Do you really want to delete this member?', function (result) {
            if (result) {
                $.ajax({
                    url: '{$BASE_URL}members/{$member.id}',
                    type: 'DELETE',
                    success: function (a) {
                        BootstrapDialog.alert({
                            title: 'Success',
                            message: 'Member deleted with success.'});
                        window.location = '{$BASE_URL}';
                    },
                    error: function (a, b, c) {
                        BootstrapDialog.alert({
                            title: 'Oops!',
                            message: 'Could not delete this member. :(\nError: ' + c});
                    }
                });
            }
        });
    })


        // Instance the tour
        function startIntro(){
            var intro = introJs();
            intro.setOptions({
                steps: [
                    {
                        intro: "Welcome the member page."
                    },
                    {
                        element: document.querySelector('#tab-about'),
                        intro: "See the 'about me' section and member avatar."
                    },
                    {
                        element: document.querySelector('#tab-info'),
                        intro: "See the member's basic information."
                    },
                    {
                        element: document.querySelector('#tab-groups'),
                        intro: "See the member's groups."
                    },
                    {
                        element: document.querySelector('#tab-friends'),
                        intro: "See the member's friends."
                    }
                ]
            });

            intro.start();
        };

        $('#helpBtn').off().show().click(function(event) {
            startIntro();
        });
    $('#add-to-group-btn').click(function (event) {
        event.preventDefault();
        BootstrapDialog.show({
            type: BootstrapDialog.TYPE_PRIMARY,
            size: BootstrapDialog.SIZE_NORMAL,
            title: 'Groups',
            message: groupSettings,
            buttons: [
                {
                    label: 'Done',
                    cssClass: 'btn-error',
                    action: function (dialogRef) {
                        dialogRef.close();
                    }
                }
            ]
        });
    });

    $('#open-password-menu').click(function (event) {
        event.preventDefault();
        BootstrapDialog.show({
            type: BootstrapDialog.TYPE_PRIMARY,
            size: BootstrapDialog.SIZE_NORMAL,
            title: 'Account Settings',
            message: accountSettings,
            buttons: [
                {
                    label: 'Confirm',
                    cssClass: 'btn-success',
                    action: function (dialogRef) {
                        if ($('#new-pass').val() != $('#confirm-new').val()) {
                            BootstrapDialog.alert({
                                type: BootstrapDialog.TYPE_DANGER,
                                title: 'Oops!',
                                message: 'Passwords don\'t match.'});
                            return;
                        }
                        else if ($('#new-pass').val() == $('#old-pass').val()) {
                            BootstrapDialog.alert({
                                type: BootstrapDialog.TYPE_DANGER,
                                title: 'Oops!',
                                message: 'Changing your password to the same thing is not productive.'});
                            return;
                        }
                        var $button = this; // 'this' here is a jQuery object that wrapping the <button> DOM element.
                        $button.disable();
                        $button.spin();
                        $.ajax({
                            url: '{$BASE_URL}actions/members/changepass.php',
                            type: 'POST',
                            data: {literal}{ old_pass: $('#old-pass').val(), new_pass: $('#new-pass').val()}{/literal},
                            success: function (a) {
                                BootstrapDialog.alert({
                                    type: BootstrapDialog.TYPE_SUCCESS,
                                    title: 'Success!',
                                    message: 'Password changed successfully.\nDon\'t Forget it!'});
                                $button.enable();
                                $button.stopSpin();
                                dialogRef.close();
                            },
                            error: function (a, b, c) {
                                BootstrapDialog.alert({
                                    type: BootstrapDialog.TYPE_DANGER,
                                    title: 'Oops!',
                                    message: 'Failed to update your password. :(\nError: ' + c});
                                $button.enable();
                                $button.stopSpin();
                            }
                        });
                    }
                },
                {
                    label: 'Cancel',
                    cssClass: 'btn-error',
                    action: function (dialogRef) {
                        dialogRef.close();
                    }
                }
            ]
        });
    });

    $("#interests-field + .bootstrap-tagsinput").mouseover(function (event) {
        event.preventDefault();
        $("#tags-info").removeClass("hidden");
    });

    $("#interests-field + .bootstrap-tagsinput").mouseout(function (event) {
        event.preventDefault();
        $("#tags-info").addClass("hidden");
    });


    $('#unfriend-btn').click(function (event) {
        event.preventDefault();
        $('#unfriend-btn').addClass('hidden');
        $.ajax({
            url: '{$BASE_URL}members/friend/{$member.id}',
            type: 'DELETE',
            success: function (a) {
                var diagInstance = new BootstrapDialog({
                    title: 'Success!',
                    message: 'Removed this user from your friend list.',
                    buttons: [
                        {
                            label: 'Close',
                            action: function (dialogItself) {
                                dialogItself.close();
                                window.location.reload(true);
                            }
                        }
                    ]
                });
                diagInstance.setClosable(false);
                diagInstance.open();
            },
            error: function (a, b, c) {
                BootstrapDialog.alert({
                    title: 'Oops!',
                    message: 'Could not process your request at this time. :(\nError: ' + c});
                $('#unfriend-btn').removeClass('hidden');
            }
        });
    });

    $('#friend-add-button').click(function (event) {
        event.preventDefault();
        $('#friend-add-button').addClass('hidden');
        $.ajax({
            url: '{$BASE_URL}members/friend/{$member.id}',
            type: 'POST',
            success: function (a) {
                var diagInstance = new BootstrapDialog({
                    title: 'Success!',
                    message: 'Sent this member a friend request!',
                    buttons: [
                        {
                            label: 'Close',
                            action: function (dialogItself) {
                                dialogItself.close();
                                window.location.reload(true);
                            }
                        }
                    ]
                });
                diagInstance.setClosable(false);
                diagInstance.open();
            },
            error: function (a, b, c) {
                BootstrapDialog.alert({
                    title: 'Oops!',
                    message: 'Could not process your request at this time. :(\nError: ' + c});
                $('#friend-add-button').removeClass('hidden');
            }
        });
    });

    $('#confirm-button').click(function (event) {
        event.preventDefault();
        $('#confirm-button').addClass('hidden');
        $('#processing_submit_section').removeClass('hidden');
        $.ajax({
            url: '{$BASE_URL}members/{$member.id}',
            type: 'POST',
            data: {literal}{ about: $('#about-me-field').val(), interests: $('#interests-field').val()}{/literal},
            success: function (a) {
                $('#member-about-content').text($('#about-me-field').val());
                $('#member-interests-content').text($('#interests-field').val().replace(/, */g, ', '));
                BootstrapDialog.alert({
                    title: 'Success!',
                    message: 'Updated your information successfully'});
                $('#processing_submit_section').addClass('hidden');
                $('#confirm-button').removeClass('hidden');
                document.location.href = '#tab_about';
            },
            error: function (a, b, c) {
                BootstrapDialog.alert({
                    title: 'Oops!',
                    message: 'Could not process your request at this time. :(\nError: ' + c});
                $('#processing_submit_section').addClass('hidden');
                $('#confirm-button').removeClass('hidden');
            }
        });
    });
});
</script>
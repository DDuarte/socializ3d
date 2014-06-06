<section class="content">
    <div class="row" style="padding-top:10px">
        <div class="col-md-12">
            <div class="thumbnail">
                <img src="{$group.coverimg}" alt="...">
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-md-4">
            <div class="nav-tabs-custom">
                <ul class="nav nav-tabs">
                    <li class="active">
                        <a href="#tab_about" data-toggle="tab">About</a>
                    </li>
                    <li>
                        <a href="#tab_activity" data-toggle="tab">Recent Activity</a>
                    </li>
                    {if !$group.isMember}
                    <li class="pull-left">
                        <button id="apply-to-group-btn" class="btn bg-blue btn-primary">
                            <i class="fa fa-plus-square-o"></i>
                            <span>Apply to group</span>
                        </button>
                    </li>
                    {elseif $group.isGroupAdmin}
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
                            <img src="{$group.avatarimg}" alt="...">
                        </div>
                        <p>{$group.about}</p>
                    </div>
                    <!-- /.tab-pane -->
                    <div class="tab-pane" id="tab_activity">
                        <ul class="media-list">
                            <li class="media">
                                <a class="pull-left" href="#">
                                    <img class="media-object" src="img/user.jpg" alt="...">
                                </a>
                                <div class="media-body">
                                    <h4 class="media-heading">
                                        <a href="#">Jane Doe</a>published a
                                        <a href="#">model</a>
                                    </h4>
                                    28th February
                                </div>
                            </li>
                            <li class="media">
                                <a class="pull-left" href="#">
                                    <img class="media-object" src="img/user2.jpg" alt="...">
                                </a>
                                <div class="media-body">
                                    <h4 class="media-heading">
                                        <a href="#">John Doe</a>published a
                                        <a href="#">model</a>
                                    </h4>
                                    23rd February
                                </div>
                            </li>
                        </ul>
                    </div>
                    {if $group.isGroupAdmin}
                    <div class="tab-pane" id="tab_settings">
                        <div class="form-group">
                            <label for="description-field">About:</label>
                            <textarea class="form-control" id="about-me-field" placeHolder="Enter your text here">{$group.about}</textarea>
                        </div>
                        <button id="delete-group-btn" class="btn bg-blue btn-primary" data-toggle="modal" data-target="#delete-group-modal">
                            <i class="fa fa-times"></i>
                            <span>Delete Group</span>
                        </button>
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
                    <li class="active">
                        <a href="#tab_gallery" data-toggle="tab">Gallery</a>
                    </li>
                    <li>
                        <a href="#tab_members" data-toggle="tab">Members</a>
                    </li>
                    {if $group.isGroupAdmin}
                        <li>
                            <a href="#tab_notifications" data-toggle="tab">Notifications</a>
                        </li>
                    {/if}
                    <li class="pull-left header">
                        <i class="fa fa-group"></i>{$group.name}</li>
                </ul>
                <div class="tab-content">
                    <div class="tab-pane active" id="tab_gallery">
                        <div class="row">
                            {foreach $group.models as $model}
                                <div class="col-md-4">
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
                                    </tr>
                                    {foreach $group.members as $member}
                                    <tr class="member_row">
                                        <td>
                                            <a class="dynamic_load" href="{$BASE_URL}{$MEMBERS}/{$member.memberid}">{$member.membername}</a>
                                        </td>
                                        <td>
                                            <time class="timeago" datetime="{{$member.lastaccess}}">{{$member.lastaccess}}</time>
                                        </td>
                                        <td>
                                            {if $member.isadmin}
                                            <span class="label label-success">Admin</span>
                                            {else}
                                            <span class="label label-primary">Member</span>
                                            {/if}
                                        </td>
                                        {if $group.isGroupAdmin}
                                        <td>
                                            <button class="btn btn-sm btn-flat btn-default pull-right" data-toggle="modal" data-target="#delete-modal">
                                                <i class="fa fa-times"></i>
                                            </button>
                                            <button class="btn btn-sm btn-flat btn-default pull-right" data-toggle="modal" data-target="#change-role-modal">
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
                                    <li class="notification-item notification-group-item">
                                        <span class="handle">
                                            <i class="fa fa-comments-o"></i>
                                        </span>
                                        <span class="text"> The user '<span class="notification-group-name">Jane Doe</span>' wants to join the group</span>
                                        <div class="tools">
                                            <i class="fa fa-check"></i>
                                            <i class="fa fa-trash-o"></i>
                                        </div>
                                    </li>
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

{if $group.isGroupAdmin}
<div id="delete-modal" class="modal fade bs-example-modal-sm" tabindex="-1" role="dialog" aria-labelledby="mySmallModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-sm">
        <div class="modal-content">
            <div class="content-header" style="text-align: center">
                <h2>Remove member</h2>
            </div>
            <div class="box box-primary">
                <div class="row">
                    <div class="col-md-12" style="text-align: center">
                        <h3>Are you sure?</h3>
                    </div>
                </div>
                <div class="box-body notifications-box row">

                    <div class="col-md-6" style="text-align: center">
                        <button class="btn bg-blue btn-primary">
                            <span>Yes</span>
                        </button>
                    </div>
                    <div class="col-md-6" style="text-align: center">
                        <button class="btn bg-blue btn-primary">
                            <span>No</span>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div id="delete-group-modal" class="modal fade bs-example-modal-sm" tabindex="-1" role="dialog" aria-labelledby="mySmallModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-sm">
        <div class="modal-content">
            <div class="content-header" style="text-align: center">
                <h2>Delete Group</h2>
            </div>
            <div class="box box-primary">
                <div class="row">
                    <div class="col-md-12" style="text-align: center">
                        <h3>Are you sure?</h3>
                    </div>
                </div>
                <div class="box-body notifications-box row">

                    <div class="col-md-6" style="text-align: center">
                        <button class="btn bg-blue btn-primary">
                            <span>Yes</span>
                        </button>
                    </div>
                    <div class="col-md-6" style="text-align: center">
                        <button class="btn bg-blue btn-primary">
                            <span>No</span>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div id="change-role-modal" class="modal fade bs-example-modal-sm" tabindex="-1" role="dialog" aria-labelledby="mySmallModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-sm">
        <div class="modal-content">
            <div class="content-header" style="text-align: center">
                <h2>Change role</h2>
            </div>
            <div class="box box-primary">
                <div class="box-body notifications-box">
                    <ul class="todo-list notifications-list">
                        <li class="notification-item notification-group-item">
                            <input type="radio" name="role">
                            <span class="text">
                                <span class="notification-group-name">Admin</span>
                            </span>
                        </li>
                        <li class="notifiation-item notification-friendship-item">
                            <input type="radio" name="role">
                            <span class="text">
                                <span class="notification-friendship-name">Member</span>
                            </span>
                        </li>
                    </ul>
                </div>
                <div class="box-footer">
                    <button class="btn btn-primary">Commit changes</button>
                </div>
            </div>
        </div>
    </div>
</div>
{/if}

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
        };
    });

    $(function () {
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

    });
</script>

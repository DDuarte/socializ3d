<link href="{$BASE_URL}css/search.css" rel="stylesheet" type="text/css"/>
<!-- Content Header (Page header) -->
<!-- Main content -->
<section class="content">
    <div class="row" style="padding-top:10px">
        <div class="col-md-4">
            <div class="nav-tabs-custom">
                <ul class="nav nav-tabs">
                    <li class="active">
                        <a href="#tab_about" data-toggle="tab">About me</a>
                    </li>
                    {if $IS_LOGGED_IN}
                        <li>
                            <a href="#tab_info" data-toggle="tab">Info</a>
                        </li>
                    {/if}
                    {if $LOGGED_ID == $member.id}
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
                            <img src="{$GRAVATAR_URL}{$member.hash}?s=250&d=identicon" alt="...">
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
                    {if $LOGGED_ID == $member.id}
                        <div class="tab-pane" id="tab_settings">
                            <div class="form-group">
                                <label for="description-field">About me:</label>
                                <textarea class="form-control" id="about-me-field" placeHolder="Enter your text here"
                                          name="about">{$member.about}</textarea>
                            </div>
                            <div class="form-group">
                                <label for="tags-field">Interests:</label>
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
                    <li class="active">
                        <a href="#tab_gallery" data-toggle="tab">Gallery</a>
                    </li>
                    <li>
                        <a href="#tab_friends" data-toggle="tab">Friends</a>
                    </li>
                    <li>
                        <a href="#tab_groups" data-toggle="tab">Groups</a>
                    </li>
                    <li class="pull-left header">
                        {$member.name}'s Profile
                    </li>
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
                            {include file="search/group.tpl" group=$group }
                        {/foreach}
                    </div>
                    <div class="tab-pane" id="tab_friends">
                        {foreach $member.friends as $friend}
                            {include file="search/member.tpl" member=$friend }
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

<div class="modal fade bs-example-modal-sm" tabindex="-1" role="dialog" aria-labelledby="mySmallModalLabel"
     aria-hidden="true">
    <div class="modal-dialog modal-sm">
        <div class="modal-content">
            <div class="content-header">
                <h2>Choose the group(s)</h2>
            </div>
            <div class="box box-primary">
                <div class="box-body notifications-box">
                    <ul class="todo-list notifications-list">
                        <li class="notification-item notification-group-item">
                            <input type="checkbox">
                            <span class="text">
                                <span class="notification-group-name">Top Model Crew</span>
                            </span>
                        </li>
                        <li class="notifiation-item notification-friendship-item">
                            <input type="checkbox">
                            <span class="text">
                                <span class="notification-friendship-name">Oporto Anime Fans</span>
                            </span>
                        </li>
                        <li class="notification-item notification-group-activity-item">
                            <input type="checkbox">
                            <span class="text">
                                <span class="notification-group-activity-name">Top Notch Design</span>
                            </span>
                        </li>
                    </ul>
                </div>
                <div class="box-footer">
                    <button class="btn btn-primary">Invite</button>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="{$BASE_URL}js/bootstrap-tagsinput.min.js" type="text/javascript"></script>
<script src="{$BASE_URL}js/plugins/bootstrap3-dialog/bootstrap-dialog.min.js" type="text/javascript"></script>
<script type="text/javascript">
    $(function () {
        $("#interests-field + .bootstrap-tagsinput").mouseover(function (event) {
            event.preventDefault();
            $("#tags-info").removeClass("hidden");
        });

        $("#interests-field + .bootstrap-tagsinput").mouseout(function (event) {
            event.preventDefault();
            $("#tags-info").addClass("hidden");
        });

        $("#confirm-button").click(function (event) {
            event.preventDefault();
            $("#confirm-button").addClass("hidden");
            $.ajax({
                url: '{$BASE_URL}/members/{$member.id}',
                type: 'POST',
                data: {literal}{ about: $("#about-me-field").val(), interests: $("#interests-field").val()}{/literal},
                success: function (a) {
                    $("#member-about-content").text($("#about-me-field").val());
                    $("#member-interests-content").text($("#interests-field").val().replace(/, */g, ', '));
                    BootstrapDialog.alert({
                        title: 'Success!',
                        message: 'Updated your information successfully'});
                    $("#confirm-button").removeClass("hidden");
                    document.location.href='#tab_about';

                },
                error: function (a, b, c) {
                    BootstrapDialog.alert({
                        title: 'Oops!',
                        message: 'Could not process your request at this time. :(\nError: ' + c});
                    $("#confirm-button").removeClass("hidden");
                }
            });
        });
    });
</script>
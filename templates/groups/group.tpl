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
                    <div class="tab-pane" id="tab_settings">
                        <div class="form-group">
                            <label for="description-field">About:</label>
                            <textarea class="form-control" id="about-me-field" placeHolder="Enter your text here">{$group.about}</textarea>
                        </div>
                    </div>
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
                                        <input type="text" name="table_search" class="form-control input-sm pull-right" style="width: 150px;" placeholder="Filter members" />
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
                                <table class="table table-hover">
                                    <tr>
                                        <th>User</th>
                                        <th>Last Activity</th>
                                        <th>Role</th>
                                    </tr>
                                    {foreach $group.members as $member}
                                    <tr>
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
                                    </tr>
                                    {/foreach}
                                </table>
                            </div>
                            <!-- /.box-body -->
                        </div>
                        <!-- /.box -->
                    </div>
                    <!-- /.tab-pane -->
                </div>
                <!-- /.tab-content -->
            </div>
            <!-- nav-tabs-custom -->
        </div>
    </div>
</section>
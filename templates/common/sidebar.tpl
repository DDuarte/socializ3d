<aside class="left-side sidebar-offcanvas">
    <section class="sidebar" style="border-bottom: none">
        {if $IS_LOGGED_IN}<a class="dynamic_load" href="{$BASE_URL}{$MEMBERS}/{$userInfo.userId}">{/if}
            <div class="user-panel">

                <div class="pull-left image">
                    <img src="{$GRAVATAR_URL}{if $IS_LOGGED_IN}{$userInfo.userHash}{/if}?s=45&d={if $IS_LOGGED_IN}identicon{else}mm{/if}" class="img-circle" alt="User Image"/>
                </div>
                <div class="pull-left info">
                    <p>Hello, {if $IS_LOGGED_IN}{$userInfo.username}{else}Visitor{/if}</p>
                </div>
            </div>
        {if $IS_LOGGED_IN}
        </a>
        <ul class="sidebar-menu options-panel">
            <li class="upload-model-panel">
                <a class="dynamic_load" href="#page_upload">
                    <i class="fa fa-cloud-upload"></i>
                    <span>Upload Model</span>
                </a>
            </li>
            <li class="catalog-panel">
                <a class="dynamic_load" href="{$BASE_URL}catalog">
                    <i class="fa fa-th"></i>
                    <span>Catalog</span>
                </a>
            </li>
            <li class="treeview groups-panel">
                <a href="#">
                    <i class="fa fa-comments-o"></i>
                    <span>Groups</span>
                    <i class="fa fa-angle-left pull-right"></i>
                </a>
                <ul class="treeview-menu">
                    {foreach $userInfo.groups as $group}
                        <li>
                            <a class="dynamic_load" href="{$BASE_URL}{$GROUPS}/{$group.groupid}" class="pull-left">
                                <i class="fa fa-angle-double-right"></i>{$group.groupname}</a>

                            <div class="btn-group pull-right" style="margin-right: 10px">
                                <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                                    <i class="fa fa-sort-down"></i>
                                </a>
                                <ul class="dropdown-menu">
                                    <li>
                                        <a href="#">Leave Group</a>
                                    </li>
                                </ul>
                            </div>
                        </li>
                    {/foreach}
                </ul>
            </li>
            <li class="treeview friends-panel">
                <a href="#" style="clear: left;">
                    <i class="fa fa-users"></i>
                    <span>Friends</span>
                    <i class="fa fa-angle-left pull-right"></i>
                </a>
                <ul class="treeview-menu">
                    {foreach $userInfo.friends as $friend}
                        <li>
                            <a class="dynamic_load" href="{$BASE_URL}{$MEMBERS}/{$friend.memberid}">
                                <i class="fa fa-angle-double-right"></i>{$friend.membername}</a>
                        </li>
                    {/foreach}
                </ul>
            </li>
            <li class="create-group-panel">
                <a class="dynamic_load" href="#page_createGroup">
                    <i class="fa  fa-plus-square-o"></i>
                    <span>Create Group</span>
                </a>
            </li>
            <li class="page-admin-panel">
                <a class="dynamic_load" href="#page_admin">
                    <i class="fa  fa-wrench"></i>
                    <span>Administration</span>
                </a>
            </li>
        </ul>
        {/if}
    </section>
</aside> <!-- /.sidebar -->
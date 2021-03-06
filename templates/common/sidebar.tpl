<aside id="usr-side-bar" class="left-side sidebar-offcanvas">
    <section class="sidebar" style="border-bottom: none;">
        {if $IS_LOGGED_IN}<a class="dynamic_load" href="{$BASE_URL}{$MEMBERS}/{$userInfo.userId}">{/if}
            <div class="user-panel">

                <div class="pull-left image">
                    <img src="{$GRAVATAR_URL}{if $IS_LOGGED_IN}{$userInfo.userHash}{/if}?s=45&amp;d={if $IS_LOGGED_IN}identicon{else}mm{/if}" class="img-circle" alt="User Image"/>
                </div>
                <div class="pull-left info">
                    <p>Hello, {if $IS_LOGGED_IN}{$userInfo.username}{else}Visitor{/if}</p>
                </div>
            </div>
        {if $IS_LOGGED_IN}
        </a>
        <ul class="sidebar-menu options-panel">
            <li class="upload-model-panel">
                <a class="dynamic_load" href="{$BASE_URL}upload">
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
                <ul id="groups-listing" class="treeview-menu">
                    {foreach $userInfo.groups as $group}
                        <li>
                            <a class="dynamic_load" href="{$BASE_URL}{$GROUPS}/{$group.groupid}">
                                <i class="fa fa-angle-double-right"></i>{$group.groupname}</a>
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
                <ul id="friends-listing" class="treeview-menu">
                    {foreach $userInfo.friends as $friend}
                        <li>
                            <a class="dynamic_load" href="{$BASE_URL}{$MEMBERS}/{$friend.memberid}">
                                <i class="fa fa-angle-double-right"></i>{$friend.membername}</a>
                        </li>
                    {/foreach}
                </ul>
            </li>
            <li class="create-group-panel">
                <a class="dynamic_load" href="{$BASE_URL}groups/create">
                    <i class="fa fa-plus-square-o"></i>
                    <span>Create Group</span>
                </a>
            </li>
            {if $userInfo.isAdmin}
            <li class="page-admin-panel">
                <a class="dynamic_load" href="{$BASE_URL}admin/stats">
                    <i class="glyphicon glyphicon-stats"></i>
                    <span>Statistics</span>
                </a>
            </li>
            {/if}
        </ul>
        {/if}
    </section>
</aside>
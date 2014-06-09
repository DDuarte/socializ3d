<header id="navbar-header" class="header">
        <a href="{$BASE_URL}" class="logo">
        Socializ3D
    </a>
    <nav class="navbar my_navbar" role="navigation">
        <a href="#" class="navbar-btn sidebar-toggle" data-toggle="offcanvas" role="button">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
        </a>
        <div class="navbar-left hidden-xs">
            <form action="{$BASE_URL}search" method="get" class="navbar-form" id="search-form" role="search">
                <div class="form-group">
                    <input type="text" name="q" class="form-control" id="search-input1" placeholder="Search">
                </div>
                <button type="submit" class="btn btn-default">Submit</button>
            </form>
        </div>
        {if $IS_LOGGED_IN}
        <div class="navbar-right">
            <ul class="nav navbar-nav">
                <li class="dropdown  notifications-menu visible-xs">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                        <i class="fa fa-search"></i>
                    </a>
                </li>
                <li id="notifications-icon" class="dropdown notifications-menu">
                    <a href="#" id="noti-count-st" class="dropdown-toggle" data-toggle="dropdown">
                        <i class="fa  fa-flag"></i>
                        {if $userUnreadNots|@count > 0}
                            <span class="label label-warning">{if $userUnreadNots|@count < 100}{$userUnreadNots|@count}{else}+99{/if}</span>
                        {/if}
                    </a>
                    <ul id="noti-menu-st" class="dropdown-menu notifications-dropdown">
                        <li class="header">You have {$userUnreadNots|@count} new notifications</li>
                        {if $userUnreadNots|@count > 0}
                        <li>
                            <ul class="menu">
                                {foreach $userUnreadNots as $noti}
                                    {if $smarty.foreach.noti.index == 4}
                                        {break}
                                    {/if}
                                    <li>
                                        <a class="dynamic_load" href="{$BASE_URL}{$NOTIFICATIONS}/#elem_{$noti.idnotification}">
                                            <i class="{$noti.icon}"></i>
                                            <span class="text">{$noti.title}</span>
                                        </a>
                                    </li>
                                {/foreach}
                            </ul>
                        </li>
                        {/if}
                        <li class="footer">
                            <a class="dynamic_load" href="{$BASE_URL}{$NOTIFICATIONS}">View all</a>
                        </li>
                    </ul>
                </li>
                <li class="dropdown user user-menu">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                        <i class="glyphicon glyphicon-user"></i>
                            <span id="username_drop">{$userInfo.username}
                                <i class="caret"></i>
                            </span>
                    </a>
                    <ul class="dropdown-menu">
                        <li class="user-header bg-light-blue">
                            <img src="{$GRAVATAR_URL}{$userInfo.userHash}?d=identicon" class="img-circle" alt="User Image" />
                            <p>
                                {$userInfo.username}
                                <small>Member since Nov. 2012</small>
                            </p>
                        </li>
                        <li class="user-body">
                            <div class="text-center">
                                <a class="dynamic_load" href="{$BASE_URL}{$MEMBERS}/{$userInfo.userId}#tab_friends">Friends</a> |
                                <a class="dynamic_load" href="{$BASE_URL}{$MEMBERS}/{$userInfo.userId}#tab_groups">Groups</a>
                            </div>
                        </li>
                        <li class="user-footer">
                            <div class="pull-left">
                                <a href="{$BASE_URL}{$MEMBERS}/{$userInfo.userId}" class="btn btn-default btn-flat dynamic_load">Profile</a>
                            </div>
                            <div class="pull-right">
                                <a href="{$BASE_URL}actions/members/logout.php" class="btn btn-default btn-flat">Sign out</a>
                            </div>
                        </li>
                    </ul>
                </li>
            </ul>
        </div>
        {else}
        <div class="navbar-right">
            <ul class="nav navbar-nav">
                <li>
                    <a class="bt btn-flat" href="{$BASE_URL}register.php" role="button">Register</a>
                </li>
                <li>
                    <a class="bt btn-warning btn-flat" href="{$BASE_URL}login.php" role="button">Log in</a>
                </li>
            </ul>
        </div>
        {/if}
    </nav>
</header>

<div id="helpBtn" hidden class="no-print vertical-text" style="position: fixed; top: 150px; right: 0px; border-top-left-radius: 5px; border-top-right-radius: 0px; border-bottom-right-radius: 0px; border-bottom-left-radius: 5px; padding: 10px 15px; font-size: 16px; z-index: 999999; cursor: pointer; color: rgb(221, 221, 221); background: rgba(0, 0, 0, 0.701961);">Help</div>
<div class="no-print" style="padding: 10px; position: fixed; top: 130px; right: -200px; border: 3px solid rgba(0, 0, 0, 0.701961); width: 200px; z-index: 999999; background: rgb(255, 255, 255);"><h4 style="margin: 0 0 5px 0; border-bottom: 1px dashed #ddd; padding-bottom: 3px;">Layout Options</h4><div class="form-group no-margin"><div class=".checkbox"><label><input type="checkbox" onchange="change_layout();"> Fixed layout</label></div></div><h4 style="margin: 0 0 5px 0; border-bottom: 1px dashed #ddd; padding-bottom: 3px;">Skins</h4><div class="form-group no-margin"><div class=".radio"><label><input name="skins" type="radio" onchange="change_skin(&quot;skin-black&quot;);"> Black</label></div></div><div class="form-group no-margin"><div class=".radio"><label><input name="skins" type="radio" onchange="change_skin(&quot;skin-blue&quot;);" checked="checked"> Blue</label></div></div></div>
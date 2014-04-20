<header class="header">
    <a href="#page_catalog" class="logo">
        <!-- Add the class icon to your logo image or logo icon to add the margining -->
        Socializ3D
    </a>
    <!-- Header Navbar: style can be found in header.less -->
    <nav class="navbar my_navbar" role="navigation">
        <!-- Sidebar toggle button-->
        <a href="#" class="navbar-btn sidebar-toggle" data-toggle="offcanvas" role="button">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
        </a>
        <!-- search form -->
        <div class="navbar-left hidden-xs">
            <form action="#" method="get" class="navbar-form" role="search" onsubmit="document.location.hash = '#page_search-s_' + $('#search-input1').val(); return false;">
                <div class="form-group">
                    <input type="text" name="q" class="form-control" id="search-input1" placeholder="Search">
                </div>
                <button type="submit" class="btn btn-default">Submit</button>
            </form>
        </div>
        <!-- /.search form -->
        <div class="navbar-right">
            <ul class="nav navbar-nav">
                <li class="dropdown  notifications-menu visible-xs">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                        <i class="fa fa-search"></i>
                    </a>
                    <ul class="dropdown-menu">
                        <li class="header">
                            <form action="#" method="get" class="navbar-form" role="search" onsubmit="document.location.hash = '#page_search-s_' + $('#search-input2').val(); return false;">
                                <div class="input-group">
                                    <input type="text" class="form-control" id="search-input2" placeholder="Search..." />
                                        <span class="input-group-btn">
                                            <button type="submit" name="search" id="search-btn" class="btn btn-flat">
                                                <i class="fa fa-search"></i>
                                            </button>
                                        </span>
                                </div>
                            </form>
                        </li>
                    </ul>
                </li>
                <!-- Notifications: style can be found in dropdown.less -->
                <li class="dropdown notifications-menu">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                        <i class="fa  fa-flag"></i>
                        <span class="label label-warning">10</span>
                    </a>
                    <ul class="dropdown-menu notifications-dropdown">
                        <li class="header">You have 10 notifications</li>
                        <li>
                            <!-- inner menu: contains the actual data -->
                            <ul class="menu">
                                <li>
                                    <a href="#">
                                        <i class="ion ion-ios7-people info"></i>
                                            <span class="text">The user '
                                                <span class="notification-friendship-name">John Doe</span>' accepted your...</span>
                                    </a>
                                </li>
                                <li>
                                    <a href="#">
                                        <i class="ion ion-ios7-people info"></i>Very long description here that may not..
                                    </a>
                                </li>
                                <li>
                                    <a href="#">
                                        <i class="ion ion-ios7-people info"></i>
                                            <span class="text">A new model was published in the '
                                                <span class="notification-group-activity-name">Top Model Crew</span>'...</span>
                                    </a>
                                </li>
                                <li>
                                    <a href="#">
                                        <i class="ion ion-ios7-people info"></i>
                                            <span class="text">A new model was published in the '
                                                <span class="notification-group-activity-name">Oporto Anime Fans</span>'...</span>
                                    </a>
                                </li>
                                <li>
                                    <a href="#">
                                        <i class="ion ion-ios7-people info"></i>
                                            <span class="text">A new model was published in the '
                                                <span class="notification-group-activity-name">Top Notch Design</span>'...</span>
                                    </a>
                                </li>
                            </ul>
                        </li>
                        <li class="footer">
                            <a href="#page_notifications">View all</a>
                        </li>
                    </ul>
                </li>
                <!-- User Account: style can be found in dropdown.less -->
                <li class="dropdown user user-menu">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                        <i class="glyphicon glyphicon-user"></i>
                            <span id="username_drop">{$userInfo.username}
                                <i class="caret"></i>
                            </span>
                    </a>
                    <ul class="dropdown-menu">
                        <!-- User image -->
                        <li class="user-header bg-light-blue">
                            <img src="{$GRAVATAR_URL}{$userInfo.userHash}" class="img-circle" alt="User Image" />
                            <p>
                                {$userInfo.username}
                                <small>Member since Nov. 2012</small>
                            </p>
                        </li>
                        <!-- Menu Body -->
                        <li class="user-body">
                            <div class="text-center">
                                <a href="#page_profile-tab_friends">Friends</a>|
                                <a href="#page_profile-tab_groups">Groups</a>
                            </div>
                        </li>
                        <!-- Menu Footer-->
                        <li class="user-footer">
                            <div class="pull-left">
                                <a href="{$BASE_URL}pages/users/user.php?id={$userInfo.userId}" class="btn btn-default btn-flat">Profile</a>
                            </div>
                            <div class="pull-right">
                                <a href="#" class="btn btn-default btn-flat">Sign out</a>
                            </div>
                        </li>
                    </ul>
                </li>
            </ul>
        </div>
    </nav>
</header> <!-- /.navbar -->
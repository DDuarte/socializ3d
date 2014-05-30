<!DOCTYPE html>
<html class="bg-black">
<head>
    <meta charset="UTF-8">
    <title>Socializ3d | Registration</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    <!-- bootstrap 3.0.2 -->
    <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
    <!-- font Awesome -->
    <link href="css/font-awesome.min.css" rel="stylesheet" type="text/css"/>
    <!-- Theme style -->
    <link href="css/AdminLTE.css" rel="stylesheet" type="text/css"/>
    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
    <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
    <script src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>
    <![endif]-->
</head>
<body class="bg-black">
{if !$IS_LOGGED_IN}
    <div class="form-box" id="login-box">
        <div class="header" style="background-color:SteelBlue">Register</div>
        <div id="error_messages">
            {foreach $ERROR_MESSAGES as $error}
                <div class="error">{$error}<a class="close" href="#">X</a></div>
            {/foreach}
        </div>
        <form action="{$BASE_URL}actions/members/register.php" method="post">
            <div class="body bg-gray">
                <div class="form-group">
                    <label for="name-field">Full name</label>
                    <input type="text" id="name-field" name="realName" class="form-control" placeholder="Full name"/>
                </div>
                <div class="form-group">
                    <label for="dateOfBirth-field">Date of Birth</label>
                    <input id="birthDataField" type="text" class="form-control" data-mask="" name="birthDate" placeholder="Date of Birth"/>
                </div>
                <div class="form-group">
                    <label for="userid-field">User ID</label>
                    <input type="text" id="userid-field" name="username" class="form-control" placeholder="User ID"/>
                </div>
                <div class="form-group">
                    <label for="email-field">E-Mail</label>
                    <input type="email" id="email-field" name="email" class="form-control" placeholder="E-Mail"/>
                </div>
                <div class="form-group">
                    <label for="password-field">Password</label>
                    <input type="password" id="password-field" name="password" class="form-control"
                           placeholder="Password"/>
                </div>
                <div class="form-group">
                    <label for="password2-field">Retype password</label>
                    <input type="password" id="password2-field" name="password2" class="form-control"
                           placeholder="Retype password"/>
                </div>
            </div>
            <div class="footer">
                <button type="submit" class="btn bg-olive btn-block">Confirm</button>
                <a href="login.php" class="text-center">I'm already registered</a>
            </div>
        </form>
    </div>
{else}
    <div class="form-box" id="login-box">
        <div class="header" style="background-color:SteelBlue">
            Already logged in!
        </div>
        <div class="footer">
            <p>How did you end up here?</p>
            <a href="{$BASE_URL}" class="text-center">Return to Socializ3D</a>
        </div>
    </div>
{/if}


<!-- jQuery 2.0.2 -->
<script src="//ajax.googleapis.com/ajax/libs/jquery/2.0.2/jquery.min.js"></script>
<!-- InputMask -->
<script src="{$BASE_URL}js/plugins/input-mask/jquery.inputmask.js" type="text/javascript"></script>
<script src="{$BASE_URL}js/plugins/input-mask/jquery.inputmask.date.extensions.js" type="text/javascript"></script>
<script src="{$BASE_URL}js/plugins/input-mask/jquery.inputmask.extensions.js" type="text/javascript"></script>
<!-- Bootstrap -->
<script src="{$BASE_URL}js/bootstrap.min.js" type="text/javascript"></script>
<script src="{$BASE_URL}js/pages/register.js" type="text/javascript"></script>
</body>
</html>

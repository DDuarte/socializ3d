<!DOCTYPE html>
<html class="bg-black">
<head>
    <meta charset="UTF-8">
    <title>Socializ3d | Log in</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    <link href="{$BASE_URL}css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
    <link href="{$BASE_URL}css/font-awesome.min.css" rel="stylesheet" type="text/css"/>
    <link href="{$BASE_URL}css/AdminLTE.css" rel="stylesheet" type="text/css"/>
    <link href="{$BASE_URL}css/bootstrapValidator.min.css" rel="stylesheet" type="text/css" />
    <link href="{$BASE_URL}css/pages/formValidator.css" rel="stylesheet" type="text/css" />
    <link href="{$BASE_URL}css/bootstrap3-dialog/bootstrap-dialog.min.css" rel="stylesheet" type="text/css" />
    <!--[if lt IE 9]>
    <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
    <script src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>
    <![endif]-->
</head>
<body class="bg-black">
{if !$IS_LOGGED_IN}
    <div class="form-box" id="login-box">
        <div class="header" style="background-color:SteelBlue">Login</div>
        <div id="error_messages">
            {foreach $ERROR_MESSAGES as $error}
                <div class="error">{$error}<a class="close" href="#">X</a></div>
            {/foreach}
        </div>
        <form class="loginForm" action="{$BASE_URL}actions/members/login.php" method="post">
            <div class="body bg-gray">
                <div class="form-group">
                    <label for="userid-field">Username</label>
                    <input type="text" id="userid-field" name="username" class="form-control" placeholder="Username" required/>
                </div>
                <div class="form-group">
                    <label for="password-field">Password</label>
                    <input type="password" id="password-field" name="password" class="form-control"
                           placeholder="Password" required/>
                </div>
                <div class="form-group">
                    <input type="checkbox" id="remember_me-field" name="remember_me"/>
                    <label for="remember_me-field">Remember me</label>
                </div>
            </div>
            <div class="footer">
                <button type="submit" class="btn bg-green btn-block">Confirm</button>

                <p><a href="#" onclick="recoverAccount();">I forgot my password</a></p>

                <a href="{$BASE_URL}register.php" class="text-center">Register a new account</a>
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

<script src="//ajax.googleapis.com/ajax/libs/jquery/2.0.2/jquery.min.js"></script>
<script src="{$BASE_URL}js/bootstrap.min.js" type="text/javascript"></script>
<script src="{$BASE_URL}js/vendor/bootstrapValidator.min.js" type="text/javascript"></script>
<script src="{$BASE_URL}js/pages/login.js" type="text/javascript"></script>
<script src="{$BASE_URL}js/plugins/bootstrap3-dialog/bootstrap-dialog.min.js" type="text/javascript"></script>
<script type="text/javascript">
    function recoverAccount() {
        BootstrapDialog.show({
            title: "Recover Account",
            message: '<div class="form-group"><label for="email-field" style="color: #444;">Email address</label>' +
                    '<input type="email" id="email-field" name="email" class="form-control" placeholder="Email address" required/>' +
                    '</div>',
            buttons: [{
                label: 'Request recovery',
                cssClass: 'btn-primary spinning-email-button',
                action: function(dialogRef){
                    dialogRef.enableButtons(false);
                    dialogRef.setClosable(false);
                    $('.spinning-email-button').prepend('<span class="bootstrap-dialog-button-icon glyphicon glyphicon-asterisk icon-spin"></span>');
                    $.ajax({
                        url: '{$BASE_URL}members/0/forgotpass?email=' + $('#email-field').val(),
                        type: 'PUT',
                        success: function (a) {
                            BootstrapDialog.alert({
                                title: 'Success!',
                                message: '<label style="color: #444;">Check your email for recovery instructions<label>'
                            });
                            dialogRef.close();
                        },
                        error: function (a, b, c) {
                            BootstrapDialog.alert({
                                title: 'Oops!',
                                message: '<label style="color: #444;">Could not process your request at this time. :(\nError: ' + (c !== 'Not Found' ? c : 'Email Not Registered') + '</label>'});
                            dialogRef.enableButtons(true);
                            dialogRef.setClosable(true);
                            $('.spinning-email-button').find('span').remove();
                        }
                    });
                }
            }, {
                label: 'Close',
                action: function(dialogRef){
                    dialogRef.close();
                }
            }]
        });
    }
</script>
</body>
</html>

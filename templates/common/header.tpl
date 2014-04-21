<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>Socializ3d</title>
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" name="viewport">
    <link href="{$BASE_URL}css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="{$BASE_URL}css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <link href="{$BASE_URL}css/ionicons.min.css" rel="stylesheet" type="text/css" />
    <link href="{$BASE_URL}css/AdminLTE.css" rel="stylesheet" type="text/css" />
    <link href="{$BASE_URL}css/bootstrap-tagsinput.css" rel="stylesheet" type="text/css" />

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
    <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
    <script src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>
    <![endif]-->

    <script src="{$BASE_URL}js/jquery-2.1.0.min.js"></script>
    <script src="{$BASE_URL}js/plugins/timeago/jquery.timeago.js" type="text/javascript"></script>
    <script src="{$BASE_URL}js/plugins/bootstrap.min.js" type="text/javascript"></script>
    <script type="text/javascript">
        if (typeof Socializ3d === 'undefined')
            Socializ3d = {};
        Socializ3d.BASE_URL = "{$BASE_URL}";
    </script>
    <script src="{$BASE_URL}js/plugins/AdminLTE/app.js" type="text/javascript"></script>
</head>

<body class="skin-blue fixed">

{$navbar}

<div class="wrapper row-offcanvas row-offcanvas-left">

{$sidebar}

<aside id="content-ajax" class="right-side">

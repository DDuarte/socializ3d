<?php

include_once('config/init.php');

include_once($BASE_DIR . 'lib/Toro.php');

include_once($BASE_DIR . 'actions/indexAction.php');
include_once($BASE_DIR . 'actions/models/model.php');
include_once($BASE_DIR . 'actions/members/member.php');

ToroHook::add("404", function() {
    header("HTTP/1.0 404 Not Found");
    http_response_code(404);
    echo "404 Not Found";
});

Toro::serve(array(
    "/" => "IndexHandler",
    "/model/:number" => "CompleteModelHandler",
    "/member/:number" => "CompleteMemberHandler"

));
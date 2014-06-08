<link href="{$BASE_URL}css/renderer/types.css" rel="stylesheet"/>
<link id="theme" href="{$BASE_URL}css/renderer/light.css" rel="stylesheet"/>

<section class="content">
    <div class="row" id="rendererContainer">
    </div>

    <div class="row">
        <div class="box col-sm-12 col-md-12">
            <div class="nav-tabs-custom">
                <ul class="nav nav-tabs pull-right">
                    {if $LOGGED_ID == $model.idauthor || $IS_ADMIN}
                        <li class="pull-right">
                            <a href="#tab_settings" data-toggle="tab"> <i class="fa fa-gear"></i> </a>
                        </li>
                    {/if}
                    <li class="active">
                        <a href="#tab_info" data-toggle="tab">Information</a>
                    </li>
                    <li>
                        <a href="#tab_comments" data-toggle="tab">Comments
                            <span class="badge">{$model.numComments}</span>
                        </a>
                    </li>
                    <li class="pull-left header">
                        <i class="fa fa-info-circle"></i>{$model.name}</li>
                    <!-- TODO: Model name -->
                </ul>
                <div class="tab-content">
                    <div class="tab-pane active" id="tab_info">
                        <div class="row">
                            <div class="col-md-8">
                                <div class="user-panel">
                                    <div class="pull-left image">
                                        <img src="{$GRAVATAR_URL}{$model.hash}?d=identicon" class="img-square"
                                             alt="User Image"/>
                                    </div>
                                    <div class="pull-left info">
                                        <p>Author:
                                            <a class="dynamic_load"
                                               href="{$BASE_URL}{$MEMBERS}/{$model.idauthor}">{$model.nameauthor}</a>
                                        </p>

                                        <p>
                                            <time class="timeago"
                                                  datetime="{$model.createdate}">{$model.createdate}</time>
                                        </p>
                                    </div>
                                </div>
                                <h4>Description:</h4>

                                <p>{$model.description}</p>
                                {if $IS_LOGGED_IN}
                                    <p>
                                        <button id="download-btn" class="btn bg-blue btn-social"
                                                onclick="window.location.href='{$BASE_URL}{$MODELS}/{$model.id}/file'">
                                            <i class="fa fa-download"></i>
                                            <span>Download</span>
                                        </button>
                                        {if $LOGGED_ID == $model.idauthor || $IS_ADMIN}
                                            <button id="delete-btn" class="btn bg-red btn-social">
                                                <i class="fa fa-trash-o"></i>
                                                <span>Delete</span>
                                            </button>
                                        {/if}
                                    </p>
                                {/if}
                            </div>
                            <div class="col-md-4">
                                <!-- Primary tile -->
                                <div class="box box-solid bg-light-blue">
                                    <div class="box-header">
                                        <h3 class="box-title">Tags</h3>
                                    </div>
                                    <div class="box-body">
                                        {foreach $model.tagsArray as $tag}
                                            <span class="btn bg-white btn-flat margin text-black">{$tag.name}</span>
                                        {/foreach}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="tab-pane" id="tab_comments">
                        <div class="row">
                            <div class="col-md-4 col-md-push-8">
                                <div class="box ">
                                    <div class="box-header">
                                        <h3 class="box-title">Votes</h3>
                                    </div>
                                    <div class="box-body chart-responsive center-block">
                                        <div class="chart" id="votes-chart" style="height: 150px; position: relative;">

                                        </div>
                                        {if $IS_LOGGED_IN}
                                            <div id="processing_vote_section" class="box box-solid box-primary hidden">
                                                <div class="box-header">
                                                    <h3 class="box-title">Processing your vote...</h3>
                                                </div>
                                                <div class="box-body">
                                                    <div class="progress progress-striped active">
                                                        <div class="progress-bar" style="width: 100%;"></div>
                                                    </div>
                                                </div>
                                            </div>
                                            <div id="vote_section" class="text-center hidden">

                                                {if $model.userVote}
                                                <button style="opacity:0.5" id="up_vote_button"
                                                        class="btn bg-green btn-social disabled">
                                                    {else}
                                                    <button style="opacity:1.0" id="up_vote_button"
                                                            class="btn bg-green btn-social">
                                                        {/if}
                                                        <i class="fa fa-thumbs-up"></i>
                                                        <span>Up vote</span>
                                                    </button>
                                                    {if $model.userVote === null || $model.userVote}
                                                    <button style="opacity:1.0" id="down_vote_button"
                                                            class="btn bg-red btn-social">
                                                        {else}
                                                        <button style="opacity:0.5" id="down_vote_button"
                                                                class="btn bg-red btn-social disabled">
                                                            {/if}
                                                            <i class="fa fa-thumbs-down"></i>
                                                            <span>Down vote</span>
                                                        </button>
                                            </div>
                                        {/if}
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-8 col-md-pull-4">
                                <div class="box-footer">
                                    {if $IS_LOGGED_IN}
                                        <form action="{$BASE_URL}models/{$model.id}/comments" method="post"
                                              onsubmit="return checkComment();">
                                            <div class="input-group">
                                                <input id="comment-input" class="form-control" name="content"
                                                       placeholder="Comment this model..." autocomplete="off"/>

                                                <div class="input-group-btn">
                                                    <button class="btn btn-success" type="submit">
                                                        <i class="fa fa-plus"></i>
                                                    </button>
                                                </div>
                                            </div>
                                        </form>
                                    {/if}
                                </div>
                                <div class="box-body chat" id="chat-box">
                                    {foreach $model.comments as $comment}
                                        {include file="models/comment.tpl" comment=$comment}
                                    {/foreach}
                                </div>
                            </div>
                        </div>
                    </div>
                    {if $LOGGED_ID == $model.idauthor || $IS_ADMIN}
                        <div class="tab-pane" id="tab_settings">
                            <form id="edit-form" action="{$BASE_URL}models/{$model.id}" method="post">
                                <div class="form-group">
                                    <label for="about-me-field">Description:</label>
                                    <textarea class="form-control" id="about-me-field" name="about"
                                              placeHolder="Enter your text here">{$model.description}</textarea>
                                </div>
                                <div class="form-group">
                                    <label for="interests-field">Tags:</label>
                                    <br/>
                                    <input type="text" class="form-control" id="interests-field"
                                           value="{$model.tags}" name="tags"
                                           data-role="tagsinput" placeholder="Add tags"/>
                                </div>
                                <div class="callout callout-info hidden" id="tags-info">
                                    <h4>To add a tag</h4>

                                    <p>After writing each tag you want to add (or several comma-separated tags), press
                                        enter.
                                        <br/>Once finished you can click the submit button.</p>
                                </div>
                                <div class="input-group-btn">
                                    <button class="btn btn-success" type="submit">
                                        Submit
                                    </button>
                                </div>
                            </form>
                        </div>
                    {/if}
                </div>
            </div>
        </div>
    </div>

</section>


<script src="{$BASE_URL}js/plugins/morris/raphael-min.js"></script>
<script src="{$BASE_URL}js/plugins/morris/morris.min.js" type="text/javascript"></script>
<script src="{$BASE_URL}js/bootstrap-tagsinput.min.js" type="text/javascript"></script>
<script src="{$BASE_URL}js/plugins/bootstrap3-dialog/bootstrap-dialog.min.js" type="text/javascript"></script>

<script src="{$BASE_URL}js/renderer/libs/spin.js"></script>
<script src="{$BASE_URL}js/renderer/js/controls/EditorControls.js"></script>
<script src="{$BASE_URL}js/renderer/js/controls/TransformControls.js"></script>
<script src="{$BASE_URL}js/renderer/js/loaders/BabylonLoader.js"></script>
<script src="{$BASE_URL}js/renderer/js/loaders/ColladaLoader.js"></script>
<script src="{$BASE_URL}js/renderer/js/loaders/OBJLoader.js"></script>
<script src="{$BASE_URL}js/renderer/js/loaders/PLYLoader.js"></script>
<script src="{$BASE_URL}js/renderer/js/loaders/STLLoader.js"></script>
<script src="{$BASE_URL}js/renderer/js/loaders/UTF8Loader.js"></script>
<script src="{$BASE_URL}js/renderer/js/loaders/VRMLLoader.js"></script>
<script src="{$BASE_URL}js/renderer/js/loaders/VTKLoader.js"></script>
<script src="{$BASE_URL}js/renderer/js/loaders/ctm/lzma.js"></script>
<script src="{$BASE_URL}js/renderer/js/loaders/ctm/ctm.js"></script>
<script src="{$BASE_URL}js/renderer/js/loaders/ctm/CTMLoader.js"></script>
<script src="{$BASE_URL}js/renderer/js/renderers/RaytracingRenderer.js"></script>
<script src="{$BASE_URL}js/renderer/js/renderers/SoftwareRenderer.js"></script>
<script src="{$BASE_URL}js/renderer/js/renderers/SVGRenderer.js"></script>
<script src="{$BASE_URL}js/renderer/libs/THREEx.screenshot.js"></script>

<!-- WIP -->

<script src="{$BASE_URL}js/renderer/js/TypedGeometry.js"></script>
<script src="{$BASE_URL}js/renderer/js/BufferGeometryUtils.js"></script>
<script src="{$BASE_URL}js/renderer/js/renderers/WebGLRenderer3.js"></script>

<script src="{$BASE_URL}js/renderer/libs/signals.min.js"></script>
<script src="{$BASE_URL}js/renderer/libs/ui.js"></script>
<script src="{$BASE_URL}js/renderer/libs/ui.editor.js"></script>
<script src="{$BASE_URL}js/renderer/libs/ui.three.js"></script>

<script src="{$BASE_URL}js/renderer/Storage.js"></script>

<script src="{$BASE_URL}js/renderer/Editor.js"></script>
<script src="{$BASE_URL}js/renderer/Config.js"></script>
<script src="{$BASE_URL}js/renderer/Loader.js"></script>
<script src="{$BASE_URL}js/renderer/Toolbar.js"></script>
<script src="{$BASE_URL}js/renderer/Viewport.js"></script>

<script type="text/javascript">
function checkComment() {
    return $('#comment-input').val().length > 0;
}

$(function () {

    $('#delete-btn').click(function () {
        $.ajax({
            url: '{$BASE_URL}models/{$model.id}',
            type: 'DELETE',
            success: function (a) {
                BootstrapDialog.alert({
                    title: 'Success',
                    message: 'Model deleted with success.'});
                window.location = '{$BASE_URL}';
            },
            error: function (a, b, c) {
                BootstrapDialog.alert({
                    title: 'Oops!',
                    message: 'Could not delete this model. :(\nError: ' + c});
            }
        });
    })

    {literal}
    window.mobilecheck = function () {
        var check = false;
        (function (a) {
            if (/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.test(a) || /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0, 4)))check = true
        })(navigator.userAgent || navigator.vendor || window.opera);
        return check;
    };
    {/literal}

    var isMobile = window.mobilecheck();
    var data = [
        {
            label: "Up votes",
            value: {$model.numupvotes}
        },
        {
            label: "Down votes",
            value: {$model.numdownvotes}
        }
    ];

    var donut = new Morris.Donut({
        element: 'votes-chart',
        resize: true,
        colors: ["green", "red"],
        data: data,
        hideHover: 'auto'
    });

    var voteButtonElem = $('#up_vote_button');
    var voted_up = voteButtonElem.hasClass("disabled");
    var voted_down = voteButtonElem.hasClass("disabled");

    var interestsElem = $("#interests-field").find("+ .bootstrap-tagsinput");
    interestsElem.focusin(function (event) {
        event.preventDefault();
        $("#tags-info").removeClass("hidden");
    });

    interestsElem.focusout(function (event) {
        event.preventDefault();
        $("#tags-info").addClass("hidden");
    });

    var itemElem = $('.item');
    itemElem.mouseover(function (event) {
        event.preventDefault();
        $(this).find(".removeicon").removeClass("hidden");
    });

    itemElem.mouseout(function (event) {
        event.preventDefault();
        $(this).find(".removeicon").addClass("hidden");
    });

    $(".deletablecomment").parent().click(function (event) {
        event.preventDefault();
        var self = $(this);
        var url = self.attr("href");
        BootstrapDialog.confirm('Do you really want to delete this comment?', function (result) {
            if (result) {
                $.ajax({
                    url: url,
                    type: 'DELETE',
                    success: function (a) {
                        self.parents(".item").remove();
                    },
                    error: function (a, b, c) {
                        BootstrapDialog.alert({
                            title: 'Oops!',
                            message: 'Could not remove your comment at this time. :(\nError: ' + c});
                    }
                });
            }
        });
    });

    $("#up_vote_button").click(function () {
        if (!voted_up) {
            $("#vote_section").addClass("hidden");
            $("#processing_vote_section").removeClass("hidden");
            $.ajax({
                url: '{$BASE_URL}models/{$model.id}/votes',
                type: 'POST',
                data: {literal}{ vote: true}{/literal},
                success: function (a) {
                    if (voted_down)
                        reset_down();
                    vote_up();
                    $("#processing_vote_section").addClass("hidden");
                    $("#vote_section").removeClass("hidden");
                },
                error: function (a, b, c) {
                    BootstrapDialog.alert({
                        title: 'Oops!',
                        message: 'Could not register your vote at this time. :(\nError: ' + c});
                    $("#processing_vote_section").addClass("hidden");
                    $("#vote_section").removeClass("hidden");
                }
            });
        }
    });

    $("#down_vote_button").click(function () {
        if (!voted_down) {
            $("#vote_section").addClass("hidden");
            $("#processing_vote_section").removeClass("hidden");
            $.ajax({
                url: '{$BASE_URL}models/{$model.id}/votes',
                type: 'POST',
                data: {literal}{ vote: false}{/literal},
                success: function (a) {
                    if (voted_up)
                        reset_up();
                    vote_down();
                    $("#processing_vote_section").addClass("hidden");
                    $("#vote_section").removeClass("hidden");
                },
                error: function (a, b, c) {
                    BootstrapDialog.alert({
                        title: 'Oops!',
                        message: 'Could not register your vote at this time. :(\nError: ' + c});
                    $("#processing_vote_section").addClass("hidden");
                    $("#vote_section").removeClass("hidden");
                }
            });
        }
    });

    function vote_up() {
        up_vote();
        $("#up_vote_button").fadeTo("fast", 0.5).addClass("disabled");
        voted_up = true;
    }

    function vote_down() {
        down_vote();
        $("#down_vote_button").fadeTo("fast", 0.5).addClass("disabled");
        voted_down = true;
    }

    function reset_up() {
        voted_up = false;
        up_vote(-1);
        $("#up_vote_button").fadeTo("fast", 1).removeClass("disabled");
    }

    function reset_down() {
        voted_down = false;
        down_vote(-1);
        $("#down_vote_button").fadeTo("fast", 1).removeClass("disabled");
    }

    function up_vote(num) {
        data[0].value += num ? num : 1;
        donut.setData(data);
    }

    function down_vote(num) {
        data[1].value += num ? num : 1;
        donut.setData(data);
    }

    $('#delete-btn').on('click', function (event) {
        //toggleFullscreen();
    });

    $("#vote_section").removeClass("hidden");

    $(document).bind("fullscreenchange", function () {
        if ($(document).fullScreen())
            return;

        if (isMobile)
            viewport.activateControls(false);
    });

    window.URL = window.URL || window.webkitURL;
    window.BlobBuilder = window.BlobBuilder || window.WebKitBlobBuilder || window.MozBlobBuilder;

    var editor = new Editor();
    var viewport = new Viewport(editor, isMobile);
    viewport.container.setId('viewport');
    viewport.container.dom.className += " col-md-offset-2";
    viewport.container.dom.className += " col-md-8";
    var fullscreenIcon, screenshotIcon;
    if (isMobile) {
        fullscreenIcon = $('<button id="fullscreenIcon" class="btn bg-gray mobile"> <i class="fa fa-play"></i> <span> &nbsp Start</span>  </button>').get(0);
    } else {
        fullscreenIcon = $('<button id="fullscreenIcon" class="btn bg-gray desktop"> <span>Fullscreen &nbsp</span> <i class="fa fa-arrows-alt"></i> </button>').get(0);
    }

    screenshotIcon = $('<button id="screenshotIcon" class="btn bg-gray mobile"> <i class="fa fa-camera"></i> <span> &nbsp Screenshot</span>  </button>').get(0);

    document.getElementById('rendererContainer').appendChild(viewport.container.dom);

    editor.setTheme(editor.config.getKey('theme'));

    document.addEventListener('dragover', function (event) {

        event.preventDefault();
        event.dataTransfer.dropEffect = 'copy';

    }, false);

    document.addEventListener('drop', function (event) {

        event.preventDefault();
        editor.loader.loadFile(event.dataTransfer.files[ 0 ]);

    }, false);

    var onWindowResize = function (event) {

        editor.signals.windowResize.dispatch();

    };

    window.addEventListener('resize', onWindowResize, false);

    onWindowResize();
    var link = "{$BASE_URL}{$MODELS}/{$model.id}/file";
    var screenshotUrl;

    function resizeImage(url, width, height, callback) {
        var sourceImage = new Image();

        sourceImage.onload = function () {
            // Create a canvas with the desired dimensions
            var canvas = document.createElement("canvas");
            canvas.width = width;
            canvas.height = height;

            // Scale and draw the source image to the canvas
            canvas.getContext("2d").drawImage(sourceImage, 0, 0, width, height);

            // Convert the canvas to a data URL in PNG format
            callback(canvas.toDataURL());
        };

        sourceImage.src = url;
    }

    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
        if (this.readyState == 4 && this.status == 200) {
            var contentDisposition = this.getResponseHeader("Content-Disposition");
            var matches = contentDisposition.match(/filename=(.*)/);
            var fileName = matches[1];

            var file = this.response;
            file.name = fileName;

            viewport.container.dom.appendChild(fullscreenIcon);
            var toggle = true;
            $('#fullscreenIcon').click(function (event) {
                viewport.activateControls(true);
                $('canvas').fullScreen(toggle);
            });

            {if $LOGGED_ID == $model.idauthor || $IS_ADMIN}
            viewport.container.dom.appendChild(screenshotIcon);
            $('#screenshotIcon').click(function (event) {
                screenshotUrl = THREEx.Screenshot.toDataURL(viewport.renderer, "img/png");

                var $textAndPic = $('<div></div>');
                resizeImage(screenshotUrl, 300, 200, function (resizedUrl) {
                    $textAndPic.append('<img class="center-block" src="' + resizedUrl + '" />');

                    BootstrapDialog.show({
                        title: 'Do you wish to set this image as the thumbnail?',
                        message: $textAndPic,
                        buttons: [
                            {
                                label: 'Confirm',
                                cssClass: 'btn-primary',
                                autospin: true,
                                action: function (dialogRef) {
                                    dialogRef.enableButtons(false);
                                    dialogRef.setClosable(false);
                                    dialogRef.getModalBody().html('Submitting thumbnail..');
                                    $.ajax({
                                        url: "{$BASE_URL}models/{$model.id}/thumbnail",
                                        type: "POST",
                                        data: {
                                            image: resizedUrl
                                        },
                                        success: function (data, textStatus, jqXHR) {
                                            dialogRef.close();
                                        },
                                        error: function (jqXHR, textStatus, errorThrown) {
                                            console.log("error");
                                            dialogRef.close();
                                        }
                                    });
                                }
                            },
                            {
                                label: 'Cancel',
                                action: function (dialogRef) {
                                    dialogRef.close();
                                }
                            }
                        ]
                    });
                });
            });
            {/if}

            editor.loader.loadFile(file);
        }
    }
};

xhr.open('GET', '{$BASE_URL}{$MODELS}/{$model.id}/file');
xhr.responseType = 'blob';
xhr.send();

})
;
</script>
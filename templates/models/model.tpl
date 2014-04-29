<section class="content">
    <div class="row">
        <div id="model-display" class="col-md-8 col-md-offset-2">
            <img class="center-block box" src="http://placehold.it/800x600" alt="..."> <!-- TODO: Model Display -->
        </div>
    </div>

    <div class="row">
        <div class="box col-sm-12 col-md-12">
            <div class="nav-tabs-custom">
                <ul class="nav nav-tabs pull-right">
                    {if $LOGGED_ID == $model.idauthor}
                        <li class="pull-right">
                            <a href="#tab_settings" data-toggle="tab"> <i class="fa fa-gear"></i> </a>
                        </li>
                    {/if}
                    <li class="active">
                        <a href="#tab_info" data-toggle="tab">Information</a>
                    </li>
                    <li>
                        <a href="#tab_comments" data-toggle="tab">Comments
                            <span class="badge">{$model.numComments}</span> <!-- TODO: Number of comments -->
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
                                             alt="User Image"/> <!-- TODO: Author's Avatar-->
                                        <!-- TODO: Author's Avatar-->
                                    </div>
                                    <div class="pull-left info">
                                        <p>Author:
                                            <a class="dynamic_load"
                                               href="{$BASE_URL}{$MEMBERS}/{$model.idauthor}">{$model.nameauthor}</a>
                                            <!-- TODO: Author's name -->
                                        </p>

                                        <p>
                                            <time class="timeago"
                                                  datetime="{$model.createdate}">{$model.createdate}</time>
                                            <!-- TODO: Creation Date -->
                                        </p>
                                    </div>
                                </div>
                                <h4>Description:</h4>

                                <p>{$model.description}</p> <!-- TODO: Description -->
                                {if $IS_LOGGED_IN}
                                    <p>
                                        <button id="download-btn" class="btn bg-blue btn-social">
                                            <i class="fa fa-download"></i>
                                            <span>Download</span>
                                        </button>
                                        {if $LOGGED_ID == $model.idauthor}
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
                                    <div class="box-body"> <!-- TODO: Tags -->
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
                            <div class="col-md-8">
                                <div class="box-body chat" id="chat-box">
                                    {foreach $model.comments as $comment}
                                        {include file="models/comment.tpl" comment=$comment}
                                    {/foreach}
                                </div>
                                <div class="box-footer">
                                    {if $IS_LOGGED_IN}
                                        <div class="input-group">
                                            <form action="{$BASE_URL}models/{$model.id}/comments" method="post">
                                                <input class="form-control" name="content" placeholder="Comment this model..."/>
                                                
                                                <div class="input-group-btn">
                                                    <button class="btn btn-success" type="submit">
                                                        <i class="fa fa-plus"></i>
                                                    </button>
                                                </div>
                                            </form>
                                        </div>
                                    {/if}
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="box">
                                    <div class="box-header">
                                        <h3 class="box-title">Votes</h3>
                                    </div>
                                    <div class="box-body chart-responsive center-block">
                                        <div class="chart" id="votes-chart" style="height: 150px; position: relative;">

                                        </div>
                                        {if $IS_LOGGED_IN}
                                            <div class="text-center">
                                                <button style="opacity:1.0" id="up_vote_button"
                                                        class="btn bg-green btn-social">
                                                    <i class="fa fa-thumbs-up"></i>
                                                    <span>Up vote</span>
                                                </button>
                                                <button style="opacity:1.0" id="down_vote_button"
                                                        class="btn bg-red btn-social">
                                                    <i class="fa fa-thumbs-down"></i>
                                                    <span>Down vote</span>
                                                </button>
                                            </div>
                                        {/if}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    {if $LOGGED_ID == $model.idauthor}
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
                                           data-role="tagsinput" placeholder="Add interests"/>
                                </div>
                                <div class="callout callout-info hidden" id="tags-info">
                                    <h4>To add a tag</h4>
                                    <p>After writing each tag you want to add, press enter.
                                    <br/>Once finished you can click the submit button.</p>
                                </div>
                                <input type="submit"/>
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

<script type="text/javascript">
    $(function () {
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

        var voted_up = false;
        var voted_down = false;
        $("#interests-field + .bootstrap-tagsinput").focusin(function (event) {
            event.preventDefault();
            $("#tags-info").removeClass("hidden");
        });
        
        $("#interests-field + .bootstrap-tagsinput").focusout(function (event) {
            event.preventDefault();
            $("#tags-info").addClass("hidden");
        });

        $("#up_vote_button").click(function () {
            if (voted_up)
                reset_up();
            else
                vote_up();
        });

        $("#down_vote_button").click(function () {
            if (voted_down)
                reset_down();
            else
                vote_down();
        });

        function vote_up() {
            up_vote();
            $("#down_vote_button").fadeTo("fast", 0.5).addClass("disabled");
            voted_up = true;
        }

        function vote_down() {
            down_vote();
            $("#up_vote_button").fadeTo("fast", 0.5).addClass("disabled");
            voted_down = true;
        }

        function reset_up() {
            voted_up = false;
            up_vote(-1);
            enable_buttons();
        }

        function reset_down() {
            voted_down = false;
            down_vote(-1);
            enable_buttons();
        }

        function enable_buttons() {
            $("#up_vote_button").fadeTo("fast", 1).removeClass("disabled");
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
    })
    ;
</script>
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
                    <li class="pull-right">
                        <a href="#tab_settings" data-toggle="tab"> <i class="fa fa-gear"></i> </a>
                    </li>
                    <li class="active">
                        <a href="#tab_info" data-toggle="tab">Information</a>
                    </li>
                    <li>
                        <a href="#tab_comments" data-toggle="tab">Comments
                            <span class="badge">{$model.numComments}</span> <!-- TODO: Number of comments -->
                        </a>
                    </li>
                    <li class="pull-left header">
                        <i class="fa fa-info-circle"></i>{$model.name}</li> <!-- TODO: Model name -->
                </ul>
                <div class="tab-content">
                    <div class="tab-pane active" id="tab_info">
                        <div class="row">
                            <div class="col-md-8">
                                <div class="user-panel">
                                    <div class="pull-left image">
                                        <img src="{$GRAVATAR_URL}{$model.hash}" class="img-square" alt="User Image" /> <!-- TODO: Author's Avatar-->
                                    </div>
                                    <div class="pull-left info">
                                        <p>Author:
                                            <a href="{$BASE_URL}member/{$model.idauthor}">{$model.nameauthor}</a> <!-- TODO: Author's name -->
                                        </p>
                                        <p>
                                            <time class="timeago" datetime="{$model.createdate}">{$model.createdate}</time> <!-- TODO: Creation Date -->
                                        </p>
                                    </div>
                                </div>
                                <h4>Description:</h4>
                                <p>{$model.description}</p> <!-- TODO: Description -->
                                <p>
                                    <button id="download-btn" class="btn bg-blue btn-social">
                                        <i class="fa fa-download"></i>
                                        <span>Download</span>
                                    </button>
                                    <button id="delete-btn" class="btn bg-red btn-social">
                                        <i class="fa fa-trash-o"></i>
                                        <span>Delete</span>
                                    </button>
                                </p>
                            </div>
                            <div class="col-md-4">
                                <!-- Primary tile -->
                                <div class="box box-solid bg-light-blue">
                                    <div class="box-header">
                                        <h3 class="box-title">Tags</h3>
                                    </div>
                                    <div class="box-body"> <!-- TODO: Tags -->
                                        {foreach $model.tags as $tag}
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
                                    <div class="input-group">
                                        <input class="form-control" placeholder="Comment this model..." />
                                        <div class="input-group-btn">
                                            <button class="btn btn-success">
                                                <i class="fa fa-plus"></i>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="box">
                                    <div class="box-header">
                                        <h3 class="box-title">Votes</h3>
                                    </div>
                                    <div class="box-body chart-responsive center-block">
                                        <div class="chart" id="votes-chart" style="height: 150px; position: relative;"></div>
                                        <div class="text-center">
                                            <button style="opacity:1.0" id="up_vote_button" class="btn bg-green btn-social">
                                                <i class="fa fa-thumbs-up"></i>
                                                <span>Up vote</span>
                                            </button>
                                            <button style="opacity:1.0" id="down_vote_button" class="btn bg-red btn-social">
                                                <i class="fa fa-thumbs-down"></i>
                                                <span>Down vote</span>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="tab-pane" id="tab_settings">
                        <div class="form-group">
                            <label for="about-me-field">Description:</label>
                            <textarea class="form-control" id="about-me-field" placeHolder="Enter your text here">This is the most bland model known to man. Shame on you for hosting this content.</textarea>
                        </div>
                        <div class="form-group">
                            <label for="interests-field">Tags:</label>
                            <br />
                            <input type="text" class="form-control" id="interests-field" value="3D, Model, Bland, CG" data-role="tagsinput" placeholder="Add interests" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

</section>

<script src="{$BASE_URL}js/plugins/morris/raphael-min.js"></script>
<script src="{$BASE_URL}js/plugins/morris/morris.min.js" type="text/javascript"></script>

<script type="text/javascript">
    $(function() {
        var data = [{
            label: "Up votes",
            value: {$model.numupvotes}
        }, {
            label: "Down votes",
            value: {$model.numdownvotes}
        }];

        var donut = new Morris.Donut({
            element: 'votes-chart',
            /*resize: true,*/
            colors: ["green", "red"],
            data: data/*,
            hideHover: 'auto'*/
        });

        var voted_up = false;
        var voted_down = false;

        $("#up_vote_button").click(function() {
            if (voted_up)
                reset_up();
            else
                vote_up();
        });

        $("#down_vote_button").click(function() {
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
    });
</script>

<script src="{$BASE_URL}js/bootstrap-tagsinput.min.js" type="text/javascript"></script>
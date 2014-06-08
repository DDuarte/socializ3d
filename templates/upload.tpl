<section class="content-header">
    <h1 id="myh122">
        Upload a Model
    </h1>
</section>

<section class="content">
    <div class="row">
        <div class="col-md-8 col-centered" id="upload-form">
            <div id="error_messages" class="hidden">
                {foreach $ERROR_MESSAGES as $error}
                    <div class="error">{$error}<a class="close" href="#">X</a></div>
                {/foreach}
            </div>
            <form id="uploadForm" action="{$BASE_URL}upload" method="post" enctype="multipart/form-data">

                <div class="box-body">
                    <input type="file" name="file" required/>

                    <hr>

                    <div class="form-group">
                        <label for="name-filed">Model name: </label>
                        <input type="text" class="form-control" id="name-filed" name="name" placeHolder="Enter model's name" required/>
                    </div>

                    <div class="form-group">
                        <label for="description-field">Description: </label>
                        <textarea class="form-control" id="description-field" name="description" placeHolder="Enter model's description"  required></textarea>
                    </div>

                    <div class="form-group">
                        <label for="to-field">To:</label>
                        <select class="form-control" id="to-field" name="to">
                            <option selected>Private</option>
                            <option>Public</option>
                            <option>Friends</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Groups: </label>
                        <div class="form-control" style="overflow-y:auto; overflow-x:hidden; max-height:100px; height: inherit;">
                            {foreach $userInfo.groups as $group}
                                <span style="float: left; clear: both"> <input type="checkbox" name="groups[]" value="{$group.groupid}" /><span style="margin-left: 10px">{$group.groupname}</span></span>
                            {/foreach}
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="tags-field">Tags: </label> <br />
                        <input type="text" class="form-control" id="tags-field" name="tags" value="" data-role="tagsinput" placeholder="Add tags" />
                    </div>

                    <hr>

                    <div class="form-group">
                        <div id="uploadSubmit" class="btn btn-primary btn-sm" style="margin-top: 10px">Submit all files</div>
                    </div>

                </div>
            </form>
        </div>
    </div>
</section>

<script src="{$BASE_URL}js/pages/upload.js" type="text/javascript"></script>
<script src="{$BASE_URL}js/bootstrap-tagsinput.min.js" type="text/javascript"></script>

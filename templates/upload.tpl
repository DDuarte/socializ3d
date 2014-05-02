<title>Upload</title>

<section class="content-header">
    <h1 id="myh122">
        Upload a Model
    </h1>
</section>

<style>
    .inner-content {
        width: 95%;
        margin: 0 auto;
    }

    .box.box-drop {
        height: 125px;
        background: rgba(182,205,229,0.5);
        border-radius: 10px;
        border: 3px dashed rgba(0,0,255,0.2);
        padding: 0;
        text-align: center;
        font-size: 2em;
        font-weight: bold;
    }

    .box.box-drop h2 {
        margin-top: 10px;
        font-size: 0.75em;
    }

    .btn.btn-drop {
        display: inline-block;
        margin-top: 10px;
        margin-bottom: 6px;
    }

    .hidden {
        visibility: hidden;
    }

    .col-centered {
        float: none;
        margin: 0 auto;
    }

    #drop-files {
        width: 90%;
        margin-top: 10px;
        margin-bottom: 10px;
    }

    #upload-form .form-group textarea {
        resize: vertical;
    }

    #upload-form .form-group {
        margin-bottom: 10px;
    }
</style>

<section class="content">
    <div class="row">
        <div class="col-md-8 col-centered" id="upload-form">
            <form action="{$BASE_URL}upload" method="post">

                <div class="box-body">
                    <!-- <div class="form-group">
                        <div id="drop-files" class="box box-drop col-centered">
                            <h2>Drag &amp; drop your file here or</h2>
                            <div id="upload-button" class="btn btn-primary btn-lg btn-drop">Choose a file to upload</div>
                        </div>
                    </div> -->

                    <hr>

                    <div class="form-group">
                        <label for="name-filed">Model name: </label>
                        <input type="text" class="form-control" id="name-filed" name="name" placeHolder="Enter model's name" />
                    </div>

                    <div class="form-group">
                        <label for="description-field">Description: </label>
                        <textarea class="form-control" id="description-field" name="description" placeHolder="Enter model's description" ></textarea>
                    </div>

                    <div class="form-group">
                        <label for="to-field">To:</label>
                        <select class="form-control" id="to-field" name="to">
                            <option>Public</option>
                            <option>Friends</option>
                            {foreach $userInfo.groups as $group}
                                <option>{$group.groupname}</option>
                            {/foreach}
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="tags-field">Tags: </label> <br />
                        <input type="text" class="form-control" id="tags-field" name="tags" value="" data-role="tagsinput" placeholder="Add tags" />
                    </div>

                    <hr>

                    <div class="form-group">
                        <div id="submit" class="btn btn-primary btn-sm" style="margin-top: 10px">Submit all files</button>
                    </div>

                </div>
            </form>
        </div>
    </div>
</section>

<script src="{$BASE_URL}js/dropzone.min.js" type="text/javascript"></script>
<script src="{$BASE_URL}js/pages/upload.js" type="text/javascript"></script>
<script src="{$BASE_URL}js/bootstrap-tagsinput.min.js" type="text/javascript"></script>

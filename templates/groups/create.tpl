<section class="content-header">
    <h1 id="myh122">
        Create Group
    </h1>
</section>

<style>
    .inner-content {
        width: 95%;
        margin: 0 auto;
    }
    .box.box-drop {
        height: 125px;
        background: rgba(182, 205, 229, 0.5);
        border-radius: 10px;
        border: 3px dashed rgba(0, 0, 255, 0.2);
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
            <form action="#" method="put">

                <div class="box-body">
                    <div class="form-group">
                        <div id="drop-files" class="box box-drop col-centered">
                            <h2>Drag &amp; drop the cover image here or</h2>
                            <div id="upload-button" class="btn btn-primary btn-lg btn-drop">Choose a image file to upload</div>
                        </div>
                    </div>

                    <hr>

                    <div class="form-group">
                        <label for="name-filed">Group name:</label>
                        <input type="text" class="form-control" id="name-filed" placeHolder="Enter the group name" />
                    </div>

                    <div class="form-group">
                        <label for="description-field">About:</label>
                        <textarea class="form-control" id="description-field" placeHolder="What's the group about?"></textarea>
                    </div>

                    <div class="form-group">
                        <label for="to-field">Visibility:</label>
                        <select class="form-control" id="to-field">
                            <option>Public</option>
                            <option>Private</option>
                        </select>
                    </div>

                    <!--<div class="form-group">
                        <label for="tags-field">Tags:</label>
                        <br />
                        <input type="text" class="form-control" id="tags-field" value="3D, Model, Bland, CG" data-role="tagsinput" placeholder="Add tags" />
                    </div> -->

                    <div class="form-group">
                        <div id="submit" class="btn btn-primary btn-sm" style="margin-top: 10px">Submit</div>
                    </div>
                </div>
            </form>
        </div>
    </div>
</section>

<script src="js/dropzone.min.js" type="text/javascript"></script>
<script src="js/pages/upload.js" type="text/javascript"></script>
<script src="js/bootstrap-tagsinput.min.js" type="text/javascript"></script>
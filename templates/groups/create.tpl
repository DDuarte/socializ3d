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
            <form action="#" method="POST">

                <div class="box-body">

                    <div class="form-group">
                        <label for="name-field">Group name:</label>
                        <input name="name" required type="text" class="form-control" id="name-field" placeHolder="Enter the group name" />
                    </div>

                    <div class="form-group">
                        <label for="cover-image">Cover image:</label>
                        <input name="cover" type="text" class="form-control" id="cover-image" placeHolder="Cover img URL" />
                    </div>

                    <div class="form-group">
                        <label for="avatar-image">Avatar image:</label>
                        <input name="avatar" type="text" class="form-control" id="avatar-image" placeHolder="Avatar img URL" />
                    </div>

                    <div class="form-group">
                        <label for="description-field">About:</label>
                        <textarea name="about" class="form-control" id="description-field" placeHolder="What's the group about?"></textarea>
                    </div>

                    <div class="form-group">
                        <label for="to-field">Visibility:</label>
                        <select name="visibility" class="form-control" id="to-field">
                            <option>Public</option>
                            <option>Private</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <div id="submit" class="btn btn-primary btn-sm">Submit</div>
                    </div>
                </div>
            </form>
        </div>
    </div>
</section>

<script src="{$BASE_URL}js/dropzone.min.js" type="text/javascript"></script>
<script src="{$BASE_URL}js/pages/upload.js" type="text/javascript"></script>
<script src="{$BASE_URL}js/bootstrap-tagsinput.min.js" type="text/javascript"></script>

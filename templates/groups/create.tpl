<section class="content-header">
    <h1 id="myh122">
        Create Group
    </h1>
</section>

<section class="content">
    <div class="row">
        <div class="col-md-8 col-centered" id="upload-form">
            <form id="createGroupForm" action="#" method="POST">

                <div class="box-body">

                    <div class="form-group">
                        <label for="name-field">Group name:</label>
                        <input name="name" type="text" class="form-control" id="name-field" placeHolder="Enter the group name" required/>
                    </div>

                    <div class="form-group">
                        <label for="cover-image">Cover image:</label>
                        <input name="cover" type="text" class="form-control" id="cover-image" placeHolder="Cover img URL" />
                        <span class="help-block">Optional; recommended 1150x200</span>
                    </div>

                    <div class="form-group">
                        <label for="avatar-image">Avatar image:</label>
                        <input name="avatar" type="text" class="form-control" id="avatar-image" placeHolder="Avatar img URL" />
                        <span class="help-block">Optional; recommended 250x250</span>
                    </div>

                    <div class="form-group">
                        <label for="description-field">About:</label>
                        <textarea name="about" class="form-control" id="description-field" placeHolder="What's the group about?"></textarea>
                    </div>

                    <div class="form-group">
                        <label for="to-field">Visibility:</label>
                        <select name="visibility" class="form-control" id="to-field">
                            <option selected>Public</option>
                            <option>Private</option>
                        </select>
                        <span class="help-block">Public: everyone can see your group; Private: invitation only</span>
                    </div>

                    <div class="form-group">
                        <button type="submit" id="submitBtn" class="btn btn-primary btn-sm">Submit</button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</section>

<script src="{$BASE_URL}js/pages/upload.js" type="text/javascript"></script>
<script src="{$BASE_URL}js/bootstrap-tagsinput.min.js" type="text/javascript"></script>
<script src="{$BASE_URL}js/pages/createGroup.js" type="text/javascript"></script>

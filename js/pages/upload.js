$("div#drop-files").dropzone({ 
    autoProcessQueue: false,
    uploadMultiple: false,
    parallelUploads: 1,
    maxFiles: 1,
    maxFilesize: 5,
    
    init: function() {
        var submitButton = $("#submit"); 
        var self = this;
        Dropzone.options.dropFiles = false;
        
        this.on("addedfile", function(file) { 
            $('#upload-preview>.dz-file-preview>:not(.dz-details)').remove();
            $("#submit").removeAttr("disabled");
        });
        
        this.on("uploadprogress", function(file, progress) {
            $('#upload-progress-bar').css("width", progress + "%");
        });
        
        this.on("maxfilesexceeded", function(file) { 
            this.removeFile(file); 
        });
        
        $('#upload-progress-bar').css("width", "0%");
        
        submitButton.on('click', function(event) {
            event.preventDefault();
            self.processQueue();
        });
        
        $("#submit").attr("disabled", "disabled");
    },
    
    url: "http://localhost:80/pages/index.php",
    method: "put",
    clickable: $("div#drop-files #upload-button").get(0),
    previewsContainer: $('#upload-preview').get(0),
    
});
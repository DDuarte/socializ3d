$('#submit').click(function () {
    $('form').submit();
});

/*$("div#drop-files").dropzone({
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
            $('#upload-preview').find('>.dz-file-preview>:not(.dz-details)').remove();
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

        submitButton.attr("disabled", "disabled");
    },
    
    url: "/upload",
    method: "put",
    clickable: $("div#drop-files #upload-button").get(0),
    previewsContainer: $('#upload-preview').get(0)
});
*/
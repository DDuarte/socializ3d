$(document).ready(function() {
    $('#createGroupForm').bootstrapValidator({
        message: 'This value is not valid',
        feedbackIcons: {
            valid: 'glyphicon glyphicon-ok',
            invalid: 'glyphicon glyphicon-remove',
            validating: 'glyphicon glyphicon-refresh'
        },
        submitButtons: 'button[type="submit"]',
        fields: {
            name: {
                message: 'The group name is not valid',
                validators: {
                    notEmpty: {
                        message: 'A group name field is required and cannot be empty'
                    },
                    stringLength: {
                        min: 1,
                        max: 70,
                        message: 'The group name field must be more than 1 and less than 71 characters long'
                    }
                }
            },
            about: {
                validators: {
                    stringLength: {
                        min: 1,
                        max: 1024,
                        message: 'The group about field must be more than 1 and less than 1024 characters long'
                    }
                }
            },
            cover: {
                validators: {
                    uri: {
                        message: 'The cover url is not valid'
                    }
                }
            },
            avatar: {
                validators: {
                    uri: {
                        message: 'The avatar url is not valid'
                    }
                }
            }
        }
    });
});

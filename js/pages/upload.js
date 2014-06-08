$(document).ready(function() {
    $('#uploadForm').bootstrapValidator({
        message: 'This value is not valid',
        feedbackIcons: {
            valid: 'glyphicon glyphicon-ok',
            invalid: 'glyphicon glyphicon-remove',
            validating: 'glyphicon glyphicon-refresh'
        },
        fields: {
            name: {
                message: 'The name is not valid',
                validators: {
                    notEmpty: {
                        message: 'The name is required and cannot be empty'
                    },
                    stringLength: {
                        min: 2,
                        max: 30,
                        message: 'The name must be more than 2 and less than 30 characters long'
                    },
                    regexp: {
                        regexp: /^[a-zA-Z0-9_]+$/,
                        message: 'The name can only consist of alphabetical, number and underscore'
                    }
                }
            },
            description: {
                message: 'The description is not valid',
                validators: {
                    notEmpty: {
                        message: 'The description is required and cannot be empty'
                    },
                    stringLength: {
                        min: 1,
                        max: 1024,
                        message: 'The description must be more than 1 and less than 1024 characters long'
                    }
                }
            }
        }
    });
});

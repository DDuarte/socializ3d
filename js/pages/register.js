$(document).ready(function() {
    $('.registerForm').bootstrapValidator({
        message: 'This value is not valid',
        feedbackIcons: {
            valid: 'glyphicon glyphicon-ok',
            invalid: 'glyphicon glyphicon-remove',
            validating: 'glyphicon glyphicon-refresh'
        },
        fields: {
            realName: {
                message: 'The real name is not valid',
                validators: {
                    notEmpty: {
                        message: 'The real name is required and cannot be empty'
                    },
                    stringLength: {
                        min: 6,
                        max: 70,
                        message: 'The real name must be more than 6 and less than 70 characters long'
                    },
                    regexp: {
                        regexp: /^[-\sa-zA-Z]+$/,
                        message: 'The real name can only consist of alphabetical, ' - ' and spaces'
                    }
                }
            },
            birthDate: {
                message: 'The birth date is not valid',
                validators: {
                    date: {
                        format: 'YYYY/MM/DD',
                        message: 'The value is not a valid date'
                    }
                }
            },
            username: {
                message: 'The username is not valid',
                validators: {
                    notEmpty: {
                        message: 'The username is required and cannot be empty'
                    },
                    stringLength: {
                        min: 6,
                        max: 30,
                        message: 'The username must be more than 6 and less than 30 characters long'
                    },
                    regexp: {
                        regexp: /^[a-zA-Z0-9_]+$/,
                        message: 'The username can only consist of alphabetical, number and underscore'
                    }
                }
            },
            email: {
                validators: {
                    notEmpty: {
                        message: 'The email is required and cannot be empty'
                    },
                    emailAddress: {
                        message: 'The input is not a valid email address'
                    }
                }
            },
            password: {
                validators: {
                    notEmpty: {
                        message: 'The password is required'
                    },
                    identical: {
                        field: 'password2',
                        message: 'The password and its confirm are not the same'
                    }
                }
            },
            password2: {
                validators: {
                    notEmpty: {
                        message: 'The password confirmation is required'
                    },
                    identical: {
                        field: 'password',
                        message: 'The password and its confirm are not the same'
                    }
                }
            }
        }
    });
});

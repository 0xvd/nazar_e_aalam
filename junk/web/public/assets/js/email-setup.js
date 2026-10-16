$(document).ready(function () {
    var baseUrl = $('meta[name="base-url"]').attr("content");

    $(".update_btn").click(function (event) {
        event.preventDefault();
        let formData = $(".email_setup_form").serialize();
        $(".mail_host").text("");
        $(".mail_port").text("");
        $(".mail_username").text("");
        $(".mail_encryption").text("");
        $(".mail_from_address").text("");
        $(".mail_password").text("");
        $.ajax({
            url: baseUrl + "/email-settings",
            type: "POST",
            data: formData,
            success: function (response) {
                Swal.fire({
                    title: "Success!",
                    text: "Email setup updated ✉",
                    icon: "success",
                    confirmButtonText: "Close",
                    timer: 1500,
                });
            },
            error: function (error) {
                if (error.responseJSON.errors.provider) {
                    $(".mail_host").text(error.responseJSON.errors.provider[0]);
                }
                if (error.responseJSON.errors.smtp_port) {
                    $(".mail_port").text(
                        error.responseJSON.errors.smtp_port[0],
                    );
                }
                if (error.responseJSON.errors.mail_username) {
                    $(".mail_username").text(
                        error.responseJSON.errors.mail_username[0],
                    );
                }
                if (error.responseJSON.errors.mail_encryption) {
                    $(".mail_encryption").text(
                        error.responseJSON.errors.mail_encryption[0],
                    );
                }
                if (error.responseJSON.errors.mail_password) {
                    $(".mail_password").text(
                        error.responseJSON.errors.mail_password[0],
                    );
                }
                if (error.responseJSON.errors.mail_from_address) {
                    $(".mail_from_address").text(
                        error.responseJSON.errors.mail_from_address[0],
                    );
                }
            },
        });
    });
});

$(document).ready(function () {
    var baseUrl = $('meta[name="base-url"]').attr("content");

    $(".change_password_btn").click(function (event) {
        event.preventDefault();
        let formData = $(".change_password_form").serialize();
        $(".current_password").text("");
        $(".new_password").text("");
        $(".password_confirmation").text("");
        $.ajax({
            url: baseUrl + "/password-change",
            type: "POST",
            data: formData,
            success: function (response) {
                if (response.success != true) {
                    $(".current_password").text(response.message);
                    Swal.fire({
                        title: "Success!",
                        text: "Password updated 🔑",
                        icon: "success",
                        confirmButtonText: "Close",
                        timer: 1500,
                    });
                    $(".change_password_form").trigger("reset");
                } else {
                    $(".change_password_form").trigger("reset");
                }
            },
            error: function (error) {
                if (error.responseJSON.errors.current_password) {
                    $(".current_password").text(
                        error.responseJSON.errors.current_password[0],
                    );
                }
                if (error.responseJSON.errors.password) {
                    $(".new_password").text(
                        error.responseJSON.errors.password[0],
                    );
                }
                if (error.responseJSON.errors.confirm_password) {
                    $(".password_confirmation").text(
                        error.responseJSON.errors.confirm_password[0],
                    );
                }
            },
        });
    });
});

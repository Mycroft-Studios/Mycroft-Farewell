Phone.Settings = {};
Phone.Settings.Background = "default";
Phone.Settings.OpenedTab = null;
Phone.Settings.Backgrounds = {
    'default': {
        label: "Standard ESX"
    }
};

var PressedBackground = null;
var PressedBackgroundObject = null;
var OldBackground = null;
var IsChecked = null;

$(document).on('click', '.settings-app-tab', function(e){
    e.preventDefault();
    var PressedTab = $(this).data("settingstab");

    if (PressedTab == "background") {
        Phone.Animations.TopSlideDown(".settings-"+PressedTab+"-tab", 200, 0);
        Phone.Settings.OpenedTab = PressedTab;
    } else if (PressedTab == "profilepicture") {
        Phone.Animations.TopSlideDown(".settings-"+PressedTab+"-tab", 200, 0);
        Phone.Settings.OpenedTab = PressedTab;
    } else if (PressedTab == "numberrecognition") {
        var checkBoxes = $(".numberrec-box");
        Phone.Data.AnonymousCall = !checkBoxes.prop("checked");
        checkBoxes.prop("checked", Phone.Data.AnonymousCall);

        if (!Phone.Data.AnonymousCall) {
            $("#numberrecognition > p").html('Off');
        } else {
            $("#numberrecognition > p").html('On');
        }
    }
});

$(document).on('click', '#accept-background', function(e){
    e.preventDefault();
    var hasCustomBackground = Phone.Functions.IsBackgroundCustom();

    if (hasCustomBackground === false) {
        Phone.Notifications.Add("fas fa-paint-brush", "Settings", Phone.Settings.Backgrounds[Phone.Settings.Background].label+" is set!")
        Phone.Animations.TopSlideUp(".settings-"+Phone.Settings.OpenedTab+"-tab", 200, -100);
        $(".phone-background").css({"background-image":"url('/html/img/backgrounds/"+Phone.Settings.Background+".png')"})
    } else {
        Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Personal background set!")
        Phone.Animations.TopSlideUp(".settings-"+Phone.Settings.OpenedTab+"-tab", 200, -100);
        $(".phone-background").css({"background-image":"url('"+Phone.Settings.Background+"')"});
    }

    $.post('https://esx-phone/SetBackground', JSON.stringify({
        background: Phone.Settings.Background,
    }))
});

Phone.Functions.LoadMetaData = function(MetaData) {
    if (MetaData.background !== null && MetaData.background !== undefined) {
        Phone.Settings.Background = MetaData.background;
    } else {
        Phone.Settings.Background = "default";
    }

    var hasCustomBackground = Phone.Functions.IsBackgroundCustom();
    
    if (!hasCustomBackground) {
        $(".phone-background").css({"background-image":"url('/html/img/backgrounds/"+Phone.Settings.Background+".jpg')"})
    } else {
        $(".phone-background").css({"background-image":"url('"+Phone.Settings.Background+"')"});
    }
    if (MetaData.profilepicture == "default") {
        $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="./img/default.png">');
    } else {
        $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="'+MetaData.profilepicture+'">');
    }
}

$(document).on('click', '#cancel-background', function(e){
    e.preventDefault();
    Phone.Animations.TopSlideUp(".settings-"+Phone.Settings.OpenedTab+"-tab", 200, -100);
});

Phone.Functions.IsBackgroundCustom = function() {
    var retval = true;
    $.each(Phone.Settings.Backgrounds, function(i, background){
        if (Phone.Settings.Background == i) {
            retval = false;
        }
    });
    return retval
}

$(document).on('click', '.background-option', function(e){
    e.preventDefault();
    PressedBackground = $(this).data('background');
    PressedBackgroundObject = this;
    OldBackground = $(this).parent().find('.background-option-current');
    IsChecked = $(this).find('.background-option-current');

    if (IsChecked.length === 0) {
        if (PressedBackground != "custom-background") {
            Phone.Settings.Background = PressedBackground;
            $(OldBackground).fadeOut(50, function(){
                $(OldBackground).remove();
            });
            $(PressedBackgroundObject).append('<div class="background-option-current"><i class="fas fa-check-circle"></i></div>');
        } else {
            Phone.Animations.TopSlideDown(".background-custom", 200, 13);
        }
    }
});

$(document).on('click', '#accept-custom-background', function(e){
    e.preventDefault();

    Phone.Settings.Background = $(".custom-background-input").val();
    $(OldBackground).fadeOut(50, function(){
        $(OldBackground).remove();
    });
    $(PressedBackgroundObject).append('<div class="background-option-current"><i class="fas fa-check-circle"></i></div>');
    Phone.Animations.TopSlideUp(".background-custom", 200, -23);
});

$(document).on('click', '#cancel-custom-background', function(e){
    e.preventDefault();

    Phone.Animations.TopSlideUp(".background-custom", 200, -23);
});

// Profile Picture

var PressedProfilePicture = null;
var PressedProfilePictureObject = null;
var OldProfilePicture = null;
var ProfilePictureIsChecked = null;

$(document).on('click', '#accept-profilepicture', function(e){
    e.preventDefault();
    var ProfilePicture = Phone.Data.MetaData.profilepicture;
    if (ProfilePicture === "default") {
        Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Standard avatar set!")
        Phone.Animations.TopSlideUp(".settings-"+Phone.Settings.OpenedTab+"-tab", 200, -100);
        $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="./img/default.png">');
    } else {
        Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Personal avatar set!")
        Phone.Animations.TopSlideUp(".settings-"+Phone.Settings.OpenedTab+"-tab", 200, -100);
        $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="'+ProfilePicture+'">');
    }
    $.post('https://esx-phone/UpdateProfilePicture', JSON.stringify({
        profilepicture: ProfilePicture,
    }));
});

$(document).on('click', '#accept-custom-profilepicture', function(e){
    e.preventDefault();
    Phone.Data.MetaData.profilepicture = $(".custom-profilepicture-input").val();
    $(OldProfilePicture).fadeOut(50, function(){
        $(OldProfilePicture).remove();
    });
    $(PressedProfilePictureObject).append('<div class="profilepicture-option-current"><i class="fas fa-check-circle"></i></div>');
    Phone.Animations.TopSlideUp(".profilepicture-custom", 200, -23);
});

$(document).on('click', '.profilepicture-option', function(e){
    e.preventDefault();
    PressedProfilePicture = $(this).data('profilepicture');
    PressedProfilePictureObject = this;
    OldProfilePicture = $(this).parent().find('.profilepicture-option-current');
    ProfilePictureIsChecked = $(this).find('.profilepicture-option-current');
    if (ProfilePictureIsChecked.length === 0) {
        if (PressedProfilePicture != "custom-profilepicture") {
            Phone.Data.MetaData.profilepicture = PressedProfilePicture
            $(OldProfilePicture).fadeOut(50, function(){
                $(OldProfilePicture).remove();
            });
            $(PressedProfilePictureObject).append('<div class="profilepicture-option-current"><i class="fas fa-check-circle"></i></div>');
        } else {
            Phone.Animations.TopSlideDown(".profilepicture-custom", 200, 13);
        }
    }
});

$(document).on('click', '#cancel-profilepicture', function(e){
    e.preventDefault();
    Phone.Animations.TopSlideUp(".settings-"+Phone.Settings.OpenedTab+"-tab", 200, -100);
});


$(document).on('click', '#cancel-custom-profilepicture', function(e){
    e.preventDefault();
    Phone.Animations.TopSlideUp(".profilepicture-custom", 200, -23);
});

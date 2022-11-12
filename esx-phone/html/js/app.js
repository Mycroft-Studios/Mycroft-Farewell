QB = {}
Phone = {}
QB.Screen = {}
Phone.Functions = {}
Phone.Animations = {}
Phone.Notifications = {}
Phone.ContactColors = {
    0: "#9b59b6",
    1: "#3498db",
    2: "#e67e22",
    3: "#e74c3c",
    4: "#1abc9c",
    5: "#9c88ff",
}

Phone.Data = {
    currentApplication: null,
    PlayerData: {},
    Applications: {},
    IsOpen: false,
    CallActive: false,
    MetaData: {},
    PlayerJob: {},
    AnonymousCall: false,
}

Phone.Data.MaxSlots = 16;

OpenedChatData = {
    number: null,
}

var CanOpenApp = true;
var up = false

function IsAppJobBlocked(joblist, myjob) {
    var retval = false;
    if (joblist.length > 0) {
        $.each(joblist, function(i, job){
            if (job == myjob) {
                retval = true;
            }
        });
    }
    return retval;
}

Phone.Functions.SetupApplications = function(data) {
    Phone.Data.Applications = data.applications;

    var i;
    for (i = 1; i <= Phone.Data.MaxSlots; i++) {
        var applicationSlot = $(".phone-applications").find('[data-appslot="'+i+'"]');
        $(applicationSlot).html("");
        $(applicationSlot).css({
            "background-color":"transparent"
        });
        $(applicationSlot).prop('title', "");
        $(applicationSlot).removeData('app');
        $(applicationSlot).removeData('placement')
    }

    $.each(data.applications, function(i, app){
        var applicationSlot = $(".phone-applications").find('[data-appslot="'+app.slot+'"]');
        var blockedapp = IsAppJobBlocked(app.blockedjobs, Phone.Data.PlayerData.job.name)

        if ((!app.job || app.job === Phone.Data.PlayerData.job.name) && !blockedapp) {
            $(applicationSlot).css({"background-color":app.color});
            var icon = '<i class="ApplicationIcon '+app.icon+'" style="'+app.style+'"></i>';
            if (app.app == "meos") {
                icon = '<img src="./img/politie.png" class="police-icon">';
            }
            $(applicationSlot).html(icon+'<div class="app-unread-alerts">0</div>');
            $(applicationSlot).prop('title', app.tooltipText);
            $(applicationSlot).data('app', app.app);

            if (app.tooltipPos !== undefined) {
                $(applicationSlot).data('placement', app.tooltipPos)
            }
        }
    });

    $('[data-toggle="tooltip"]').tooltip();
}

Phone.Functions.SetupAppWarnings = function(AppData) {
    $.each(AppData, function(i, app){
        var AppObject = $(".phone-applications").find("[data-appslot='"+app.slot+"']").find('.app-unread-alerts');

        if (app.Alerts > 0) {
            $(AppObject).html(app.Alerts);
            $(AppObject).css({"display":"block"});
        } else {
            $(AppObject).css({"display":"none"});
        }
    });
}

Phone.Functions.IsAppHeaderAllowed = function(app) {
    var retval = true;
    $.each(Config.HeaderDisabledApps, function(i, blocked){
        if (app == blocked) {
            retval = false;
        }
    });
    return retval;
}

$(document).on('click', '.phone-application', function(e){
    e.preventDefault();
    var PressedApplication = $(this).data('app');
    var AppObject = $("."+PressedApplication+"-app");

    if (AppObject.length !== 0) {
        if (CanOpenApp) {
            if (Phone.Data.currentApplication == null) {
                Phone.Animations.TopSlideDown('.phone-application-container', 300, 0);
                Phone.Functions.ToggleApp(PressedApplication, "block");

                if (Phone.Functions.IsAppHeaderAllowed(PressedApplication)) {
                    Phone.Functions.HeaderTextColor("black", 300);
                }

                Phone.Data.currentApplication = PressedApplication;

                if (PressedApplication == "settings") {
                    $("#myPhoneNumber").text(Phone.Data.PlayerData.phone_number);
                } else if (PressedApplication == "twitter") {
                    $.post('https://esx-phone/GetMentionedTweets', JSON.stringify({}), function(MentionedTweets){
                        Phone.Notifications.LoadMentionedTweets(MentionedTweets)
                    })
                    $.post('https://esx-phone/GetHashtags', JSON.stringify({}), function(Hashtags){
                        Phone.Notifications.LoadHashtags(Hashtags)
                    })
                    if (Phone.Data.IsOpen) {
                        $.post('https://esx-phone/GetTweets', JSON.stringify({}), function(Tweets){
                            Phone.Notifications.LoadTweets(Tweets);
                        });
                    }
                } else if (PressedApplication == "bank") {
                    Phone.Functions.DoBankOpen();
                    $.post('https://esx-phone/GetBankContacts', JSON.stringify({}), function(contacts){
                        Phone.Functions.LoadContactsWithNumber(contacts);
                    });
                    $.post('https://esx-phone/GetInvoices', JSON.stringify({}), function(invoices){
                        Phone.Functions.LoadBankInvoices(invoices);
                    });
                } else if (PressedApplication == "messages") {
                    $.post('https://esx-phone/GetmessagesChats', JSON.stringify({}), function(chats){
                        Phone.Functions.LoadmessagesChats(chats);
                    });
                } else if (PressedApplication == "phone") {
                    $.post('https://esx-phone/GetMissedCalls', JSON.stringify({}), function(recent){
                        Phone.Functions.SetupRecentCalls(recent);
                    });
                    $.post('https://esx-phone/GetSuggestedContacts', JSON.stringify({}), function(suggested){
                        Phone.Functions.SetupSuggestedContacts(suggested);
                    });
                    $.post('https://esx-phone/ClearGeneralAlerts', JSON.stringify({
                        app: "phone"
                    }));
                } else if (PressedApplication == "mail") {
                    $.post('https://esx-phone/GetMails', JSON.stringify({}), function(mails){
                        Phone.Functions.SetupMails(mails);
                    });
                    $.post('https://esx-phone/ClearGeneralAlerts', JSON.stringify({
                        app: "mail"
                    }));
                } else if (PressedApplication == "advert") {
                    $.post('https://esx-phone/LoadAdverts', JSON.stringify({}), function(Adverts){
                        Phone.Functions.RefreshAdverts(Adverts);
                    })
                } else if (PressedApplication == "garage") {
                    $.post('https://esx-phone/SetupGarageVehicles', JSON.stringify({}), function(Vehicles){
                        SetupGarageVehicles(Vehicles);
                    })
                } else if (PressedApplication == "lawyers") {
                    $.post('https://esx-phone/GetCurrentLawyers', JSON.stringify({}), function(data){
                        SetupLawyers(data);
                    });
                    
                } else if (PressedApplication == "crypto") {
                    $.post('https://esx-phone/GetCryptoData', JSON.stringify({
                        crypto: "Lux Coin",
                    }), function(CryptoData){
                        SetupCryptoData(CryptoData);
                    })
                    $.post('https://esx-phone/GetCryptoTransactions', JSON.stringify({}), function(data){
                        RefreshCryptoTransactions(data);
                    })
                } else if (PressedApplication == "racing") {
                    $.post('https://esx-phone/GetAvailableRaces', JSON.stringify({}), function(Races){
                        SetupRaces(Races);
                    });
                } else if (PressedApplication == "houses") {
                    $.post('https://esx-phone/GetPlayerHouses', JSON.stringify({}), function(Houses){
                        SetupPlayerHouses(Houses);
                    });
                    $.post('https://esx-phone/GetPlayerKeys', JSON.stringify({}), function(Keys){
                        $(".house-app-mykeys-container").html("");
                        if (Keys.length > 0) {
                            $.each(Keys, function(i, key){
                                var elem = '<div class="mykeys-key" id="keyid-'+i+'"><span class="mykeys-key-label">' + key.HouseData.adress + '</span> <span class="mykeys-key-sub">Click to set GPS</span> </div>';
                                $(".house-app-mykeys-container").append(elem);
                                $("#keyid-"+i).data('KeyData', key);
                            });
                        }
                    });
                } else if (PressedApplication == "meos") {
                    SetupMeosHome();
                } else if (PressedApplication == "store") {
                    $.post('https://esx-phone/SetupStoreApps', JSON.stringify({}), function(data){
                        SetupAppstore(data);
                    });
                } else if (PressedApplication == "trucker") {
                    $.post('https://esx-phone/GetTruckerData', JSON.stringify({}), function(data){
                        SetupTruckerInfo(data);
                    });
                }
                else if (PressedApplication == "gallery") {
                    $.post('https://esx-phone/GetGalleryData', JSON.stringify({}), function(data){
                        setUpGalleryData(data);
                    });
                }
                else if (PressedApplication == "camera") {
                    $.post('https://esx-phone/TakePhoto', JSON.stringify({}),function(url){
                        setUpCameraApp(url)
                    })
                    Phone.Functions.Close();
                }

                
            }
        }
    } else {
        if (PressedApplication != null){
            Phone.Notifications.Add("fas fa-exclamation-circle", "System", Phone.Data.Applications[PressedApplication].tooltipText+" is not available!")
        }
    }
});

$(document).on('click', '.mykeys-key', function(e){
    e.preventDefault();

    var KeyData = $(this).data('KeyData');

    $.post('https://esx-phone/SetHouseLocation', JSON.stringify({
        HouseData: KeyData
    }))
});

$(document).on('click', '.phone-home-container', function(event){
    event.preventDefault();

    if (Phone.Data.currentApplication === null) {
        Phone.Functions.Close();
    } else {
        Phone.Animations.TopSlideUp('.phone-application-container', 400, 100);
        Phone.Animations.TopSlideUp('.'+Phone.Data.currentApplication+"-app", 400, 100);
        CanOpenApp = false;
        setTimeout(function(){
            Phone.Functions.ToggleApp(Phone.Data.currentApplication, "none");
            CanOpenApp = true;
        }, 400)
        Phone.Functions.HeaderTextColor("white", 300);

        if (Phone.Data.currentApplication == "messages") {
            if (OpenedChatData.number !== null) {
                setTimeout(function(){
                    $(".messages-chats").css({"display":"block"});
                    $(".messages-chats").animate({
                        left: 0+"vh"
                    }, 1);
                    $(".messages-openedchat").animate({
                        left: -30+"vh"
                    }, 1, function(){
                        $(".messages-openedchat").css({"display":"none"});
                    });
                    OpenedChatPicture = null;
                    OpenedChatData.number = null;
                }, 450);
            }
        } else if (Phone.Data.currentApplication == "bank") {
            if (CurrentTab == "invoices") {
                setTimeout(function(){
                    $(".bank-app-invoices").animate({"left": "30vh"});
                    $(".bank-app-invoices").css({"display":"none"})
                    $(".bank-app-accounts").css({"display":"block"})
                    $(".bank-app-accounts").css({"left": "0vh"});

                    var InvoicesObjectBank = $(".bank-app-header").find('[data-headertype="invoices"]');
                    var HomeObjectBank = $(".bank-app-header").find('[data-headertype="accounts"]');

                    $(InvoicesObjectBank).removeClass('bank-app-header-button-selected');
                    $(HomeObjectBank).addClass('bank-app-header-button-selected');

                    CurrentTab = "accounts";
                }, 400)
            }
        } else if (Phone.Data.currentApplication == "meos") {
            $(".meos-alert-new").remove();
            setTimeout(function(){
                $(".meos-recent-alert").removeClass("noodknop");
                $(".meos-recent-alert").css({"background-color":"#004682"});
            }, 400)
        }

        Phone.Data.currentApplication = null;
    }
});

Phone.Functions.Open = function(data) {
    Phone.Animations.BottomSlideUp('.container', 300, 0);
    Phone.Notifications.LoadTweets(data.Tweets);
    Phone.Data.IsOpen = true;
}

Phone.Functions.ToggleApp = function(app, show) {
    $("."+app+"-app").css({"display":show});
}

Phone.Functions.Close = function() {

    if (Phone.Data.currentApplication == "messages") {
        setTimeout(function(){
            Phone.Animations.TopSlideUp('.phone-application-container', 400, 100);
            Phone.Animations.TopSlideUp('.'+Phone.Data.currentApplication+"-app", 400, 100);
            $(".messages-app").css({"display":"none"});
            Phone.Functions.HeaderTextColor("white", 300);

            if (OpenedChatData.number !== null) {
                setTimeout(function(){
                    $(".messages-chats").css({"display":"block"});
                    $(".messages-chats").animate({
                        left: 0+"vh"
                    }, 1);
                    $(".messages-openedchat").animate({
                        left: -30+"vh"
                    }, 1, function(){
                        $(".messages-openedchat").css({"display":"none"});
                    });
                    OpenedChatData.number = null;
                }, 450);
            }
            OpenedChatPicture = null;
            Phone.Data.currentApplication = null;
        }, 500)
    } else if (Phone.Data.currentApplication == "meos") {
        $(".meos-alert-new").remove();
        $(".meos-recent-alert").removeClass("noodknop");
        $(".meos-recent-alert").css({"background-color":"#004682"});
    }

    Phone.Animations.BottomSlideDown('.container', 300, -70);
    $.post('https://esx-phone/Close');
    Phone.Data.IsOpen = false;
}

Phone.Functions.HeaderTextColor = function(newColor, Timeout) {
    $(".phone-header").animate({color: newColor}, Timeout);
}

Phone.Animations.BottomSlideUp = function(Object, Timeout, Percentage) {
    $(Object).css({'display':'block'}).animate({
        bottom: Percentage+"%",
    }, Timeout);
}

Phone.Animations.BottomSlideDown = function(Object, Timeout, Percentage) {
    $(Object).css({'display':'block'}).animate({
        bottom: Percentage+"%",
    }, Timeout, function(){
        $(Object).css({'display':'none'});
    });
}

Phone.Animations.TopSlideDown = function(Object, Timeout, Percentage) {
    $(Object).css({'display':'block'}).animate({
        top: Percentage+"%",
    }, Timeout);
}

Phone.Animations.TopSlideUp = function(Object, Timeout, Percentage, cb) {
    $(Object).css({'display':'block'}).animate({
        top: Percentage+"%",
    }, Timeout, function(){
        $(Object).css({'display':'none'});
    });
}

Phone.Notifications.Add = function(icon, title, text, color, timeout) {
    $.post('https://esx-phone/HasPhone', JSON.stringify({}), function(HasPhone){
        if (HasPhone) {
            if (timeout == null && timeout == undefined) {
                timeout = 1500;
            }
            if (Phone.Notifications.Timeout == undefined || Phone.Notifications.Timeout == null) {
                if (color != null || color != undefined) {
                    $(".notification-icon").css({"color":color});
                    $(".notification-title").css({"color":color});
                } else if (color == "default" || color == null || color == undefined) {
                    $(".notification-icon").css({"color":"#e74c3c"});
                    $(".notification-title").css({"color":"#e74c3c"});
                }
                if (!Phone.Data.IsOpen) {
                    Phone.Animations.BottomSlideUp('.container', 300, -52);
                }
                Phone.Animations.TopSlideDown(".phone-notification-container", 200, 8);
                if (icon !== "politie") {
                    $(".notification-icon").html('<i class="'+icon+'"></i>');
                } else {
                    $(".notification-icon").html('<img src="./img/politie.png" class="police-icon-notify">');
                }
                $(".notification-title").html(title);
                $(".notification-text").html(text);
                if (Phone.Notifications.Timeout !== undefined || Phone.Notifications.Timeout !== null) {
                    clearTimeout(Phone.Notifications.Timeout);
                }
                Phone.Notifications.Timeout = setTimeout(function(){
                    Phone.Animations.TopSlideUp(".phone-notification-container", 200, -8);
                    if (!Phone.Data.IsOpen) {
                        Phone.Animations.BottomSlideUp('.container', 300, -100);
                    }
                    Phone.Notifications.Timeout = null;
                }, timeout);
            } else {
                if (color != null || color != undefined) {
                    $(".notification-icon").css({"color":color});
                    $(".notification-title").css({"color":color});
                } else {
                    $(".notification-icon").css({"color":"#e74c3c"});
                    $(".notification-title").css({"color":"#e74c3c"});
                }
                if (!Phone.Data.IsOpen) {
                    Phone.Animations.BottomSlideUp('.container', 300, -52);
                }
                $(".notification-icon").html('<i class="'+icon+'"></i>');
                $(".notification-title").html(title);
                $(".notification-text").html(text);
                if (Phone.Notifications.Timeout !== undefined || Phone.Notifications.Timeout !== null) {
                    clearTimeout(Phone.Notifications.Timeout);
                }
                Phone.Notifications.Timeout = setTimeout(function(){
                    Phone.Animations.TopSlideUp(".phone-notification-container", 200, -8);
                    if (!Phone.Data.IsOpen) {
                        Phone.Animations.BottomSlideUp('.container', 300, -100);
                    }
                    Phone.Notifications.Timeout = null;
                }, timeout);
            }
        }
    });
}

Phone.Functions.LoadPhoneData = function(data) {
    Phone.Data.PlayerData = data.PlayerData;
    Phone.Data.PlayerJob = data.PlayerJob;
    Phone.Data.MetaData = data.PhoneData.MetaData;
    Phone.Functions.LoadMetaData(data.PhoneData.MetaData);
    Phone.Functions.LoadContacts(data.PhoneData.Contacts);
    Phone.Functions.SetupApplications(data);

    $("#player-id").html("<span>" + "ID: " + data.PlayerId + "</span>")
}

Phone.Functions.UpdateTime = function(data) {
    var NewDate = new Date();
    var NewHour = NewDate.getHours();
    var NewMinute = NewDate.getMinutes();
    var Minutessss = NewMinute;
    var Hourssssss = NewHour;
    if (NewHour < 10) {
        Hourssssss = "0" + Hourssssss;
    }
    if (NewMinute < 10) {
        Minutessss = "0" + NewMinute;
    }
    var MessageTime = Hourssssss + ":" + Minutessss

    $("#phone-time").html("<span>" + data.InGameTime.hour + ":" + data.InGameTime.minute + "</span>");
}

var NotificationTimeout = null;

QB.Screen.Notification = function(title, content, icon, timeout, color) {
    $.post('https://esx-phone/HasPhone', JSON.stringify({}), function(HasPhone){
        if (HasPhone) {
            if (color != null && color != undefined) {
                $(".screen-notifications-container").css({"background-color":color});
            }
            $(".screen-notification-icon").html('<i class="'+icon+'"></i>');
            $(".screen-notification-title").text(title);
            $(".screen-notification-content").text(content);
            $(".screen-notifications-container").css({'display':'block'}).animate({
                right: 5+"vh",
            }, 200);

            if (NotificationTimeout != null) {
                clearTimeout(NotificationTimeout);
            }

            NotificationTimeout = setTimeout(function(){
                $(".screen-notifications-container").animate({
                    right: -35+"vh",
                }, 200, function(){
                    $(".screen-notifications-container").css({'display':'none'});
                });
                NotificationTimeout = null;
            }, timeout);
        }
    });
}

$(document).on('keydown', function(e) {
    switch(event.keyCode) {
        case 27: // ESCAPE
        if (up){
            $('#popup').fadeOut('slow');
            $('.popupclass').fadeOut('slow');
            $('.popupclass').html("");
            up = false
        } else {
            Phone.Functions.Close();
            break;
        }
    }
});

QB.Screen.popUp = function(source){
    if(!up){
        $('#popup').fadeIn('slow');
        $('.popupclass').fadeIn('slow');
        $('<img  src='+source+' style = "width:100%; height: 100%;">').appendTo('.popupclass')
        up = true
    }
}

QB.Screen.popDown = function(){
    if(up){
        $('#popup').fadeOut('slow');
        $('.popupclass').fadeOut('slow');
        $('.popupclass').html("");
        up = false
    }
}

$(document).ready(function(){
    window.addEventListener('message', function(event) {
        switch(event.data.action) {
            case "open":
                Phone.Functions.Open(event.data);
                Phone.Functions.SetupAppWarnings(event.data.AppData);
                Phone.Functions.SetupCurrentCall(event.data.CallData);
                Phone.Data.IsOpen = true;
                Phone.Data.PlayerData = event.data.PlayerData;
                break;
            case "LoadPhoneData":
                Phone.Functions.LoadPhoneData(event.data);
                break;
            case "UpdateTime":
                Phone.Functions.UpdateTime(event.data);
                break;
            case "Notification":
                QB.Screen.Notification(event.data.NotifyData.title, event.data.NotifyData.content, event.data.NotifyData.icon, event.data.NotifyData.timeout, event.data.NotifyData.color);
                break;
            case "PhoneNotification":
                Phone.Notifications.Add(event.data.PhoneNotify.icon, event.data.PhoneNotify.title, event.data.PhoneNotify.text, event.data.PhoneNotify.color, event.data.PhoneNotify.timeout);
                break;
            case "RefreshAppAlerts":
                Phone.Functions.SetupAppWarnings(event.data.AppData);
                break;
            case "UpdateMentionedTweets":
                Phone.Notifications.LoadMentionedTweets(event.data.Tweets);
                break;
            case "UpdateBank":
                $(".bank-app-account-balance").html("&#36; "+event.data.NewBalance);
                $(".bank-app-account-balance").data('balance', event.data.NewBalance);
                break;
            case "UpdateAccounts":
                Phone.Data.PlayerData.accounts = event.data.accounts
                break;
            case "UpdateChat":
                if (Phone.Data.currentApplication == "messages") {
                    if (OpenedChatData.number !== null && OpenedChatData.number == event.data.chatNumber) {
                        Phone.Functions.SetupChatMessages(event.data.chatData);
                    } else {
                        Phone.Functions.LoadmessagesChats(event.data.Chats);
                    }
                }
                break;
            case "UpdateHashtags":
                Phone.Notifications.LoadHashtags(event.data.Hashtags);
                break;
            case "RefreshmessagesAlerts":
                Phone.Functions.ReloadmessagesAlerts(event.data.Chats);
                break;
            case "CancelOutgoingCall":
                $.post('https://esx-phone/HasPhone', JSON.stringify({}), function(HasPhone){
                    if (HasPhone) {
                        CancelOutgoingCall();
                    }
                });
                break;
            case "IncomingCallAlert":
                $.post('https://esx-phone/HasPhone', JSON.stringify({}), function(HasPhone){
                    if (HasPhone) {
                        IncomingCallAlert(event.data.CallData, event.data.Canceled, event.data.AnonymousCall);
                    }
                });
                break;
            case "SetupHomeCall":
                Phone.Functions.SetupCurrentCall(event.data.CallData);
                break;
            case "AnswerCall":
                Phone.Functions.AnswerCall(event.data.CallData);
                break;
            case "UpdateCallTime":
                var CallTime = event.data.Time;
                var date = new Date(null);
                date.setSeconds(CallTime);
                var timeString = date.toISOString().substr(11, 8);
                if (!Phone.Data.IsOpen) {
                    if ($(".call-notifications").css("right") !== "52.1px") {
                        $(".call-notifications").css({"display":"block"});
                        $(".call-notifications").animate({right: 5+"vh"});
                    }
                    $(".call-notifications-title").html("In conversation ("+timeString+")");
                    $(".call-notifications-content").html("Calling with "+event.data.Name);
                    $(".call-notifications").removeClass('call-notifications-shake');
                } else {
                    $(".call-notifications").animate({
                        right: -35+"vh"
                    }, 400, function(){
                        $(".call-notifications").css({"display":"none"});
                    });
                }
                $(".phone-call-ongoing-time").html(timeString);
                $(".phone-currentcall-title").html("In conversation ("+timeString+")");
                break;
            case "CancelOngoingCall":
                $(".call-notifications").animate({right: -35+"vh"}, function(){
                    $(".call-notifications").css({"display":"none"});
                });
                Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
                setTimeout(function(){
                    Phone.Functions.ToggleApp("phone-call", "none");
                    $(".phone-application-container").css({"display":"none"});
                }, 400)
                Phone.Functions.HeaderTextColor("white", 300);

                Phone.Data.CallActive = false;
                Phone.Data.currentApplication = null;
                break;
            case "RefreshContacts":
                Phone.Functions.LoadContacts(event.data.Contacts);
                break;
            case "UpdateMails":
                Phone.Functions.SetupMails(event.data.Mails);
                break;
            case "RefreshAdverts":
                if (Phone.Data.currentApplication == "advert") {
                    Phone.Functions.RefreshAdverts(event.data.Adverts);
                }
                break;
            case "UpdateTweets":
                if (Phone.Data.currentApplication == "twitter") {
                    Phone.Notifications.LoadTweets(event.data.Tweets);
                }
                break;
            case "AddPoliceAlert":
                AddPoliceAlert(event.data)
                break;
            case "UpdateApplications":
                Phone.Data.PlayerJob = event.data.JobData;
                Phone.Functions.SetupApplications(event.data);
                break;
            case "UpdateTransactions":
                RefreshCryptoTransactions(event.data);
                break;
            case "UpdateRacingApp":
                $.post('https://esx-phone/GetAvailableRaces', JSON.stringify({}), function(Races){
                    SetupRaces(Races);
                });
                break;
            case "RefreshAlerts":
                Phone.Functions.SetupAppWarnings(event.data.AppData);
                break;
        }
    })
});
var ContactSearchActive = false;
var CurrentFooterTab = "contacts";
var CallData = {};
var ClearNumberTimer = null;
var SelectedSuggestion = null;
var AmountOfSuggestions = 0;
var keyPadHTML;

$(document).on('click', '.phone-app-footer-button', function(e){
    e.preventDefault();

    var PressedFooterTab = $(this).data('phonefootertab');

    if (PressedFooterTab !== CurrentFooterTab) {
        var PreviousTab = $(this).parent().find('[data-phonefootertab="'+CurrentFooterTab+'"');

        $('.phone-app-footer').find('[data-phonefootertab="'+CurrentFooterTab+'"').removeClass('phone-selected-footer-tab');
        $(this).addClass('phone-selected-footer-tab');

        $(".phone-"+CurrentFooterTab).hide();
        $(".phone-"+PressedFooterTab).show();

        if (PressedFooterTab == "recent") {
            $.post('https://esx-phone/ClearRecentAlerts');
        } else if (PressedFooterTab == "suggestedcontacts") {
            $.post('https://esx-phone/ClearRecentAlerts');
        }

        CurrentFooterTab = PressedFooterTab;
    }
});

$(document).on("click", "#phone-search-icon", function(e){
    e.preventDefault();

    if (!ContactSearchActive) {
        $("#phone-plus-icon").animate({
            opacity: "0.0",
            "display": "none"
        }, 150, function(){
            $("#contact-search").css({"display":"block"}).animate({
                opacity: "1.0",
            }, 150);
        });
    } else {
        $("#contact-search").animate({
            opacity: "0.0"
        }, 150, function(){
            $("#contact-search").css({"display":"none"});
            $("#phone-plus-icon").animate({
                opacity: "1.0",
                display: "block",
            }, 150);
        });
    }

    ContactSearchActive = !ContactSearchActive;
});

Phone.Functions.SetupRecentCalls = function(recentcalls) {
    $(".phone-recent-calls").html("");

    recentcalls = recentcalls.reverse();

    $.each(recentcalls, function(i, recentCall){
        var FirstLetter = (recentCall.name).charAt(0);
        var TypeIcon = 'fas fa-phone-slash';
        var IconStyle = "color: #e74c3c;";
        if (recentCall.type === "outgoing") {
            TypeIcon = 'fas fa-phone-volume';
            var IconStyle = "color: #2ecc71; font-size: 1.4vh;";
        }
        if (recentCall.anonymous) {
            FirstLetter = "A";
            recentCall.name = "Anonymous";
        }
        var elem = '<div class="phone-recent-call" id="recent-'+i+'"><div class="phone-recent-call-image">'+FirstLetter+'</div> <div class="phone-recent-call-name">'+recentCall.name+'</div> <div class="phone-recent-call-type"><i class="'+TypeIcon+'" style="'+IconStyle+'"></i></div> <div class="phone-recent-call-time">'+recentCall.time+'</div> </div>'

        $(".phone-recent-calls").append(elem);
        $("#recent-"+i).data('recentData', recentCall);
    });
}

$(document).on('click', '.phone-recent-call', function(e){
    e.preventDefault();

    var RecendId = $(this).attr('id');
    var RecentData = $("#"+RecendId).data('recentData');

    cData = {
        number: RecentData.number,
        name: RecentData.name
    }

    $.post('https://esx-phone/CallContact', JSON.stringify({
        ContactData: cData,
        Anonymous: Phone.Data.AnonymousCall,
    }), function(status){
        if (cData.number !== Phone.Data.PlayerData.phone_number) {
            if (status.IsOnline) {
                if (status.CanCall) {
                    if (!status.InCall) {
                        if (Phone.Data.AnonymousCall) {
                            Phone.Notifications.Add("fas fa-phone", "Phone", "You started a anonymous call!");
                        }
                        $(".phone-call-outgoing").css({"display":"block"});
                        $(".phone-call-incoming").css({"display":"none"});
                        $(".phone-call-ongoing").css({"display":"none"});
                        $(".phone-call-outgoing-caller").html(cData.name);
                        Phone.Functions.HeaderTextColor("white", 400);
                        Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
                        setTimeout(function(){
                            $(".phone-app").css({"display":"none"});
                            Phone.Animations.TopSlideDown('.phone-application-container', 400, 0);
                            Phone.Functions.ToggleApp("phone-call", "block");
                        }, 450);

                        CallData.name = cData.name;
                        CallData.number = cData.number;

                        Phone.Data.currentApplication = "phone-call";
                    } else {
                        Phone.Notifications.Add("fas fa-phone", "Phone", "You're already in a call!");
                    }
                } else {
                    Phone.Notifications.Add("fas fa-phone", "Phone", "This person is busy!");
                }
            } else {
                Phone.Notifications.Add("fas fa-phone", "Phone", "This person is not available!");
            }
        } else {
            Phone.Notifications.Add("fas fa-phone", "Phone", "You can't call yourself!");
        }
    });
});

$(document).on('click', ".phone-keypad-key-call", function(e){
    e.preventDefault();

    var InputNum = keyPadHTML;

    cData = {
        number: InputNum,
        name: InputNum,
    }

    $.post('https://esx-phone/CallContact', JSON.stringify({
        ContactData: cData,
        Anonymous: Phone.Data.AnonymousCall,
    }), function(status){
        if (cData.number !== Phone.Data.PlayerData.phone_number) {
            if (status.IsOnline) {
                if (status.CanCall) {
                    if (!status.InCall) {
                        $(".phone-call-outgoing").css({"display":"block"});
                        $(".phone-call-incoming").css({"display":"none"});
                        $(".phone-call-ongoing").css({"display":"none"});
                        $(".phone-call-outgoing-caller").html(cData.name);
                        Phone.Functions.HeaderTextColor("white", 400);
                        Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
                        setTimeout(function(){
                            $(".phone-app").css({"display":"none"});
                            Phone.Animations.TopSlideDown('.phone-application-container', 400, 0);
                            Phone.Functions.ToggleApp("phone-call", "block");
                        }, 450);

                        CallData.name = cData.name;
                        CallData.number = cData.number;

                        Phone.Data.currentApplication = "phone-call";
                    } else {
                        Phone.Notifications.Add("fas fa-phone", "Phone", "You're already in a call!");
                    }
                } else {
                    Phone.Notifications.Add("fas fa-phone", "Phone", "This person is busy!");
                }
            } else {
                Phone.Notifications.Add("fas fa-phone", "Phone", "This person is not available!");
            }
        } else {
            Phone.Notifications.Add("fas fa-phone", "Phone", "You can't call yourself!");
        }
    });
});

Phone.Functions.LoadContacts = function(myContacts) {
    var ContactsObject = $(".phone-contact-list");
    $(ContactsObject).html("");
    var TotalContacts = 0;

    $(".phone-contacts").hide();
    $(".phone-recent").hide();
    $(".phone-keypad").hide();

    $(".phone-"+CurrentFooterTab).show();

    $("#contact-search").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".phone-contact-list .phone-contact").filter(function() {
          $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });

    if (myContacts !== null) {
        $.each(myContacts, function(i, contact){
            contact.name = DOMPurify.sanitize(contact.name , {
                ALLOWED_TAGS: [],
                ALLOWED_ATTR: []
            });
            if (contact.name == '') contact.name = 'Hmm, I shouldn\'t be able to do this...'
            var ContactElement = '<div class="phone-contact" data-contactid="'+i+'"><div class="phone-contact-firstletter" style="background-color: #e74c3c;">'+((contact.name).charAt(0)).toUpperCase()+'</div><div class="phone-contact-name">'+contact.name+'</div><div class="phone-contact-actions"><i class="fas fa-sort-down"></i></div><div class="phone-contact-action-buttons"> <i class="fas fa-phone-volume" id="phone-start-call"></i> <i class="fab fa-whatsapp" id="new-chat-phone" style="font-size: 2.5vh;"></i> <i class="fas fa-user-edit" id="edit-contact"></i> </div></div>'
            if (contact.status) {
                ContactElement = '<div class="phone-contact" data-contactid="'+i+'"><div class="phone-contact-firstletter" style="background-color: #2ecc71;">'+((contact.name).charAt(0)).toUpperCase()+'</div><div class="phone-contact-name">'+contact.name+'</div><div class="phone-contact-actions"><i class="fas fa-sort-down"></i></div><div class="phone-contact-action-buttons"> <i class="fas fa-phone-volume" id="phone-start-call"></i> <i class="fab fa-whatsapp" id="new-chat-phone" style="font-size: 2.5vh;"></i> <i class="fas fa-user-edit" id="edit-contact"></i> </div></div>'
            }
            TotalContacts = TotalContacts + 1
            $(ContactsObject).append(ContactElement);
            $("[data-contactid='"+i+"']").data('contactData', contact);
        });
        $("#total-contacts").text(TotalContacts+ " contacts");
    } else {
        $("#total-contacts").text("0 contacten #SAD");
    }
};

$(document).on('click', '#new-chat-phone', function(e){
    var ContactId = $(this).parent().parent().data('contactid');
    var ContactData = $("[data-contactid='"+ContactId+"']").data('contactData');

    if (ContactData.number !== Phone.Data.PlayerData.phone_number) {
        $.post('https://esx-phone/GetmessagesChats', JSON.stringify({}), function(chats){
            Phone.Functions.LoadmessagesChats(chats);
        });

        $('.phone-application-container').animate({
            top: -160+"%"
        });
        Phone.Functions.HeaderTextColor("white", 400);
        setTimeout(function(){
            $('.phone-application-container').animate({
                top: 0+"%"
            });

            Phone.Functions.ToggleApp("phone", "none");
            Phone.Functions.ToggleApp("messages", "block");
            Phone.Data.currentApplication = "messages";

            $.post('https://esx-phone/GetmessagesChat', JSON.stringify({phone: ContactData.number}), function(chat){
                Phone.Functions.SetupChatMessages(chat, {
                    name: ContactData.name,
                    number: ContactData.number
                });
            });

            $('.messages-openedchat-messages').animate({scrollTop: 9999}, 150);
            $(".messages-openedchat").css({"display":"block"});
            $(".messages-openedchat").css({left: 0+"vh"});
            $(".messages-chats").animate({left: 30+"vh"},100, function(){
                $(".messages-chats").css({"display":"none"});
            });
        }, 400)
    } else {
        Phone.Notifications.Add("fa fa-phone-alt", "Phone", "You can't messages yourself..", "default", 3500);
    }
});

var CurrentEditContactData = {}

$(document).on('click', '#edit-contact', function(e){
    e.preventDefault();
    var ContactId = $(this).parent().parent().data('contactid');
    var ContactData = $("[data-contactid='"+ContactId+"']").data('contactData');

    CurrentEditContactData.name = DOMPurify.sanitize(ContactData.name , {
        ALLOWED_TAGS: [],
        ALLOWED_ATTR: []
    });
    if (CurrentEditContactData.name == '') CurrentEditContactData.name = 'Hmm, I shouldn\'t be able to do this...'
    CurrentEditContactData.number = ContactData.number

    $(".phone-edit-contact-header").text(ContactData.name+" Edit")
    $(".phone-edit-contact-name").val(ContactData.name);
    $(".phone-edit-contact-number").val(ContactData.number);
    if (ContactData.iban != null && ContactData.iban != undefined) {
        $(".phone-edit-contact-iban").val(ContactData.iban);
        CurrentEditContactData.iban = ContactData.iban
    } else {
        $(".phone-edit-contact-iban").val("");
        CurrentEditContactData.iban = "";
    }

    Phone.Animations.TopSlideDown(".phone-edit-contact", 200, 0);
});

$(document).on('click', '#edit-contact-save', function(e){
    e.preventDefault();

    var ContactName = DOMPurify.sanitize($(".phone-edit-contact-name").val() , {
        ALLOWED_TAGS: [],
        ALLOWED_ATTR: []
    });
    if (ContactName == '') ContactName = 'Hmm, I shouldn\'t be able to do this...'
    var ContactNumber = $(".phone-edit-contact-number").val();
    var ContactIban = $(".phone-edit-contact-iban").val();

    if (ContactName != "" && ContactNumber != "") {
        $.post('https://esx-phone/EditContact', JSON.stringify({
            CurrentContactName: ContactName,
            CurrentContactNumber: ContactNumber,
            CurrentContactIban: ContactIban,
            OldContactName: CurrentEditContactData.name,
            OldContactNumber: CurrentEditContactData.number,
            OldContactIban: CurrentEditContactData.iban,
        }), function(PhoneContacts){
            Phone.Functions.LoadContacts(PhoneContacts);
        });
        Phone.Animations.TopSlideUp(".phone-edit-contact", 250, -100);
        setTimeout(function(){
            $(".phone-edit-contact-number").val("");
            $(".phone-edit-contact-name").val("");
        }, 250)
    } else {
        Phone.Notifications.Add("fas fa-exclamation-circle", "Edit Contact", "Fill out all fields!");
    }
});

$(document).on('click', '#edit-contact-delete', function(e){
    e.preventDefault();

    var ContactName = $(".phone-edit-contact-name").val();
    var ContactNumber = $(".phone-edit-contact-number").val();
    var ContactIban = $(".phone-edit-contact-iban").val();

    $.post('https://esx-phone/DeleteContact', JSON.stringify({
        CurrentContactName: ContactName,
        CurrentContactNumber: ContactNumber,
        CurrentContactIban: ContactIban,
    }), function(PhoneContacts){
        Phone.Functions.LoadContacts(PhoneContacts);
    });
    Phone.Animations.TopSlideUp(".phone-edit-contact", 250, -100);
    setTimeout(function(){
        $(".phone-edit-contact-number").val("");
        $(".phone-edit-contact-name").val("");
    }, 250);
});

$(document).on('click', '#edit-contact-cancel', function(e){
    e.preventDefault();

    Phone.Animations.TopSlideUp(".phone-edit-contact", 250, -100);
    setTimeout(function(){
        $(".phone-edit-contact-number").val("");
        $(".phone-edit-contact-name").val("");
    }, 250)
});

$(document).on('click', '.phone-keypad-key', function(e){
    e.preventDefault();
    var PressedButton = $(this).data('keypadvalue');
    if (!isNaN(PressedButton)) {
        keyPadHTML = $("#phone-keypad-input").text();
        $("#phone-keypad-input").text(keyPadHTML + PressedButton)
        keyPadHTML = $("#phone-keypad-input").text();
    } else if (PressedButton == "#") {
        keyPadHTML = $("#phone-keypad-input").text();
        $("#phone-keypad-input").text(keyPadHTML + PressedButton)
        keyPadHTML = $("#phone-keypad-input").text();
    } else if (PressedButton == "*") {
        if (ClearNumberTimer == null) {
            $("#phone-keypad-input").text("Cleared")
            ClearNumberTimer = setTimeout(function(){
                $("#phone-keypad-input").text("");
                keyPadHTML = $("#phone-keypad-input").text();
                ClearNumberTimer = null;
            }, 750);
        }
    }
})

var OpenedContact = null;

$(document).on('click', '.phone-contact-actions', function(e){
    e.preventDefault();

    var FocussedContact = $(this).parent();
    var ContactId = $(FocussedContact).data('contactid');

    if (OpenedContact === null) {
        $(FocussedContact).animate({
            "height":"12vh"
        }, 150, function(){
            $(FocussedContact).find('.phone-contact-action-buttons').fadeIn(100);
        });
        OpenedContact = ContactId;
    } else if (OpenedContact == ContactId) {
        $(FocussedContact).find('.phone-contact-action-buttons').fadeOut(100, function(){
            $(FocussedContact).animate({
                "height":"4.5vh"
            }, 150);
        });
        OpenedContact = null;
    } else if (OpenedContact != ContactId) {
        var PreviousContact = $(".phone-contact-list").find('[data-contactid="'+OpenedContact+'"]');
        $(PreviousContact).find('.phone-contact-action-buttons').fadeOut(100, function(){
            $(PreviousContact).animate({
                "height":"4.5vh"
            }, 150);
            OpenedContact = ContactId;
        });
        $(FocussedContact).animate({
            "height":"12vh"
        }, 150, function(){
            $(FocussedContact).find('.phone-contact-action-buttons').fadeIn(100);
        });
    }
});


$(document).on('click', '#phone-plus-icon', function(e){
    e.preventDefault();

    Phone.Animations.TopSlideDown(".phone-add-contact", 200, 0);
});

$(document).on('click', '#add-contact-save', function(e){
    e.preventDefault();

    var ContactName = DOMPurify.sanitize($(".phone-add-contact-name").val() , {
        ALLOWED_TAGS: [],
        ALLOWED_ATTR: []
    });
    if (ContactName == '') ContactName = 'Hmm, I shouldn\'t be able to do this...'
    var ContactNumber = $(".phone-add-contact-number").val();
    var ContactIban = $(".phone-add-contact-iban").val();

    if (ContactName != "" && ContactNumber != "") {
        $.post('https://esx-phone/AddNewContact', JSON.stringify({
            ContactName: ContactName,
            ContactNumber: ContactNumber,
            ContactIban: ContactIban,
        }), function(PhoneContacts){
            Phone.Functions.LoadContacts(PhoneContacts);
        });
        Phone.Animations.TopSlideUp(".phone-add-contact", 250, -100);
        setTimeout(function(){
            $(".phone-add-contact-number").val("");
            $(".phone-add-contact-name").val("");
        }, 250)

        if (SelectedSuggestion !== null) {
            $.post('https://esx-phone/RemoveSuggestion', JSON.stringify({
                data: $(SelectedSuggestion).data('SuggestionData')
            }));
            $(SelectedSuggestion).remove();
            SelectedSuggestion = null;
            var amount = parseInt(AmountOfSuggestions);
            if ((amount - 1) === 0) {
                amount = 0
            }
            $(".amount-of-suggested-contacts").html(amount + " contacts");
        }
    } else {
        Phone.Notifications.Add("fas fa-exclamation-circle", "Add Contact", "Fill out all fields!");
    }
});

$(document).on('click', '#add-contact-cancel', function(e){
    e.preventDefault();

    Phone.Animations.TopSlideUp(".phone-add-contact", 250, -100);
    setTimeout(function(){
        $(".phone-add-contact-number").val("");
        $(".phone-add-contact-name").val("");
    }, 250)
});

$(document).on('click', '#phone-start-call', function(e){
    e.preventDefault();

    var ContactId = $(this).parent().parent().data('contactid');
    var ContactData = $("[data-contactid='"+ContactId+"']").data('contactData');

    SetupCall(ContactData);
});

SetupCall = function(cData) {
    var retval = false;
    $.post('https://esx-phone/CallContact', JSON.stringify({
        ContactData: cData,
        Anonymous: Phone.Data.AnonymousCall,
    }), function(status){
        if (cData.number !== Phone.Data.PlayerData.phone_number) {
            if (status.IsOnline) {
                if (status.CanCall) {
                    if (!status.InCall) {
                        $(".phone-call-outgoing").css({"display":"block"});
                        $(".phone-call-incoming").css({"display":"none"});
                        $(".phone-call-ongoing").css({"display":"none"});
                        $(".phone-call-outgoing-caller").html(cData.name);
                        Phone.Functions.HeaderTextColor("white", 400);
                        Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
                        setTimeout(function(){
                            $(".phone-app").css({"display":"none"});
                            Phone.Animations.TopSlideDown('.phone-application-container', 400, 0);
                            Phone.Functions.ToggleApp("phone-call", "block");
                        }, 450);

                        CallData.name = cData.name;
                        CallData.number = cData.number;

                        Phone.Data.currentApplication = "phone-call";
                    } else {
                        Phone.Notifications.Add("fas fa-phone", "Phone", "You're already in a call!");
                    }
                } else {
                    Phone.Notifications.Add("fas fa-phone", "Phone", "This person is in a call!");
                }
            } else {
                Phone.Notifications.Add("fas fa-phone", "Phone", "This person is not available!");
            }
        } else {
            Phone.Notifications.Add("fas fa-phone", "Phone", "You can't call your own number!");
        }
    });
}

CancelOutgoingCall = function() {
    if (Phone.Data.currentApplication == "phone-call") {
        Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
        Phone.Animations.TopSlideUp('.'+Phone.Data.currentApplication+"-app", 400, -160);
        setTimeout(function(){
            Phone.Functions.ToggleApp(Phone.Data.currentApplication, "none");
        }, 400)
        Phone.Functions.HeaderTextColor("white", 300);

        Phone.Data.CallActive = false;
        Phone.Data.currentApplication = null;
    }
}

$(document).on('click', '#outgoing-cancel', function(e){
    e.preventDefault();

    $.post('https://esx-phone/CancelOutgoingCall');
});

$(document).on('click', '#incoming-deny', function(e){
    e.preventDefault();

    $.post('https://esx-phone/DenyIncomingCall');
});

$(document).on('click', '#ongoing-cancel', function(e){
    e.preventDefault();

    $.post('https://esx-phone/CancelOngoingCall');
});

IncomingCallAlert = function(CallData, Canceled, AnonymousCall) {
    if (!Canceled) {
        if (!Phone.Data.CallActive) {
            Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
            Phone.Animations.TopSlideUp('.'+Phone.Data.currentApplication+"-app", 400, -160);
            setTimeout(function(){
                var Label = "You have an incoming call from "+CallData.name
                if (AnonymousCall) {
                    Label = "You're being called by a anonymous person"
                }
                $(".call-notifications-title").html("Incoming Call");
                $(".call-notifications-content").html(Label);
                $(".call-notifications").css({"display":"block"});
                $(".call-notifications").animate({
                    right: 5+"vh"
                }, 400);
                $(".phone-call-outgoing").css({"display":"none"});
                $(".phone-call-incoming").css({"display":"block"});
                $(".phone-call-ongoing").css({"display":"none"});
                $(".phone-call-incoming-caller").html(CallData.name);
                $(".phone-app").css({"display":"none"});
                Phone.Functions.HeaderTextColor("white", 400);
                $("."+Phone.Data.currentApplication+"-app").css({"display":"none"});
                $(".phone-call-app").css({"display":"block"});
                setTimeout(function(){
                    Phone.Animations.TopSlideDown('.phone-application-container', 400, 0);
                }, 400);
            }, 400);

            Phone.Data.currentApplication = "phone-call";
            Phone.Data.CallActive = true;
        }
        setTimeout(function(){
            $(".call-notifications").addClass('call-notifications-shake');
            setTimeout(function(){
                $(".call-notifications").removeClass('call-notifications-shake');
            }, 1000);
        }, 400);
    } else {
        $(".call-notifications").animate({
            right: -35+"vh"
        }, 400);
        Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
        Phone.Animations.TopSlideUp('.'+Phone.Data.currentApplication+"-app", 400, -160);
        setTimeout(function(){
            $("."+Phone.Data.currentApplication+"-app").css({"display":"none"});
            $(".phone-call-outgoing").css({"display":"none"});
            $(".phone-call-incoming").css({"display":"none"});
            $(".phone-call-ongoing").css({"display":"none"});
            $(".call-notifications").css({"display":"block"});
        }, 400)
        Phone.Functions.HeaderTextColor("white", 300);
        Phone.Data.CallActive = false;
        Phone.Data.currentApplication = null;
    }
}

// IncomingCallAlert = function(CallData, Canceled) {
//     if (!Canceled) {
//         if (!Phone.Data.CallActive) {
//             $(".call-notifications-title").html("Inkomende Oproep");
//             $(".call-notifications-content").html("Je hebt een inkomende oproep van "+CallData.name);
//             $(".call-notifications").css({"display":"block"});
//             $(".call-notifications").animate({
//                 right: 5+"vh"
//             }, 400);
//             $(".phone-call-outgoing").css({"display":"none"});
//             $(".phone-call-incoming").css({"display":"block"});
//             $(".phone-call-ongoing").css({"display":"none"});
//             $(".phone-call-incoming-caller").html(CallData.name);
//             $(".phone-app").css({"display":"none"});
//             Phone.Functions.HeaderTextColor("white", 400);
//             Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
//             $(".phone-call-app").css({"display":"block"});
//             setTimeout(function(){
//                 Phone.Animations.TopSlideDown('.phone-application-container', 400, 0);
//             }, 450);

//             Phone.Data.currentApplication = "phone-call";
//             Phone.Data.CallActive = true;
//         }
//         setTimeout(function(){
//             $(".call-notifications").addClass('call-notifications-shake');
//             setTimeout(function(){
//                 $(".call-notifications").removeClass('call-notifications-shake');
//             }, 1000);
//         }, 400);
//     } else {
//         $(".call-notifications").animate({
//             right: -35+"vh"
//         }, 400);
//         Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
//         Phone.Animations.TopSlideUp('.'+Phone.Data.currentApplication+"-app", 400, -160);
//         setTimeout(function(){
//             Phone.Functions.ToggleApp(Phone.Data.currentApplication, "none");
//             $(".phone-call-outgoing").css({"display":"none"});
//             $(".phone-call-incoming").css({"display":"none"});
//             $(".phone-call-ongoing").css({"display":"none"});
//             $(".call-notifications").css({"display":"block"});
//         }, 400)
//         Phone.Functions.HeaderTextColor("white", 300);

//         Phone.Data.CallActive = false;
//         Phone.Data.currentApplication = null;
//     }
// }

Phone.Functions.SetupCurrentCall = function(cData) {
    if (cData.InCall) {
        CallData = cData;
        $(".phone-currentcall-container").css({"display":"block"});

        if (cData.CallType == "incoming") {
            $(".phone-currentcall-title").html("Incoming call");
        } else if (cData.CallType == "outgoing") {
            $(".phone-currentcall-title").html("Outgoing call");
        } else if (cData.CallType == "ongoing") {
            $(".phone-currentcall-title").html("In call ("+cData.CallTime+")");
        }

        $(".phone-currentcall-contact").html(cData.TargetData.name);
    } else {
        $(".phone-currentcall-container").css({"display":"none"});
    }
}

$(document).on('click', '.phone-currentcall-container', function(e){
    e.preventDefault();

    if (CallData.CallType == "incoming") {
        $(".phone-call-incoming").css({"display":"block"});
        $(".phone-call-outgoing").css({"display":"none"});
        $(".phone-call-ongoing").css({"display":"none"});
    } else if (CallData.CallType == "outgoing") {
        $(".phone-call-incoming").css({"display":"none"});
        $(".phone-call-outgoing").css({"display":"block"});
        $(".phone-call-ongoing").css({"display":"none"});
    } else if (CallData.CallType == "ongoing") {
        $(".phone-call-incoming").css({"display":"none"});
        $(".phone-call-outgoing").css({"display":"none"});
        $(".phone-call-ongoing").css({"display":"block"});
    }
    $(".phone-call-ongoing-caller").html(CallData.name);

    Phone.Functions.HeaderTextColor("white", 500);
    Phone.Animations.TopSlideDown('.phone-application-container', 500, 0);
    Phone.Animations.TopSlideDown('.phone-call-app', 500, 0);
    Phone.Functions.ToggleApp("phone-call", "block");

    Phone.Data.currentApplication = "phone-call";
});

$(document).on('click', '#incoming-answer', function(e){
    e.preventDefault();

    $.post('https://esx-phone/AnswerCall');
});

Phone.Functions.AnswerCall = function(CallData) {
    $(".phone-call-incoming").css({"display":"none"});
    $(".phone-call-outgoing").css({"display":"none"});
    $(".phone-call-ongoing").css({"display":"block"});
    $(".phone-call-ongoing-caller").html(CallData.TargetData.name);

    Phone.Functions.Close();
}

Phone.Functions.SetupSuggestedContacts = function(Suggested) {
    $(".suggested-contacts").html("");
    AmountOfSuggestions = Suggested.length;
    if (AmountOfSuggestions > 0) {
        $(".amount-of-suggested-contacts").html(AmountOfSuggestions + " contacts");
        Suggested = Suggested.reverse();
        $.each(Suggested, function(index, suggest){
            var elem = '<div class="suggested-contact" id="suggest-'+index+'"> <i class="fas fa-exclamation-circle"></i> <span class="suggested-name">'+suggest.name +' &middot; <span class="suggested-number">'+suggest.number+'</span></span> </div>';
            $(".suggested-contacts").append(elem);
            $("#suggest-"+index).data('SuggestionData', suggest);
        });
    } else {
        $(".amount-of-suggested-contacts").html("0 contacts");
    }
}

$(document).on('click', '.suggested-contact', function(e){
    e.preventDefault();

    var SuggestionData = $(this).data('SuggestionData');
    SelectedSuggestion = this;

    Phone.Animations.TopSlideDown(".phone-add-contact", 200, 0);

    $(".phone-add-contact-name").val(SuggestionData.name);
    $(".phone-add-contact-number").val(SuggestionData.number);
    $(".phone-add-contact-iban").val(SuggestionData.bank);
});
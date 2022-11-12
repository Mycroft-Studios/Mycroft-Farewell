let veh

$(document).on('click', '.garage-vehicle', function(e){
    e.preventDefault();

    $(".garage-homescreen").animate({
        left: 30+"vh"
    }, 200);
    $(".garage-detailscreen").animate({
        left: 0+"vh"
    }, 200);

    var Id = $(this).attr('id');
    var VehData = $("#"+Id).data('VehicleData');
    veh = VehData
    SetupDetails(VehData);
});

$(document).on('click', '#track-vehicle', function(e){
    e.preventDefault()
    $.post("https://esx-phone/track-vehicle", JSON.stringify({
        veh: veh,
    }));
});


$(document).on('click', '#return-button', function(e){
    e.preventDefault();

    $(".garage-homescreen").animate({
        left: 00+"vh"
    }, 200);
    $(".garage-detailscreen").animate({
        left: -30+"vh"
    }, 200);
});

SetupGarageVehicles = function(Vehicles) {
    $(".garage-vehicles").html("");
    if (Vehicles != null) {
        $.each(Vehicles, function(i, vehicle){
            var Element = '<div class="garage-vehicle" id="vehicle-'+i+'"><span class="garage-vehicle-name">'+vehicle.name + ' | ' + vehicle.plate + '</span> </div>';

            $(".garage-vehicles").append(Element);
            $("#vehicle-"+i).data('VehicleData', vehicle);
        });
    }
}

SetupDetails = function(data) {
    $(".vehicle-brand").find(".vehicle-answer").html(data.brand);
    $(".vehicle-model").find(".vehicle-answer").html(data.name);
    $(".vehicle-plate").find(".vehicle-answer").html(data.plate);
    $(".vehicle-garage").find(".vehicle-answer").html(data.garage);
    $(".vehicle-status").find(".vehicle-answer").html(data.status);
    if (data.stored === true) {
        $(".vehicle-engine").show();
        $(".vehicle-body").show();
        $(".vehicle-engine").find(".vehicle-answer").html(Math.ceil(data.engine / 10)+"%");
        $(".vehicle-body").find(".vehicle-answer").html(Math.ceil(data.body / 10)+"%");
    } else {
        $(".vehicle-engine").hide();
        $(".vehicle-body").hide();
    };
}
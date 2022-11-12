Config = Config or {}
Config.BillingCommissions = { -- This is a percentage (0.10) == 10%
    mechanic = 0.10
}


Config.TwitterLog = "https://discord.com/api/webhooks/975080849571709018/RA3L4uTZI5fNJm_s8bbaJyOSvFYh0hrs8FhbbqKRDPNRVuPH0t0A5acTzxFcrMvfOYqg"
Config.AdsLog = "https://discord.com/api/webhooks/983835517319802931/M-_c0nltVlUwW45rDW1SXH3RDCeoukJXTMzoZE30LE5NbracMWOJkgx_C7AvdYpv23EY"
Config.Linux = false -- True if linux
Config.TweetDuration = 12 -- How many hours to load tweets (12 will load the past 12 hours of tweets)
Config.RepeatTimeout = 2000
Config.CallRepeats = 10
Config.OpenPhone = 244
Config.PhoneApplications = {
    ["phone"] = {
        app = "phone",
        color = "#32A840",
        icon = "fa fa-phone-alt",
        tooltipText = "Phone",
        tooltipPos = "top",
        job = false,
        blockedjobs = {},
        slot = 1,
        Alerts = 0,
    },
    ["messages"] = {
        app = "messages",
        color = "#141414",
        icon = "fas fa-comment",
        tooltipText = "Messages",
        tooltipPos = "top",
        style = "font-size: 2.8vh";
        job = false,
        blockedjobs = {},
        slot = 2,
        Alerts = 0,
    },
    ["settings"] = {
        app = "settings",
        color = "#A0A0A0",
        icon = "fa fa-cogs",
        tooltipText = "Settings",
        tooltipPos = "top",
        style = "padding-right: .08vh; font-size: 2.3vh";
        job = false,
        blockedjobs = {},
        slot = 4,
        Alerts = 0,
    },
        ["messages"] = {
        app = "messages",
        color = "#42E85F",
        icon = "fab fa-whatsapp",
        tooltipText = "WhatsApp",
        tooltipPos = "top",
        style = "font-size: 2.8vh";
        job = false,
        blockedjobs = {},
        slot = 2,
        Alerts = 0,
    },
    ["twitter"] = {
        app = "twitter",
        color = "#1DA1F2",
        icon = "fab fa-twitter",
        tooltipText = "Twitter",
        tooltipPos = "top",
        job = false,
        blockedjobs = {},
        slot = 3,
        Alerts = 0,
    },
    ["garage"] = {
        app = "garage",
        color = "#4F54B8",
        icon = "fas fa-car",
        tooltipText = "Vehicles",
        job = false,
        blockedjobs = {},
        slot = 7,
        Alerts = 0,
    },
    ["mail"] = {
        app = "mail",
        color = "#1B64AD",
        icon = "fas fa-envelope-open-text",
        tooltipText = "Mail",
        job = false,
        blockedjobs = {},
        slot = 5,
        Alerts = 0,
    },
    ["advert"] = {
        app = "advert",
        color = "#E2C000",
        icon = "fas fa-bullhorn",
        tooltipText = "Advertisements",
        job = false,
        blockedjobs = {},
        slot = 12,
        Alerts = 0,
    },

    ["lawyers"] = {
        app = "lawyers",
        color = "#E6012A",
        icon = "fas fa-briefcase",
        tooltipText = "Services",
        tooltipPos = "bottom",
        job = false,
        blockedjobs = {},
        slot = 11,
        Alerts = 0,
    },
    ["gallery"] = {
        app = "gallery",
        color = "#9C1C29",
        icon = "fas fa-images",
        tooltipText = "Gallery",
        tooltipPos = "bottom",
        job = false,
        blockedjobs = {},
        slot = 8,
        Alerts = 0,
    },
    ["camera"] = {
        app = "camera",
        color = "#979EAE",
        icon = "fas fa-camera",
        tooltipText = "Camera",
        tooltipPos = "bottom",
        job = false,
        blockedjobs = {},
        slot = 9,
        Alerts = 0,
    },
    ["crypto"] = {
        app = "crypto",
        color = "#D5A020",
        icon = "fas fa-coins",
        tooltipText = "Crypto",
        job = false,
        blockedjobs = {},
        slot =10,
        Alerts = 0,
    },
    ["racing"] = {
        app = "racing",
        color = "#565656",
        icon = "fas fa-flag-checkered",
        tooltipText = "Racing",
        job = false,
        blockedjobs = {},
        slot = 13,
        Alerts = 0,
    },
    ["bank"] = {
        app = "bank",
        color = "#27903A",
        icon = "fa fa-university",
        tooltipText = "Bank",
        job = false,
        blockedjobs = {},
        slot = 6,
        Alerts = 0,
    },
    ["calculator"] = {
        app = "calculator",
        color = "#27903A",
        icon = "far fa-calculator",
        tooltipText = "calculator",
        job = false,
        blockedjobs = {},
        slot = 14,
        Alerts = 0,
    },
}
Config.MaxSlots = 20

Config.StoreApps = {
    ["territory"] = {
        app = "territory",
        color = "#353b48",
        icon = "fas fa-globe-europe",
        tooltipText = "Territorium",
        tooltipPos = "right",
        style = "";
        job = false,
        blockedjobs = {},
        slot = 15,
        Alerts = 0,
        password = true,
        creator = "QBCore",
        title = "Territory",
    },
}

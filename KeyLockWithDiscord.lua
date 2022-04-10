--webhookLink is everything after discord.com, with the "/", e.g. "/api/webhooks/..."
--numOfKeys is the number of keys you want to set
--minKey is the lowest the key can go in math.random. Can't be lower than signed 32-bit integer limit.
--maxKey is the highest the key can go in math.random. Can't be higher than signed 32-bit integer limit.
--if enableNotifs is on, it shows useful notifications.
util.keep_running()

Keys = {} --empty table for our keys

function KeyLockWithDiscord(webhookLink, numOfKeys, minKey, maxKey, enableNotifs)
    for i = 1, numOfKeys do
        Keys[i] = math.random(minKey, maxKey)
        if enableNotifs then
            util.toast(i .. " keys set!")
        end
        async_http.init("discord.com", webhookLink, function () end)
        async_http.set_post("application/json", "{" .. "\"content\":\"" .. tostring(Keys[i]) .. "\", \"username\":\"" .. "Key " .. i .. " of " .. tostring(numOfKeys) .. "\", \"avatar_url\":\"https://cdn.e-z.host/e-zimagehosting/63fc79dc-61b2-4349-ae2d-74a21c918a80/05f17430.jpg\"}")
        async_http.dispatch()
        util.yield(100)
    end
end

--lets say you want to implement this into your script.
local secret = menu.list(menu.my_root(), "Locked", {}, "") --this is the list that your keys, and keyCheck will go into.

--set up our global variables table, they will be assigned the SLIDER values
KeyAnswers = {}
SETUPSLIDERS = false --this is a check if we set up the sliders or not; we don't want to make multiple sliders!

local function setUpSliders() --set up our sliders here
    if not SETUPSLIDERS then
        for i = 1, #Keys do --so for every key, it sets up a slider for said key.
            menu.slider(secret, "Key " .. i, {"key" .. i}, "", -2147483647, 2147483647, 0, 1, function (value)
                KeyAnswers[i] = value
            end)
        end
        SETUPSLIDERS = true
    else
        util.toast("Sliders already set up!")
    end
end


function CheckSecretFeatures()
    for i = 1, #Keys do
        if Keys[i] ~= KeyAnswers[i] then
            return false
        end
    end
    return true
end

CONFIRMED = false
local function checkKeysGen()
    menu.action(secret, "Check keys", {}, "", function ()
        local check = CheckSecretFeatures()
        if check then
            util.toast("confirmed")
            CONFIRMED = true
            SetUpFeatures()
        else
            util.toast('false')
            CONFIRMED = false
        end
    end)
end

Already_set_up = false
function SetUpFeatures()
    if CONFIRMED then --check for confirmed
        if not Already_set_up then
            Already_set_up = true --we make this true, so that we don't generate feautres again
            --now do your functions here
            menu.action(secret, "Hello there!", {}, "", function ()
                util.toast("completed!")
            end)
        else
            util.toast("Already set up!")
        end
    end
end

menu.action(secret, "Send Webhook", {}, "", function ()
    KeyLockWithDiscord("/api/webhooks/<insert webhook here>", 2, -1000, 1000, false) --what this will do is send the webhook to the discord.
    util.yield(1000) --waits a second for the webhook to send
    setUpSliders() --set up the sliders after the webhook has been sent
    checkKeysGen() --set up the "check keys" button, so that they can't run it before, since it returns true if sliders are not present.
end)
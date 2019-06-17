local snd = require('playsound')

o = obslua
ALERT_INTERVAL = 0
IS_ALERTING = false

PROP_ALERT_AUDIO_FILEPATH = script_path() .. "defaultalert.wav"

function script_description()
	return "Alerts user in chosen interval if they are not recording."
end

function script_load(s)
    ALERT_INTERVAL = o.obs_data_get_int(s, "alert_interval") * 1000
    o.obs_frontend_add_event_callback(obs_frontend_callback)
    update_alert()
end

function script_unload()
    
end

function obs_frontend_callback(event, private_data)
    if event == o.OBS_FRONTEND_EVENT_RECORDING_STARTED or event == o.OBS_FRONTEND_EVENT_RECORDING_STOPPED then
        update_alert()
    end
end

function timer_callback()
    snd.playsound(PROP_ALERT_AUDIO_FILEPATH)
end

function script_properties()
    local AUDIO_FILTER = "WAV files (*.wav)"

    local p = o.obs_properties_create()

    o.obs_properties_add_int(p, "alert_interval", "Alert interval (seconds)", 1, 100000, 1)

    o.obs_properties_add_path(p, "alert_audio", "Alert sound",
        o.OBS_PATH_FILE,
        AUDIO_FILTER,
        nil
    )

    return p
end

function script_defaults(s)
    o.obs_data_set_default_int(s, "alert_interval", 10)
    o.obs_data_set_default_string(s, "alert_audio", PROP_ALERT_AUDIO_FILEPATH)
end

function script_update(s)
    ALERT_INTERVAL = o.obs_data_get_int(s, "alert_interval") * 1000
    PROP_ALERT_AUDIO_FILEPATH = o.obs_data_get_string(s, "alert_audio")
    update_alert()
end

function update_alert()
    if IS_ALERTING then
        o.timer_remove(timer_callback)
    end

    if not o.obs_frontend_recording_active() then
        IS_ALERTING = true
        o.timer_add(timer_callback, ALERT_INTERVAL)
    else
        IS_ALERTING = false
    end
end
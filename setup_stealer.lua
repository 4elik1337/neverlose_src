events['level_init']:set(function()
    utils.console_exec('sm_10man')
end)

events['player_say']:set(function(e)
    local victim = entity.get(e.userid, true)
    local msg = e.text

    if msg:find('forceend') or msg:find('.fe') or msg:find('!fe') then
        utils.console_exec('sm_10man')
    end
end)

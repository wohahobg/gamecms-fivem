GameCMS = GameCMS or {}


function GameCMS.GetPlayerId(id)
    for _, playerId in ipairs(GetPlayers()) do
        for _, value in pairs(GetPlayerIdentifiers(playerId)) do
            if value == id then
                return playerId
            end
        end
    end

    return nil
end

CreateThread(function()
    local time = (1 * 60 * 1000)
    while true do
        GameCMS.Fetcher:run();
        if Config.DebugMessages then
            print("[GameCMS.ORG] Fetcher triggered!")
        end
        Wait(time)
    end
end)

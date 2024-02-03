local fetcher = {}
local httpClient = {}

function fetcher:run()
    local result = promise.new()

    httpClient:request('GET', 'commands/queue/fivem', {}, Config.ServerApiKey)
        :next(function(response)
            return fetcher:dispatchCommands(response)
        end)
        :next(function(dispatchCommands)
            result:resolve(dispatchCommands)
        end, function(code)
            if Config.DebugMessages then
                print("[GameCMS.ORG] " .. code.message)
            end
        end)
    return result
end

function fetcher:dispatchCommands(response)
    if not response.data then
        return
    end
    local dispatchCommands = promise.new()
    local total = 0
    local completedCommands = {};
    for _, commandData in pairs(response.data) do
      
        local needsPlayer = false
        for _, command in pairs(commandData.commands) do
            if command:find("license") then
                needsPlayer = true
                break
            end
        end

        local playerId = nil
        if needsPlayer then
            playerId = GameCMS.GetPlayerId('license:' .. commandData.license)
        end

        if not needsPlayer or playerId then
            for _, command in pairs(commandData.commands) do
                local playerCommand = command
                if needsPlayer then
                    playerCommand = command:gsub("%%license%%", playerId)
                end
                ExecuteCommand(playerCommand)
            end
            table.insert(completedCommands, commandData.id)
            total = total + 1
        else
            if Config.DebugMessages then
                 local username = commandData.username or "unknown";
                 local message = "[GameCMS.ORG] Player %s is offline skipped.";
                 print(string.format(message,username));
            end
        end
    end


    if total > 0 then
        httpClient:request('POST', 'commands/complete', {
            ids = json.encode(completedCommands)
        }, Config.ServerApiKey):next(function(response)
            dispatchCommands:resolve(response)
        end, function(code)
            dispatchCommands:reject(code)
        end)

        if Config.DebugMessages then
            local message = "[GameCMS.ORG] Fetched %d command(s).";
            print(string.format(message, total));
        end
    end

    return dispatchCommands
end

function httpClient:request(requestMethod, endpoint, data, key)
    local result = promise.new()
    local url = "https://api.gamecms.org/v2/" .. endpoint
    local headers = {
        ['Authorization'] = 'Bearer ' .. key,
        ['Accept'] = 'application/json',
        ['Content-Type'] = 'application/x-www-form-urlencoded',
    }

    local postData = ''
    if requestMethod == 'POST' then
        for k, v in pairs(data) do
            postData = postData .. "&" .. k .. "=" .. urlencode(v)
        end
        postData = postData.sub(postData, 2)
    end

    PerformHttpRequest(url, function(code, body, headers, errorData)
        if code == 200 then
            result:resolve(body and json.decode(body) or {})
        else
            local message = "An unknown error occurred"
            if errorData then
                local jsonStart = errorData:find("{")
                if jsonStart then
                    local jsonString = errorData:sub(jsonStart)
                    local errorObj = json.decode(jsonString)
                    if errorObj and errorObj.message then
                        message = errorObj.message
                    end
                end
            end
            result:reject({ code = code, message = message })
        end
    end, requestMethod, postData, headers)

    return result
end

function urlencode(str)
    if (str) then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w ])",
            function(c) return string.format("%%%02X", string.byte(c)) end)
        str = string.gsub(str, " ", "+")
    end
    return str
end

GameCMS.Fetcher = fetcher
GameCMS.HttpClient = httpClient

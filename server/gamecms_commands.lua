RegisterCommand("gcmsverify", function(source, args, rawCommand)
    if source > 0 then
        local code = args[1]

        if not code then
            TriggerClientEvent("chat:addMessage", source, {
                color = { 255, 255, 255 },
                args = { "[GameCMS.ORG]", "Please provide a code from the website." }
            })
            return
        end

        local license = GetPlayerIdentifierByType(source, 'license')

        GameCMS.HttpClient:request('POST', 'websites/user/verify/fivem', {
            token = code,
            license = license
        }, Config.WebsiteApiKey):next(function(response)
            TriggerClientEvent("chat:addMessage", source, {
                color = { 0, 255, 0 },
                args = { "[GameCMS.ORG]", "Verification successful!" }
            })
        end, function(error)
            local errorMessage = error.message
            TriggerClientEvent("chat:addMessage", source, {
                color = { 255, 0, 0 },
                args = { "[GameCMS.ORG]", errorMessage }
            })
        end)
    end
end, false)

RegisterCommand("gcmsforce", function(source, args, rawCommand)
    if source > 0 then
        TriggerClientEvent("chat:addMessage", source, {
            color = { 255, 0 },
            args = { "[GameCMS.ORG]", "This command can be run only from the console!" }
        })
    else
        GameCMS.Fetcher:run();
    end
end, false)

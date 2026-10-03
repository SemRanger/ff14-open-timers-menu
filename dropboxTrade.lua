--[[

for yona
read from file the info needed to trade to alts
check if theres an available character near you in a while loop and wait 1 second between each check
if you find an available character around you that is also on the list to trade, then 1) focus target said character and 2) start trading
write to a variable that said character has been traded with
trade to next character on the list that is not on the list of already traded characters








for alt characters
log into the character in the order that autoretainer has it
make sure that said character is inside the house, otherwise move character to house
use a while loop to check if Yona is around
if you find Yona, then wait till Yona clicks you (the alt) and trades you the items
go back to your home world
wait a random amount from 1 second up to 1 min (cuz so many alts from 1 same world botting to GC would look so obvious, or do this part manually to avoid problems)
go to GC and trade the item
log into the next character on autoretainer list
repeat from start

]]

function FindMainCharacterOfThisAccount()
    local characterList = IPC.AutoRetainer.GetRegisteredCharacters()
    local mainCharactersList = {
        "Iroha Tsuneko@Gilgamesh",
        "Yona Flecher@Seraph",
        "Flamme Megu@Gilgamesh",
        "Maeva Bellona@Gilgamesh",
        "Eleanor Tsuneko@Gilgamesh",
        "Faelar Lumin@Seraph",
        "Rinoa Angelheart@Seraph",
        "Kaida Homura@Seraph",
        "Claire Sama@Cuchulainn",
        "Valentina Roxy@Cuchulainn"
    }
    local mainCharOfThisAccount = "" -- Track added names to prevent duplicate entries per character

    for index = 0, characterList.Count - 1 do
        local CID = characterList[index]
        local characterInfo = IPC.AutoRetainer.GetOfflineCharacterData(CID)

        if characterInfo and characterInfo.Name then
            local name = characterInfo.Name
            local world = characterInfo.World
            local fullName = name .. "@" .. world

            for mainCharIndex, value in ipairs(mainCharactersList) do
                if fullName == mainCharactersList[mainCharIndex] then
                    print(fullName .. " has been found on this account. ")
                    return fullName
                end
            end
        end
    end
end

function GetCharacterInfoToTradeOn(worldToReadFileFrom)
    local pathFile_CharactersToTradeOnYonaPlot =
    "C:/Users/ecosm/AppData/Roaming/XIVLauncher2/pluginConfigs/GatherbuddyReborn/charactersToMoveToYonaHouse.txt"
    local pathFile_CharactersToTradeOnEleanorPlot =
    "C:/Users/ecosm/AppData/Roaming/XIVLauncher2/pluginConfigs/GatherbuddyReborn/charactersToMoveToEleanorHouse.txt"

    local quantityList = {}

    local idItem = {}

    local itemNameList = {}

    local nameList = {}
    local currentWorld = Excel.GetRow("World", Player.Entity.CurrentWorld).Name


    if worldToReadFileFrom == "Seraph" then
        print("Getting list of characters to trade on Seraph")
        local openfile_CharactersToTradeOnHousePlot = io.open(pathFile_CharactersToTradeOnYonaPlot, "r")
        if openfile_CharactersToTradeOnHousePlot then
            for line in openfile_CharactersToTradeOnHousePlot:lines() do
                --TODO consider if you wanna keep worldTotradeon around, as i only write it once to check which file to write to
                local id_item, quantity, itemName, name, worldToTradeOn = string.match(line,
                    "([^,]+),%s*([^,]+),%s*([^,]+),%s([^,]+),%s([^,]+)")
                --print(id_item, quantity, itemName, name, worldToTradeOn)
                table.insert(quantityList, quantity)
                table.insert(idItem, id_item)
                table.insert(itemNameList, itemName)
                table.insert(nameList, name)
            end
            openfile_CharactersToTradeOnHousePlot:close()
            return idItem, quantityList, itemNameList, nameList
        end
    elseif worldToReadFileFrom == "Bismarck" then
        print("Getting list of characters to trade on Bismarck")
        local openfile_CharactersToTradeOnHousePlot = io.open(pathFile_CharactersToTradeOnEleanorPlot, "r")
        if openfile_CharactersToTradeOnHousePlot then
            for line in openfile_CharactersToTradeOnHousePlot:lines() do
                local id_item, quantity, itemName, name, worldToTradeOn = string.match(line,
                    "([^,]+),%s*([^,]+),%s*([^,]+),%s([^,]+),%s([^,]+)")
                --print(id_item, quantity, itemName, name, worldToTradeOn)
                table.insert(quantityList, quantity)
                table.insert(idItem, id_item)
                table.insert(itemNameList, itemName)
                table.insert(nameList, name)
            end
            openfile_CharactersToTradeOnHousePlot:close()
            return idItem, quantityList, itemNameList, nameList
        end
    else
        print(currentWorld ..
        " is not a valid world to check against the files to open. Worlds to check are Seraph and Bismarck.")
    end
end

function IsCharacterAbleToEnterYonaHouse(world)
    --local world = GetWorldFromAutoRetainerOfflineData()
    print("Home world: " .. world .. ", Visit cross dc to world 'Seraph': " .. tostring(IPC.Lifestream.CanVisitCrossDC("Seraph")) .. ", Visit same dc to world 'Seraph': " .. tostring(IPC.Lifestream.CanVisitSameDC("Seraph")))
    if IPC.Lifestream.CanVisitCrossDC("Seraph") == true then
        print("Character can cross dc travel from " .. world .. " to Seraph for trade.")
        return true
    elseif IPC.Lifestream.CanVisitSameDC("Seraph") == true then
        print("Character can same dc world travel from " .. world .. " to Seraph for trade.")
        return true
    else
        print("Character CANNOT travel to Seraph for trade.")
        return false
    end
end

function GetWorldFromAutoRetainerOfflineData()
    local characterList = IPC.AutoRetainer.GetRegisteredCharacters()
    local charactersToFarm = {}
    local addedCharacters = {} -- Track added names to prevent duplicate entries per character

    for index = 0, characterList.Count - 1 do
        local CID = characterList[index]
        local character = IPC.AutoRetainer.GetOfflineCharacterData(CID)

        if character and character.Name then
            local world = character.World
            print(character.Name, world)
            return world
        end
    end
end

function GetListOfCharactersToTrade()
    local characterList = IPC.AutoRetainer.GetRegisteredCharacters()
    local seraphCharacters = {}
    local bismarckCharacters = {}
    local addedCharactersToTableList = {}

    local pathSeraphCharacters = "C:/Users/ecosm/AppData/Roaming/XIVLauncher2/pluginConfigs/GatherbuddyReborn/charactersThatIHaveTraded.txt"
    local pathBismarckCharacters = "C:/Users/ecosm/AppData/Roaming/XIVLauncher2/pluginConfigs/GatherbuddyReborn/charactersToMoveToEleanorHouse.txt"

    local fileSortedCharactersForSeraphTrading = io.open(pathSeraphCharacters, "r")
    local fileSortedCharactersForBismarckTrading = io.open(pathBismarckCharacters, "r")
    if fileSortedCharactersForSeraphTrading then
        for line in fileSortedCharactersForSeraphTrading:lines() do
            table.insert(seraphCharacters,line)
        end
        fileSortedCharactersForSeraphTrading:close()
    end

    if fileSortedCharactersForBismarckTrading then
        for line in fileSortedCharactersForBismarckTrading:lines() do
            table.insert(seraphCharacters,line)
        end
        fileSortedCharactersForBismarckTrading:close()
    end
    return seraphCharacters, bismarckCharacters
end

function MoveCharToHouse(worldToMoveTo)
    local canCrossDCToSeraph = IPC.Lifestream.CanVisitCrossDC("Seraph")
    local canSameDCToSeraph = IPC.Lifestream.CanVisitSameDC("Seraph")

    --THIS WILL RETURN A WRONG RESULT IF YOU DONT LOG INTO SAID CHARACTER FIRST
    
end

function GetListOfLowLevelRetainers()
    local characterList = IPC.AutoRetainer.GetRegisteredCharacters()
    local charactersToFarm = {} --Seraph
    local charactersToFarm2 = {} --Bismarck
    local addedCharacters = {} -- Track added names to prevent duplicate entries per character

    for index = 0, characterList.Count - 1 do
        local CID = characterList[index]
        local character = IPC.AutoRetainer.GetOfflineCharacterData(CID)

        if character and character.Name then
            local name = character.Name
            -- Fetch world directly from the character object or World ID property
            local world = character.World
            local fullName = name .. "@" .. world

            local retainer = character.RetainerData

            if retainer and retainer.Count > 0 then
                for retainerIndex = 0, retainer.Count - 1 do
                    local rData = retainer[retainerIndex]
                    local jobRow = Excel.GetRow("ClassJob", rData.Job)
                    local job = jobRow and tostring(jobRow.Name):lower() or ""
                    local level = tonumber(rData.Level) or 0

                    if (job == "miner" or job == "botanist") and level < 100 then
                        print(name .. " has a " .. job .. " retainer below level 100 (Level " .. level .. ")")
                        
                         -- Only add unique character entries to the list
                            if not addedCharacters[fullName] then
                                table.insert(charactersToFarm, fullName)
                                addedCharacters[fullName] = true
                                print("Added " .. fullName .. " to leveling queue.")
                            end
                    end
                end
            else
                print("No retainers found for " .. name)
            end
        else
            print("Invalid offline character data at index " .. index)
        end
    end
    return charactersToFarm
end

function debugTradeWithYona()
    local namesToTradeOnSeraph, namesToTradeOnBismarck = GetListOfLowLevelRetainers()--[cite: 1]
    local namesOfCharsThatIHaveTradedWith = GetCharactersThatIHaveTradedWith()--[cite: 1]
    
    yield("/dropbox")--[cite: 1]
    yield("/wait 1")--[cite: 1]
    print("Currently in TradeWithBossMainAccount()")--[cite: 1]
    
    -- Debug diagnostic: verify table contents
    if type(namesToTradeOnSeraph) ~= "table" then
        print("[DEBUG] namesToTradeOnSeraph is nil or not a table!")--[cite: 1]
        return
    end

    local totalCount = 0
    for key in pairs(namesToTradeOnSeraph) do
        totalCount = totalCount + 1
    end

    local t = 0
    for key in pairs(namesToTradeOnBismarck) do
        t = t +1
    end
    print("[DEBUG] Total characters found in namesToTradeOnBismarck: " .. tostring(t))--[cite: 1]

    print("[DEBUG] Total characters found in namesToTradeOnSeraph: " .. tostring(totalCount))--[cite: 1]

    if totalCount == 0 then
        print("[DEBUG] Loop skipped: namesToTradeOnSeraph table is empty.")--[cite: 1]
        return
    end

    if t == 0 then
        print("[DEBUG] Loop skipped: namesToTradeOnBismarck table is empty.")--[cite: 1]
    elseif t >0 then
        print("[DEBUG] Loop skipped: namesToTradeOnSeraph has " .. tostring(t) .. " values")--[cite: 1]

    end

    for index, seraphName in pairs(namesToTradeOnSeraph) do--[cite: 1]
        if namesOfCharsThatIHaveTradedWith[seraphName] then--[cite: 1]
            print(seraphName .. " has already been traded with.")--[cite: 1]
        else
            print("No trade has been done with " .. seraphName)--[cite: 1]
        end
    end
end

function AreThereCharactersNearby()
    if Entity.NearestOtherCharacter then
        return true
    else
        print("No available characters nearby. ")
        return false
    end
end

function GetNearestCharacterName()
    return Entity.NearestOtherCharacter.Name or ""
end

function SetItemsToTrade(id, isItemHQ, quantity)
    if IPC.Dropbox.SetItemQuantity(tonumber(id), false, tonumber(quantity)) == nil then
        print("args are OK for trading")
    else
        print("INVALID args. Check SetItemsToTrade() function")
    end
end

function ResetItemsToTrade(id, isItemHQ, quantity)
    IPC.Dropbox.SetItemQuantity(tonumber(id), false, tonumber(quantity))
end

function GetItemQuantity(id)
    print(IPC.Dropbox.GetItemQuantity(tonumber(id), false))
end

function StartTrade()
    IPC.Dropbox.BeginTradingQueue()
end

function FocusTargetCharacter(name)
    Entity.GetEntityByName(name):SetAsFocusTarget()
end

function ClearFocusTargetCharacter(name)
    Entity.GetEntityByName(name):ClearTarget()
end

function IsDropboxBusy()
    return IPC.Dropbox.IsBusy()
end

function GetTerritoryID()
    local code = IPC.Lifestream.GetRealTerritoryType()
    --print(IPC.Lifestream.GetRealTerritoryType())
    return IPC.Lifestream.GetRealTerritoryType()
end

function AmIinsideHouse()
    local mistSmallHouse = 282
    if GetTerritoryID() == mistSmallHouse then
        return true
    else
        return false
    end
end

function DisableAutoRetainerMultiMode()
    IPC.AutoRetainer.SetMultiModeEnabled(false)
end

function EnableAutoRetainerMultiMode()
    IPC.AutoRetainer.SetMultiModeEnabled(true)
end

function Relog(name)
    yield("/ays relog " .. name)
    yield("/wait 1")
    while IPC.Lifestream.IsBusy() or Player.IsBusy do
        yield("/wait 1")
        print("Waiting for Lifestream to log into " .. name .. ". Waiting 1 second to check. ")
    end
    yield("/wait 1")
    while IPC.Lifestream.IsBusy() or Player.IsBusy do
        yield("/wait 1")
        print("Lifestream is still busy.")
    end
    yield("/wait 1")
    print("Logged into " .. name)
end

function Trade(name, id, isItemHQ, quantity)
    FocusTargetCharacter(name)
    yield("/wait 2")
    SetItemsToTrade(id, isItemHQ, quantity)
    yield("/wait 2")
    StartTrade()
    yield("/wait 2")
    ResetItemsToTrade(id, isItemHQ)
    ClearFocusTargetCharacter(name)
end

function GetSizeOfCurrentyTradedCharacters(_table)
    local count = 0
    for _ in pairs(_table) do
        count = count + 1
    end
    return count
end

function TradeWithBossMainAccount()
    --[[

    This is for the alts to log into house and wait till you have traded with them

    ]]
    local namesToTradeOnSeraph, namesToTradeOnBismarck = GetListOfCharactersToTrade()
    local charNamesFromThisAccount = GetListOfLowLevelRetainers()
    local namesOfCharsThatIHaveTradedWith = GetCharactersThatIHaveTradedWith()
    yield("/dropbox") --IDK but it seems that the menu has to be open for it to work
    yield("/wait 1")
    print("Currently in TradeWithBossMainAccount()")
    for index, seraphName in pairs(namesToTradeOnSeraph) do
        if namesOfCharsThatIHaveTradedWith[seraphName] then
            print(seraphName.." has already been traded with.")
        else
            print("No trade has been done with " .. seraphName)
        end
    end
end

function TradeWithAlts()
    --[[

    This is for Yona, the account that trades to the alts

    ]]
    local haveITradedWithThisCharacter = {}
    local nameOfNearbyCharacter = GetNearestCharacterName() or ""
    local currentWorld = Excel.GetRow("World", Player.Entity.CurrentWorld).Name
    local world = Excel.GetRow("World", Player.Entity.HomeWorld).Name
    local idOfItem, quantityOfItem, nameOfItem, characterName, worldToTradeOn = GetCharacterInfoToTradeOn(currentWorld)
    --print(nameOfNearbyCharacter)
    yield("/dropbox")
    yield("/wait 1")
    while GetSizeOfCurrentyTradedCharacters(haveITradedWithThisCharacter) < #characterName do
        if AreThereCharactersNearby() and haveITradedWithThisCharacter[nameOfNearbyCharacter] ~= true then

            local validCharacterNameFromListFound = false

            for index, name in ipairs(characterName) do
                if (name == nameOfNearbyCharacter) and not haveITradedWithThisCharacter[name] == true then
                    validCharacterNameFromListFound = true
                    print(characterName[index] .. " is part of the Seraph characters to trade with")
                    print("No trade has been done to " .. characterName[index] .. ", whom is on the list for trading...")
                    haveITradedWithThisCharacter[name] = true
                    local fullNameWithWorld = name .. "@" .. world
                    WriteCharactersThatIHaveTradedWith(fullNameWithWorld)
                    print(name ..
                        " items are: " ..
                        nameOfItem[index] .. "(" .. quantityOfItem[index] .. ")[id -> " .. idOfItem[index] .. "]")
                    Trade(name, idOfItem[index], false, quantityOfItem[index])
                    yield("/wait 1")
                    while IsDropboxBusy() or Player.IsBusy do
                        print("Trading....")
                        yield("/wait 1")
                    end
                    print("Trading has ended.")
                    break
                end
            end

            if not validCharacterNameFromListFound then
                if haveITradedWithThisCharacter[nameOfNearbyCharacter] then
                    print(nameOfNearbyCharacter .. " has already been traded with. Waiting for a new character...")
                else
                    print(nameOfNearbyCharacter .. " is nearby but not on the trade list. Waiting...")
                end
                yield("/wait 2") -- Sleep briefly to avoid spamming the CPU
            end
        -- elseif haveITradedWithThisCharacter[nameOfNearbyCharacter] == true then
        --     local nameOfLastCharacterTradedWtih = nameOfNearbyCharacter
        --     print(nameOfNearbyCharacter .. " has been traded with already. Waiting for another character...")
        --     while nameOfNearbyCharacter ~= nameOfLastCharacterTradedWtih do
        --         print("Waiting for another character that isn't " .. nameOfLastCharacterTradedWtih .. "...")
        --         yield("/wait 1")
        --     end
        elseif AreThereCharactersNearby() and haveITradedWithThisCharacter[nameOfNearbyCharacter] == true then
            print("Already traded with " .. nameOfNearbyCharacter .. ". Looking for another valid character...")
        else
            print("No nearby characters. Waiting to find a nearby VALID character...")
            yield("/wait 3")
        end
    end
    -- if AreThereCharactersNearby() then
    --     local nameOfNearbyCharacter = ""
    --     if AreThereCharactersNearby() then
    --         nameOfNearbyCharacter = GetNearestCharacterName()
    --         print(nameOfNearbyCharacter .. " is the closest charactet atm.")
    --     else
    --         nameOfNearbyCharacter = "nil"
    --     end
    --     for index, name in ipairs(characterName) do
    --         if (characterName[index] == nameOfNearbyCharacter) and not haveITradedWithThisCharacter[name] == true then
    --             print(characterName[index] .. " is part of the Seraph characters to trade with")
    --             print("No trade has been done to " .. characterName[index] .. ", whom is on the list for trading...")
    --             print(characterName[index] .. " items are: " .. nameOfItem[index] .. "(" .. quantityOfItem[index] .. ")[id -> " .. idOfItem[index] .. "]")
    --             Trade(characterName[index], idOfItem[index], false, quantityOfItem[index])
    --         end
    --     end
    -- else
    --     print("No nearby characters.")
    --     while AreThereCharactersNearby() == false do
    --         yield("/wait 1")
    --     end
    --     TradeWithAlts()
    -- end
end

function WriteCharactersThatIHaveTradedWith(nameNoWorld)
    local pathFile_CharsThatIHaveTradedWith = "C:/Users/ecosm/AppData/Roaming/XIVLauncher2/pluginConfigs/GatherbuddyReborn/charactersThatIHaveTraded.txt"
    local fileCharsTradedWith = io.open(pathFile_CharsThatIHaveTradedWith, "a")
    if fileCharsTradedWith then
        print("Valid/Found file.")
        fileCharsTradedWith:write(nameNoWorld .. "\n")
        fileCharsTradedWith:close()
    end
end

function GetCharactersThatIHaveTradedWith()
    local pathFile_CharsThatIHaveTradedWith = "C:/Users/ecosm/AppData/Roaming/XIVLauncher2/pluginConfigs/GatherbuddyReborn/charactersThatIHaveTraded.txt"
    local fileCharsTradedWith = io.open(pathFile_CharsThatIHaveTradedWith, "r")
    local names = {}
    if fileCharsTradedWith then
        print("Valid/Found file.")
        for line in fileCharsTradedWith:lines() do
            table.insert(names, line)
            names[line] = true
        end
        fileCharsTradedWith:close()
    end
    return names
end

function WhatItemsDoesThisCharacterNeedToAskFor()
    local nameOfNearbyCharacter = GetNearestCharacterName()
    local currentWorld = Excel.GetRow("World", Player.Entity.CurrentWorld).Name
    local idOfItem, quantityOfItem, nameOfItem, characterName, worldToTradeOn = GetCharacterInfoToTradeOn(currentWorld)
    for index, name in ipairs(characterName) do
        if characterName[index] == nameOfNearbyCharacter then
            return idOfItem[index], quantityOfItem[index]
        end
    end
end

function debugmaintest()
    local amIBossOrAlt = FindMainCharacterOfThisAccount()
    if amIBossOrAlt == "Yona Flecher@Seraph" then
        TradeWithAlts()
    else
        TradeWithBossMainAccount()
    end
end

function main()
    DisableAutoRetainerMultiMode()
    local amIBossOrAlt = FindMainCharacterOfThisAccount()
    print(amIBossOrAlt)
    if amIBossOrAlt == "Yona Flecher@Seraph" then
        print("Account is boss.")
        TradeWithAlts()
    else
        print("Account is alt character.")
        TradeWithBossMainAccount()
    end
end

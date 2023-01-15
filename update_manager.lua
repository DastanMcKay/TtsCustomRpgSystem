-- Downloadable = {
--     version = 0,
--     url = "",
--     value = nil
-- }

-- function Downloadable.load(this)
--     WebRequest.get(this.url, function(request)
--         if (request.is_error) then
--             print("Failed to get download data.\n" .. request.error)
--             return
--         end

--         this.value = request.text
--     end)
-- end

-- Factory = {
--     class = "",
--     script = {},
--     xml = {},
--     objects = {}
-- }

-- setmetatable(Factory.script, Downloadable)
-- setmetatable(Factory.xml, Downloadable)

-- function Factory.spawn(this, parametrs)
--     local oldCallBack = parametrs["callback_function"]
--     parametrs["callback_function"] =
--     function(object)
--         object.setLuaScript(this.script.value)
--         object.UI.setXml(this.xml.value)
--         object.call("setFactory", {
--             factory = this,
--             class = this.class,
--             glManager = self
--         })
--         table.insert(this.objects, object)
--         if (oldCallBack ~= nil) then
--             oldCallBack(object)
--         end
--     end
--     spawnObject(parametrs)
-- end

-- function Factory.delete(this, object)
--     for index, obj in ipairs(this.objects) do
--         if (obj == object) then
--             table.remove(this.objects, index)
--             return
--         end
--     end
-- end

State = {
    settings = {
        updating = {
            check = true,
            install = true
        }
    },
    objects = {
        -- GUID
    }
}

ClassesToUpdate = {}

function onSave()
    return JSON.encode(State)
end

function onLoad(save_state)
    if (save_state ~= "") then
        State = JSON.decode(save_state)
    end
    if (State.settings.updating.check) then
        checkForUpdates()
    end
end

local function curentVersion()
    local curVersions = {}
    for _, objGuid in ipairs(State.objects) do
        local obj = getObjectFromGUID(objGuid)
        if (obj ~= nil) then
            local objClassVersion = obj.call("getVersionInfo")
            if (objClassVersion ~= nil) then
                for className, classVer in pairs(objClassVersion) do
                    curVersions[className] = classVer
                end
            end
        end
    end
    return curVersions

    -- local result = {}
    -- for className, factory in pairs(State.factories) do
    --     result[className].script.version = factory.script.version
    --     result[className].xml.version = factory.xml.version
    -- end
    -- return result
end

local function newVersionAvaliable(className, curVersion, latestVersion)
    if (curVersion[className] == nil) then
        return true
    end
    if (curVersion[className].version < latestVersion[className].version) then
        return true
    end
    return false
end

function checkForUpdates()
    local url = self.getDescription()
    --local url = "https://raw.githubusercontent.com/DastanMcKay/TtsCustomRpgSystem/release/versions.json"
    WebRequest.get(url, function(request)
        if (request.is_error) then
            print("Failed to get version info.\n" .. request.error)
            return
        end

        print("Received:\n" .. request.text)

        local latestVersion = JSON.decode(request.text)
        local curVersion = curentVersion()
        ClassesToUpdate = {}

        for className, classInfo in pairs(latestVersion) do
            if (newVersionAvaliable(className, curVersion, latestVersion)) then
                ClassesToUpdate[className] = classInfo
            end
        end
        if (next(ClassesToUpdate) == nil) then
            return
        end
        if (State.settings.updating.install) then
            getLatestUpdates()
        else
            broadcastToAll("Custom RPG system update avaliable")
        end
    end)
end

local function updateClass(className, url)
    WebRequest.get(url, function(request)
        if (request.is_error) then
            print("Failed to download class \"" .. className .. "\" from:\n" .. request.url .. "\nError: " .. request.error)
            return
        end

        print(className .. "dowloded")
        --local newScript = request.text
        --TODO update objects
    end)
end

function getLatestUpdates()
    while (next(ClassesToUpdate) ~= nil) do
        local classInfo = table.remove(ClassesToUpdate)
        updateClass(classInfo.url)
    end
end

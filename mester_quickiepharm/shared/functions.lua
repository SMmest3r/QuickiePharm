function CanLoad()
    if not Config then
        return false, "Couldn't load config. Make sure 'config.lua' is present in the 'shared' folder and everything is correct."
    end
    return true
end
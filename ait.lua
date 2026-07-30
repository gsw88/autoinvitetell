_addon.name = 'AutoInviteTell'
_addon.author = 'AI'
_addon.version = '1.1'
_addon.commands = {'ait'}
config = require ('config')
strings = require('strings')

require('packets')

default_whitelist = {'kellyn','miniina','zenithe','aerythel', 'vinnifre',}

whitelist = config.load(default_whitelist)
local function contains(list, value)
    for _, v in ipairs(list) do
        if v:lower() == value then
            return true
        end
    end
    return false
end
function isPlayerInParty(name)
    local party = windower.ffxi.get_party()
    if not party then return false end

    -- Check party slots p1 through p5
    for i = 0, 5 do
        local member = party['p' .. i]
        if member and member.name and member.name:lower() == name:lower() then
            return true
        end
    end

    return false
end

local function get_addon_directory()
    local source = debug.getinfo(1, "S").source

    -- Remove the leading '@'
    if source:sub(1,1) == '@' then
        source = source:sub(2)
    end

    -- Strip the filename
    return source:match("^(.*)[/\\]")
end

local function update_addon()
    local dir = get_addon_directory()

    local cmd = string.format(
        'cmd /C "cd /d "%s" && git fetch && git pull"',
        dir
    )

    print("Updating addon...")
    os.execute(cmd)
    print("Update complete.")
end

-- Event triggered on incoming chat messages
windower.register_event('chat message', function(message, sender, mode, is_gm)
    -- Mode 3 corresponds to incoming Tells
    if mode == 3 then
        -- Clean up the sender name just in case
        local player_name = string.gsub(sender, "[^a-zA-Z0-9]", ""):lower()
        if (contains(whitelist,player_name) and message:contains('invite')) then
        -- Send the party invite command via windower console
        windower.send_command('pcmd add ' .. player_name)
        
        -- Optional log message to your console
        print('AutoInviteTell: Sent party invite to ' .. player_name)
				
				elseif contains(whitelist,player_name) and isPlayerInParty(player_name) and message:contains('leader') then
					windower.send_command('pcmd leader ' .. player_name)
        
        -- Optional log message to your console
        print('AutoInviteTell: Sent party leader to ' .. player_name)
				
				elseif contains(whitelist, player_name)
					and message:contains('join') then
					
					
					windower.send_command('join')
					print('AutoInviteTell: Joining pt')
					
				elseif contains(whitelist, player_name)
					and message:contains('update') then

					update_addon()
					windower.send_command('lua r ait')
					print('AutoInviteTell: Updating from github')
				end
    end
end)

function removeAll(list, value)
	for i, v in ipairs(whitelist) do
        if v:lower() == value:lower() then
            table.remove(whitelist, i)
            return true
        end
    end
end
windower.register_event('addon command',function(...)

local args = {...}

if args[1] == 'add' then table.insert(whitelist, args[2]:lower()) end
if args[1] == 'rm' then 
	removeAll(whitelist,args[2])
end
if args[1] == 'save' then config.save(whitelist, 'all') end
if args[1] == 'help' then 
	windower.add_to_chat(1, 'usage: ait add <name>, ait rm <name>, ait save, ait print')
end
if args[1] == 'print' then 
	for key, value in pairs(whitelist) do
		print(value)
		
	end
end

end)
		

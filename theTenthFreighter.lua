-- todo -- fight for access card
-- todo -- make escape pods location
-- todo -- make escape pods examine ==> end text

require 'adventure'

game = {
  done = false,
  stop = false,
  filename = 'theTenthFreighter.save.txt',
  defaultname = 'Zigar',
  introtext = wrap("\nWelcome {name}, You are an ambassador. You are also the only passenger the tenth freighter has ever had. The on freighter is on its way to Zaga Alpha; a well colonized planet the outskirts of the deadly alien Trelzi's territory. Because the United Federation fears a war with the deadly Trelzi, and because this was the only ship headed in that direction, this freighter is hurrying you toward an important round of tense negotiations.")
}

--========================================================
-- location function factories
local function  quarters_south_passageway (event, state)
  return function ()
    gbl.description = "The passageway. (To the West is Engineering which is locked.)"
    gbl.options = {
      n = 'Go North; back to quarters',
      s = 'Go South; to the mess hall',
      e = 'Go East; to the bunker',
    }
    if gbl.conditions.engineeringaccess then
      gbl.options['w'] = 'Go West; to engineering'
    end
    return state
  end
end
function passageway_north_quarters (event, state)
   return function ()
    gbl.description = "You are back in general quarters; your bed says, 'hi'."
    gbl.options = {
      s = 'Go South; back to the passageway',
    }
    return state
  end
end
function passageway_south_mess_hall (event, state)
   return function ()
    gbl.description = "You are in the mess hall. There is a table in the center of the room with lots of chairs around it. The aroma is evocative of its name; a mess."
    gbl.options = {
      n = 'Go North; back to passageway',
    }
    if gbl.conditions.inmesshall == 2 then
      gbl.description = gbl.description .. '\n\noverheard conversation...' -- todo -- add overheard conversation...
      gbl.roomswithenemies = {
        'helm',
        'bunker',
        'chambers',
        'engineering',
        'escape_pods',
        'mess_hall',
        'northern_battery',
        'quarters',
        'southern_battery',
      }
    else
      gbl.conditions.inmesshall = gbl.conditions.inmesshall + 1
    end
    return state
  end
end
function mess_hall_north_passageway (event, state)
   return function ()
    gbl.description = "You are back in the passageway. (To the West is Engineering which is locked.)"
    gbl.options = {
      n = 'Go North; to the quarters',
      s = 'Go South; back to the mess hall',
      e = 'Go East; to the bunker',
    }
    if gbl.conditions.engineeringaccess then
      gbl.options['w'] = 'Go West; to engineering'
    end
    return state
  end
end
function passageway_east_bunker (event, state)
  return function ()
    gbl.description = "You are in the bunker."
    gbl.options = {
      w = "Go West; back to the passageway",
      n = "Go North; to the northern battery",
      s = "Go South; to the southern battery",
    }
    if detectinventoryitem('access_card') then
      gbl.options['e'] = 'Go East; to the helm'
    end
    return state
  end
end
function bunker_west_passageway (event, state)
   return function ()
    gbl.description = "You are back in the passageway. (To the West is Engineering which is locked.)"
    gbl.options = {
      n = 'Go North; to the quarters',
      s = 'Go South; to the mess hall',
      e = 'Go East; back to the bunker',
    }
    if gbl.conditions.engineeringaccess then
      gbl.options['w'] = 'Go West; to engineering'
    end
    return state
  end
end
function bunker_east_helm (event, state)
   return function ()
    gbl.description = "You are in the helm; a huge window is in front of you. A man sits in front of a control panel in front of the window. A blue glowing screen is in the center of the control panel."
    gbl.options = {
      w = "Go West; back to the bunker",
    }
    return state
  end
end
function bunker_north_northern_battery (event, state)
   return function ()
    gbl.description = "You are in the northern battery. A targeting terminal is to your right. It's Flashing."
    gbl.options = {
     s  = "Go South; back to the bunker",
    }
    return state
  end
end
function bunker_south_southern_battery (event, state)
   return function ()
    gbl.description = "You are in the southern battery. A targeting terminal is to your left. It's Flashing."
    gbl.options = {
     n = "Go North; back to the bunker",
    }
    return state
  end
end
function helm_west_bunker (event, state)
   return function ()
    gbl.description = "You are back in the bunker."
    gbl.options = {
      w = "Go West; back to the passageway",
      e = "Go East; to the helm",
      n = "Go North; to the northern battery",
      s = "Go South; to the southern battery",

    }
    return state
  end
end
function  northern_battery_south_bunker (event, state)
   return function ()
    gbl.description = "You are back in the bunker."
    gbl.options = {
      n = "Go North; to the northern battery",
      s = "Go South; to the southern battery",
    }
    if detectinventoryitem('access_card') then
      gbl.options['e'] = 'Go East; to the helm'
    end
    return state
  end
end
function southern_battery_north_bunker (event, state)
   return function ()
    gbl.description = "You are back in the bunker."
    gbl.options = {
      w = "Go West; back to the passageway",
      n = "Go North; to the northern battery",
      s = "Go South; to the southern battery",
    }
    if detectinventoryitem('access_card') then
      gbl.options['e'] = 'Go East; to the helm'
    end
    return state
  end
end
function passageway_west_engineering (event, state)
   return function ()
    gbl.description = "You are in the engineering room. There are buttons and dials in rows on the control panel in the center of the room. There is an iron tube a foot wide and three long next to the control panel."
    gbl.options = {
      e = "Go East; back to the passageway.",
    }
    return state
  end
end
function  engineering_east_passageway (event, state)
   return function ()
    gbl.description = "description"
    gbl.options = {
      n = 'Go North; to the quarters',
      s = 'Go South; to the mess hall',
      e = 'Go East; to the bunker',
      w = 'Go West; back to engineering',
    }
    return state
  end
end
--========================================================
-- start function factory
local function start_begin_quarters (event, state)
  return function ()
    gbl.description = "you are in general quarters, siting on the one peace of furniture you have; your bed. There is a door going south out of general quarters."
    gbl.options = {
      s = 'Go South; to the passageway',
    }
    return state
  end
end
--========================================================
-- examination function factories
local function battery_examine (state)
  return function ()
    print(wrap("\n\nThe terminal says, '*** ACCESS DENIED: No access card detected ***'"))
    entertocontinue()
    return state
  end
end
local function southern_battery_examine_southern_battery (event, state)
  return battery_examine (state)
end
local function northern_battery_examine_northern_battery (event, state)
  return battery_examine (state)
end
local function helm_examine_helm (event, state)
  return function ()
    if not gbl.conditions.engineeringaccess then
      print(wrap("\n\nThe terminal says, '*** ACCESS GRANTED: Access card detected; access level sufficient ***'\n\nIt takes awhile but you finally figure out how to grant yourself engineering access."))
      gbl.conditions.engineeringaccess = true
    else
      print('\nYour examination is fruitless.\n')
    end
    entertocontinue()
    return state
  end
end
local function engineering_examine_engineering (event, state)
  return function ()
    if not gbl.conditions.engineeringaccess then
      print(wrap("\n\nThe terminal says, '*** ACCESS DENIED: Access card detected; access level insufficient ***'\n\n"))
    else
      print('\n\njettison warp-core') -- todo -- jettison warp-core
    end
    entertocontinue()
    return state
  end
end

locations = makeFSM({
  -- examine rows
  { 'bunker',           'examine', 'bunker',           fruitless_examination },
  { 'helm',             'examine', 'helm',             helm_examine_helm },
  { 'mess_hall',        'examine', 'mess_hall',        fruitless_examination },
  { 'northern_battery', 'examine', 'northern_battery', northern_battery_examine_northern_battery },
  { 'passageway',       'examine', 'passageway',       fruitless_examination },
  { 'quarters',         'examine', 'quarters',         fruitless_examination },
  { 'southern_battery', 'examine', 'southern_battery', southern_battery_examine_southern_battery },
  { 'engineering',      'examine', 'engineering',      engineering_examine_engineering},
  -- location rows
  { 'bunker',           'east',    'helm',             bunker_east_helm },
  { 'bunker',           'north',   'northern_battery', bunker_north_northern_battery },
  { 'bunker',           'south',   'southern_battery', bunker_south_southern_battery },
  { 'bunker',           'west',    'passageway',       bunker_west_passageway },
  { 'engineering',      'east',    'passageway',       engineering_east_passageway },
  { 'helm',             'west',    'bunker',           helm_west_bunker },
  { 'mess_hall',        'north',   'passageway',       mess_hall_north_passageway },
  { 'northern_battery', 'south',   'bunker',           northern_battery_south_bunker },
  { 'passageway',       'east',    'bunker',           passageway_east_bunker },
  { 'passageway',       'north',   'quarters',         passageway_north_quarters },
  { 'passageway',       'south',   'mess_hall',        passageway_south_mess_hall },
  { 'passageway',       'west',    'engineering',      passageway_west_engineering },
  { 'quarters',         'south',   'passageway',       quarters_south_passageway },
  { 'southern_battery', 'north',   'bunker',           southern_battery_north_bunker },
  -- default starting location row
  { 'start',            'begin',   'quarters',         start_begin_quarters },
})

actions = {}

go({
  name = nil,
  conditions = {
    engineeringaccess = false,
    inhelm = 0,
    inmesshall = 0,
  },
  roomswithenemies = {
    'nowhere',
  },
  commands = {
    e = 'east',
    h = 'hail',
    n = 'north',
    s = 'south',
    w = 'west',
    x = 'examine',
  },
  enemytypes = {
    'ship_crawler',
    'silet_shadow',
    'ship_guard',
    'shadow_guard',
  },
  inventory = {
    'access_card', -- todo -- remove access card before release
  }
},
{
  hero = {
    hitmin = 3,
    hitmax = 5,
    tohit = 5,
  },
  enemy = {
    hitmin = 2,
    hitmax = 7,
    mintohit = 4,
    maxtohit = 5,
    minhp = 1,
    maxhp = 4,
    hitmod = 3,
  }
})
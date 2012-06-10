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
    getcard()
    return state
  end
end
function passageway_north_quarters (event, state)
   return function ()
    gbl.description = "You are back in general quarters; your bed says, 'hi'."
    gbl.options = {
      s = 'Go South; back to the passageway',
    }
    getcard()
    return state
  end
end
function passageway_south_mess_hall (event, state)
   return function ()
    gbl.description = "You are in the mess hall. There is a table in the center of the room with lots of chairs around it. The aroma is evocative of its name; a mess."
    gbl.options = {
      n = 'Go North; back to passageway',
    }
    if gbl.conditions.inmesshall == 1 then
      gbl.description = gbl.description .. '"\n\nAs you wander into the mess hall your senses tell you there are people behind the replicator partition. Then you hear voices engaged in tense conversation. "Ok; Ok. I get that he has to be... you know. But how are we going to make it look like an accid..." the other voice cuts in abruptly, "Shut up, someone\'s coming." Two men come walking slowly from behind the partition. Both look startled to see you there. As they walk by one looks at you stupidly but the other nudges him and looks menacingly at you. As soon as they are out of eyesight you hear the intruder alert sounding...'
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
    end
    gbl.conditions.inmesshall = gbl.conditions.inmesshall + 1
    getcard()
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
    getcard()
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
    getcard()
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
    getcard()
    return state
  end
end
function bunker_east_helm (event, state)
   return function ()
    gbl.description = "You are in the helm; a huge window is in front of you. A control panel is in front of the window. A blue glowing screen is in the center of the control panel."
    gbl.options = {
      w = "Go West; back to the bunker",
    }
    insertinventoryitem('computer_terminal')
    getcard()
    return state
  end
end
function bunker_north_northern_battery (event, state)
   return function ()
    gbl.description = "You are in the northern battery. A targeting terminal is to your right. It's Flashing."
    gbl.options = {
     s  = "Go South; back to the bunker",
    }
    insertinventoryitem('computer_terminal')
    getcard()
    return state
  end
end
function bunker_south_southern_battery (event, state)
   return function ()
    gbl.description = "You are in the southern battery. A targeting terminal is to your left. It's Flashing."
    gbl.options = {
     n = "Go North; back to the bunker",
    }
    insertinventoryitem('computer_terminal')
    getcard()
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
    deleteinventoryitem('computer_terminal')
    getcard()
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
    deleteinventoryitem('computer_terminal')
    getcard()
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
    deleteinventoryitem('computer_terminal')
    getcard()
    return state
  end
end
function passageway_west_engineering (event, state)
   return function ()
    gbl.description = "You are in the engineering room. There are buttons and dials -- rows and rows of them -- on the control panel in the center of the room. There is an iron tube a foot wide and three feet long next to the control panel."
    gbl.options = {
      e = "Go East; back to the passageway.",
      s = "Go South; to the pod bay"
    }
    insertinventoryitem('computer_terminal')
    getcard()
    return state
  end
end
function engineering_east_passageway (event, state)
   return function ()
    gbl.description = "description"
    gbl.options = {
      n = 'Go North; to the quarters',
      s = 'Go South; to the mess hall',
      e = 'Go East; to the bunker',
      w = 'Go West; back to engineering',
    }
    deleteinventoryitem('computer_terminal')
    getcard()
    return state
  end
end
function pod_bay_north_engineering (event, state)
   return function ()
    gbl.description = "You are in the engineering room. here are buttons and dials -- rows and rows of them -- on the control panel in the center of the room. There is an iron tube a foot wide and three feet long next to the control panel."
    gbl.options = {
      s = "Go South; back to pod bay",
      e = "Go East; to the passageway",
    }
    getcard()
    return state
  end
end
function engineering_south_pod_bay (event, state)
   return function ()
    gbl.description = "Round doors leading to the little round pods line the walls of the pod bay it is rather dark in here compared to the rest of the ship. Little wisps of steam come from the edges of the doors."
    gbl.options = {
      n = "Go North; back to engineering",
    }
    getcard()
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
    getcard()
    return state
  end
end
--========================================================
-- examination function factories
local function terminal_examine (state)
  return function ()
    print(wrap("\n\nYou see a computer terminal here with an access card slot centered just below the screen."))
    entertocontinue()
    return state
  end
end
local function southern_battery_examine_southern_battery (event, state)
  return terminal_examine (state)
end
local function northern_battery_examine_northern_battery (event, state)
  return terminal_examine (state)
end
local function helm_examine_helm (event, state)
  return terminal_examine (state)
end
local function engineering_examine_engineering (event, state)
  return terminal_examine (state)
end
local function pod_bay_examine_pod_bay (event, state)
  return terminal_examine (state)
end

--========================================================
-- check if the player gets the access card (invoked by all location functions)
function getcard()
  if gbl.health.state ~= 'healthy' and not detectinventoryitem('access_card') then
    print(wrap("\n\nAs you are about to leave you notice that your attacker, when he fell to the ground unconscious, must have dropped an access card. (Access card taken.)"))
    insertinventoryitem('access_card')
    entertocontinue()
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
  { 'engineering',      'examine', 'engineering',      engineering_examine_engineering },
  { 'pod_bay',          'examine', 'pod_bay',          pod_bay_examine_pod_bay },
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
  { 'pod_bay',          'north',   'engineering',      pod_bay_north_engineering },
  { 'engineering',      'south',   'pod_bay',          engineering_south_pod_bay },
  -- default starting location row
  { 'start',            'begin',   'quarters',         start_begin_quarters },
})

actions = {}

local function useterminal ()
  return function (t)
    return function ()
      local function batteryterminal ()
          local msg = detectinventoryitem('access_card') and 'Access card detected; access level insufficient' or 'No access card detected'
          local r = "\n\nAfter a beep that can only be described as rude, the terminal says, '*** ACCESS DENIED: " .. msg .. " ***'"
          return r
      end
      local terminals = {
        helm = function ()
          local msg = gbl.conditions.engineeringaccess and "that you have already granted yourself engineering access." or "how to grant yourself engineering access."
          local r = "\n\nThe terminal says, '*** ACCESS GRANTED: Access card detected; access level sufficient ***'\n\nIt takes awhile but you finally figure out " .. msg
          gbl.conditions.engineeringaccess = true
          return r
        end,
        engineering = function ()
          local r = "\n\nThe terminal says, '*** ACCESS DENIED: Access card detected; access level insufficient ***'\n\n"
          if gbl.conditions.engineeringaccess then
            r = "\n\nYou have had some training with these control panel things, not much but enough to know the basics. You punch a few buttons; suddenly the ship rocks violently, throwing you back. After a little while the tremors die down and you pick your self up."
          end
          return r
        end,
        southern_battery = batteryterminal,
        northern_battery = batteryterminal,
      }
      if gbl.location ~= 'pod_bay' then
        return wrap(stringifyaction(t) .. terminals[gbl.location]())
      else
        local description = '\n\nYou walk into the pod bay; pick the captain\'s pod, it being the best, crawl through the door and pound the "eject" button. The door twists shut and the pod starts up the thrusters. It heads for the nearest space station; a mere 1.284 light seconds away.\n\n\nTHE END\n\n'
        print('\n' .. wrap(description))
        game.done = true
        game.stop = true
      end
    end
  end
end

insertaction(
  actions,
  {
    verbs = {
      'push',
      'put',
      'use',
    },
    nouns = {
      first = {
        'access_card',
      },
      second = {
        'computer_terminal',
      }
    },
    predicates = {
      'in',
      'on',
      'to',
      'with',
    }
  },
  useterminal()
)

go({
  name = nil,
  conditions = {
    engineeringaccess = false,
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
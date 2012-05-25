require 'adventure'

--========================================================
-- settings, globals, and defaults
--========================================================

-- what rooms can an enemy be in (note: enemies will be in one of these rooms each turn)
roomswithenemies = {
    'room01',
    'room02',
}

-- for command translation from single letter to full command
commands = {
    n = 'north',
    s = 'south',
    e = 'east',
    w = 'west',
    x = 'examine',
}

-- names for the various enemies, from weakest to strongest (only four unless you make cfg.enemy.maxhp > 4)
enemytypes = {
    'tiny_drone',
    'small_drone',
    'drone',
    'large_drone',
}

-- configuration for the fighting sub-engine
cfg = {
    hero = {
        hitmin = 3, -- where you start -- heroattack = math.random(cfg.hero.hitmin, cfg.hero.hitmax)
        hitmax = 5, -- max bad-ass-ness -- heroattack = math.random(cfg.hero.hitmin, cfg.hero.hitmax)
        tohit = 5, -- what the hero has to beat to hit the enemy -- heroattack > cfg.hero.tohit
    },
    enemy = {
        hitmin = 2, -- enemyattack = math.random(cfg.enemy.hitmin, cfg.enemy.hitmax)
        hitmax = 7, -- enemyattack = math.random(cfg.enemy.hitmin, cfg.enemy.hitmax)
        mintohit = 4, -- the min of what an enemy has to beat to hit the hero (the enemy is savage)
        maxtohit = 5, -- the max of what an enemy has to beat to hit the hero (the enemy is menacing)
        minhp = 1, -- the min hit points for an enemy (this matches the enemytypes)
        maxhp = 4, -- the max hit points for an enemy (this matches the enemytypes)
        hitmod = 3, -- the diff between the maxtohit and the two types of enemies (menacing, savage)
    }
}

-- starting values, only change the last two items please
game = {
    done = false,
    stop = false,
    name = nil,
    defaultname = 'Friend',
    introtext = wrap("\nWelcome {name}, This is an example adventure. Not much fun as a game though, sorry."),
}

-- the hero's items, stick items that you want the player to have at game start
inventory = inventory or {
    'the_inevitable_round_hole'
}

-- the action table for the inventory sub-engine
actions = actions or {}

-- for recording author configurable states, events, and conditions
conditions = {
    timesinroom00 = 1,
}

--========================================================
-- location function factories
--========================================================
local function room00_north_room01 (event, state)
    return function ()
        room.description = "This is another room. There are three like it in this adventure. You can see another identical room to the North. To the South is the room you just left."
        room.options = {
            n = 'Go North; to still another room',
            s = 'Go South; back to the starting room'
        }
        -- use conditions
        if conditions.timesinroom00 > 1 then room.options.s = room.options.s .. ' (thou you have been there ' .. tostring(conditions.timesinroom00) .. ' times already)' end
        return state
    end
end

local function room01_south_room00 (event, state)
    return function ()
        room.description = "Hey, you're back at the starting room. (Notice the ability to have descriptions that are dependent on the direction of entry.)"
        room.options = {
            n = 'Go North; back to that other room'
        }
        -- set conditions
        conditions.timesinroom00 = conditions.timesinroom00 + 1
        return state
    end
end

local function room01_north_room02 (event, state)
    return function ()
        room.description = "You made it to the last room! (It looks exactly the same as the other two.)"
        room.options = {
            s = 'Go South; back to the middle room'
        }
        return state
    end
end

local function room02_south_room01 (event, state)
    return function ()
        room.description = "And here you are, at the middle room. (Notice that you can now add information to the options that would have been a spoiler before.)"
        room.options = {
            n = 'Go North; back to the dead-end',
            s = 'Go South; back to the start'
        }
        return state
    end
end

--========================================================
-- examination function factories
--========================================================
local function room01_examine_room01 (event, state)
    return function ()
        if not (detectinventoryitem('the_proverbial_square_peg') or detectinventoryitem('a_conundrum')) then
            print(wrap('\n\nYou discover the square peg; yes, _that_ square peg. (Peg taken.)\nChoose (i)nventory and do what you have to do.'))
            insertinventoryitem('the_proverbial_square_peg')
        else
            print('\nYour examination is fruitless.\n')
        end
        entertocontinue()
        return state
    end
end

--========================================================
-- start function factory
--========================================================
local function start_begin_room00 (event, state)
    return function ()
        room.description = "This is the starting location. I called it room00."
        room.options = {
            n = 'Go North; to another room. (Careful, you can be attack in the other rooms)'
        }
        return state
    end
end

--========================================================
-- room dispatch table
--========================================================
locations = makeFSM({
-- the room you started in --> the command taken --> the room you'll end in --> the function that gets invoked
-- notice how when you examine you want the hero to stay in the same room
-- (also you could make a teleporter with this... just saying)
    { 'room00', 'examine', 'room00', fruitless_examination },
    { 'room00', 'north',   'room01', room00_north_room01 },
    { 'room01', 'examine', 'room01', room01_examine_room01 },
    { 'room01', 'north',   'room02', room01_north_room02 },
    { 'room01', 'south',   'room00', room01_south_room00 },
    { 'room02', 'examine', 'room02', fruitless_examination },
    { 'room02', 'south',   'room01', room02_south_room01 },
    -- default starting area
    { 'start',  'begin',   'room00', start_begin_room00 }
})

--========================================================
-- create an action: make a conundrum
--========================================================
local function makeaconundrum ()
    return function (t)
        return function ()
            local r = stringifyaction(t)
            r = r .. '\n\n[You have (somehow) gotten the square peg into the round hole. (Good job!)]'
            deleteinventoryitem({
                'the_proverbial_square_peg',
                'the_inevitable_round_hole',
            })
            insertinventoryitem('a_conundrum')
            return r
        end
    end
end

insertaction(
    actions,
    {
        verbs = {
            'drop',
            'push',
            'put',
        },
        nouns = {
            first = { 'the_proverbial_square_peg' },
            second = { 'the_inevitable_round_hole' }
        },
        predicates = {
            'in',
        }
    },
    makeaconundrum()
)

--========================================================
--enter the main loop, no touchy!
--========================================================
go()
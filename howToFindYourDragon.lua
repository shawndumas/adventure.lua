require 'adventure'

--========================================================
-- location function factories
local function ground_north_woods (event, state)
    return function ()
        room.description = "There are trees everywhere. Leaves litter the ground."
        room.options = {
            n = 'Go North; to the river'
        }
        return state
    end
end

local function woods_north_river (event, state)
    return function ()
        room.description = "There is a slow-moving river that continues to the West. The river does not seem very dangerous. You can see a cave to the North. The ground rises slightly to the East."
        room.options = {
            n = 'Go North; to the cave',
            s = 'Go South; to the woods',
            e = 'Go East; going up',
            w = 'Go West; to the rivulet'
        }
        deletecommand('c')
        insertinventoryitem('the_river')
        return state
    end
end

local function river_north_cave (event, state)
    return function ()
        if not detectinventoryitem('the_lit_torch') then
            room.description = "You are in a dark cave, and you feel very unsafe. You can't see anything inside the cave except two eyes peering eagerly out of the inky darkness.\n\nIt is too dark and too dangerous to continue.\n\n[You hear a dank dripping... then a low growl.]"
        else
            local description = '\n\nWith the lit torch in one hand and the fish in the other Toothless can both see you and smell the fish. He bounds out of the cave in a single dragonesque leap knocking you over eagerly eating the offered fish.\n\n\nTHE END'
            print('\n' .. wrap(description))
            game.done = true
            game.stop = true
        end
        room.options = {
            s = 'Go South; to the river'
        }
        deleteinventoryitem('the_river')
        return state
    end
end

local function river_south_woods (event, state)
    return function ()
        room.description = "Trees and leaves; just like before."
        room.options = {
            n = 'Go North; to the river'
        }
        deleteinventoryitem('the_river')
        return state
    end
end

local function river_east_pit (event, state)
    return function ()
        room.description = "A pit."
        room.options = {
            w = 'Go West; go to the river'
        }
        deleteinventoryitem('the_river')
        return state
    end
end

local function river_west_rivulet (event, state)
    return function ()
        room.description = "There is a small rivulet branching out from the main river. It moves slightly faster, but not dangerously fast. Low, tree-lined grassy banks are on either side of the rivulet. You can see a clearing to the West."
        room.options = {
            e = 'Go East; go to the river',
            w = 'Go West; go to the clearing'
        }
        deleteinventoryitem('the_river')
        return state
    end
end

local function rivulet_west_clearing (event, state)
    return function ()
        room.description = "At the termination of the rivulet, there is a large rock with smaller rocks spread around. The sun shines down on the moss-covered rocks. To the South there is a meadow.\n\n[You hear a lonely howling.]"
        room.options = {
            e = 'Go East; go to the rivulet',
            s = 'Go South; in to the meadow'
        }
        return state
    end
end

local function rivulet_east_river (event, state)
    return function ()
        room.description = "You follow the rivulet as it becomes the slow-moving river."
        room.options = {
            n = 'Go North; to the cave',
            s = 'Go South; to the woods',
            e = 'Go East; to the pit',
            w = 'Go West; to the rivulet'
        }
        insertinventoryitem('the_river')
        return state
    end
end

local function clearing_east_rivulet (event, state)
    return function ()
        room.description = "There is a trickling rivulet."
        room.options = {
            e = 'Go East; go to the river',
            w = 'Go West; go to the clearing'
        }
        return state
    end
end

local function pit_west_river (event, state)
    return function ()
        room.description = "There is a slow-moving river."
        room.options = {
            n = 'Go North; to the cave',
            s = 'Go South; to the woods',
            e = 'Go East; to the pit',
            w = 'Go West; to the rivulet'
        }
        insertinventoryitem('the_river')
        return state
    end
end

local function cave_south_river (event, state)
    return function ()
        room.description = "There is a slow-moving river."
        room.options = {
            n = 'Go North; to the cave',
            s = 'Go South; to the woods',
            e = 'Go East; to the pit',
            w = 'Go West; to the rivulet'
        }
        insertinventoryitem('the_river')
        return state
    end
end

local function woods_climb_tree (event, state)
    return function ()
        room.description = "Tree top."
        room.options = {
            c = 'Climb down; to the woods below',
        }
        return state
    end
end

local function tree_climb_woods (event, state)
    return function ()
        room.description = "Trees and leaves; just like before. (But it was fun up in the tree.)"
        room.options = {
            n = 'Go North; to the river',
            c = 'Climb up; back to the tree top',
        }
        return state
    end
end

local function clearing_south_meadow (event, state)
    return function ()
        room.description = "Flies; little tiny flies everywhere."
        room.options = {
            n = 'Go North; to the clearing',
            s = 'Go South; continuing in to the meadow',
            w = 'Go West; continuing in to the meadow'
        }
        if not (detectinventoryitem('the_small_fly') or conditions.bait) then
            insertcommand('c', 'catch')
            room.options.c = 'Catch one; if you can'
        end
        return state
    end
end

local function meadow_north_clearing (event, state)
    return function ()
        local thirsty = ''
        if conditions.milesinthemeadow > 7 then
            thirsty = '\n\nAfter your thirsty escapade in the meadow (' .. conditions.milesinthemeadow .. ' miles by my count) you take a long drink from the dwindled rivulet.'
        end
        room.description = "You are back at the clearing." .. thirsty .. "\n\n[You hear a lonely howling.]"
        room.options = {
            e = 'Go East; go to the rivulet',
            s = 'Go South; in to the meadow'
        }
        conditions.milesinthemeadow = 0
        deletecommand('c')
        return state
    end
end

local function meadow_catch_meadow (event, state)
    return function ()
        room.description = "The flies are fast and wary but you finally catch one."
        room.options = {
            n = 'Go North; to the clearing',
            s = 'Go South; continuing in to the meadow',
            w = 'Go West; continuing in to the meadow'
        }
        insertinventoryitem('the_small_fly')
        return state
    end
end

local function neverendingmeadow (event, state)
    local monotonousmessages = {
        'The flies are starting to get to you.',
        'The flies are in your eyes, mouth, and everywhere else annoying flies go.',
        "Boy is it hot.",
        'The sun is beaming down on you,',
        'Did I mention that it is hot?',
        'You become sick from eating flies.',
        'Thirst...',
        'Very thirsty...',
        'If I said "thirsty" again would you stop?',
        'Wow; determined!'
    }
    return function ()
        conditions.milesinthemeadow = conditions.milesinthemeadow + 1
        local mm = monotonousmessages[conditions.milesinthemeadow]
        mm = mm or 'Ok, listen. It never ends; go back... Really.'
        room.description = "Flies; little tiny flies everywhere." .. '\n\n' .. mm
        room.options = {
            n = 'Go North; to the clearing',
            s = 'Go South; continuing in to the meadow',
            w = 'Go West; continuing in to the meadow'
        }
        if not (detectinventoryitem('the_small_fly') or conditions.bait) then
            insertcommand('c', 'catch')
            room.options.c = 'Catch one; if you can'
        end
        if conditions.milesinthemeadow == 6 then
            hero.health = kombat[hero.health.state]['hit'].action()
            print('\t' .. hero.health.report)
        end
        return state
    end
end

local function meadow_south_meadow (event, state)
    return neverendingmeadow(event, state)
end

local function meadow_west_meadow (event, state)
    return neverendingmeadow(event, state)
end

--========================================================
-- examination function factories
local function woods_examine_woods (event, state)
    return function ()
        if not (detectinventoryitem('the_branch') or detectinventoryitem('the_fishing_rod')) then
            print(wrap('\n\nA fallen branch lies among the strewn leaves. (Branch taken.)'))
            insertinventoryitem('the_branch')
        elseif not detectinventoryitem('the_tinder') then
            print(wrap('\n\nYou notice a low hanging branch.'))
            insertcommand('c', 'climb')
            room.options.c = 'Climb up; to the top of the tree'
        else
            print('\nYour examination is fruitless.\n')
        end
        entertocontinue()
        return state
    end
end

local function tree_examine_tree (event, state)
    return function ()
        if not detectinventoryitem('the_tinder') then
            print(wrap('\n\nYou see an abandon nest. There is a tuft of down that can be used as tinder. Also, the creative weaver wove a thin strip of cloth forming a part of the walls of the nest. (Tinder and thin strip of cloth taken.)'))
            insertinventoryitem({ 'the_tinder', 'thin_strip_of_cloth' })
        else
            print('\nYour examination is fruitless.\n')
        end
        entertocontinue()
        return state
    end
end

local function river_examine_river (event, state)
    return function ()
        if not (detectinventoryitem('the_hook_shaped_bone') or detectinventoryitem('the_fishing_rod')) then
            print(wrap('\n\nWhen you peer into the beautiful shining water, a long killer spearfish jumps out at you. Startled you slip and catch yourself just before falling in. From your new vantage point you see a small hooked shaped bone in the shallows. (Bone taken.)'))
            insertinventoryitem('the_hook_shaped_bone')
        else
            print('\nYour examination is fruitless.\n')
        end
        entertocontinue()
        return state
    end
end

local function clearing_examine_clearing (event, state)
    return function ()
        if not (detectinventoryitem('the_strong_thin_vine') or detectinventoryitem('the_fishing_rod')) then
            print(wrap('\n\nAn extraordinarily strong and thin vine is wrapped around the far side of rock. With difficulty you pry it loose. (Vine taken.)'))
            insertinventoryitem('the_strong_thin_vine')
        else
            print('\nYour examination is fruitless.\n')
        end
        entertocontinue()
        return state
    end
end

local function rivulet_examine_rivulet (event, state)
    return function ()
        if not detectinventoryitem('the_flint') then
            print(wrap('\n\nYou see a flint among the rocks on the embankment. (Flint taken.)'))
            if detectinventoryitem('the_rock') then
                insertinventoryitem('the_flint_and_rock')
            end
            insertinventoryitem('the_flint')
        else
            print('\nYour examination is fruitless.\n')
        end
        entertocontinue()
        return state
    end
end

local function pit_examine_pit (event, state)
    return function ()
        if not detectinventoryitem('the_rock') then
            print(wrap("\n\nYou see a nice hand sized rock among the lesser rocks in the pit's bottom. (Rock taken.)"))
            if detectinventoryitem('the_flint') then
                insertinventoryitem('the_flint_and_rock')
            end
            insertinventoryitem('the_rock')
        else
            print('\nYour examination is fruitless.\n')
        end
        entertocontinue()
        return state
    end
end

--========================================================
-- start function factory
local function start_begin_ground (event, state)
    return function ()
        room.description = "Oof! Your butt hurts, but you have landed on the grass near a small forest. Looking up, you see your dragon fly quite a bit, then begin falling from the sky. You try to call to him but he can't hear you. He is now out of sight. You sigh desperately."
        room.options = { n = 'Go North; entering the woods.' }
        return state
    end
end

locations = makeFSM({
    { 'cave',     'examine', 'cave',     fruitless_examination },
    { 'cave',     'south',   'river',    cave_south_river },
    { 'clearing', 'east',    'rivulet',  clearing_east_rivulet },
    { 'clearing', 'examine', 'clearing', clearing_examine_clearing },
    { 'clearing', 'south',   'meadow',   clearing_south_meadow },
    { 'ground',   'examine', 'ground',   fruitless_examination },
    { 'ground',   'north',   'woods',    ground_north_woods },
    { 'meadow',   'catch',   'meadow',   meadow_catch_meadow },
    { 'meadow',   'north',   'clearing', meadow_north_clearing },
    { 'meadow',   'south',   'meadow',   meadow_south_meadow },
    { 'meadow',   'west',    'meadow',   meadow_west_meadow },
    { 'pit',      'examine', 'pit',      pit_examine_pit },
    { 'pit',      'west',    'river',    pit_west_river },
    { 'river',    'east',    'pit',      river_east_pit },
    { 'river',    'examine', 'river',    river_examine_river },
    { 'river',    'north',   'cave',     river_north_cave },
    { 'river',    'south',   'woods',    river_south_woods },
    { 'river',    'west',    'rivulet',  river_west_rivulet },
    { 'rivulet',  'east',    'river',    rivulet_east_river },
    { 'rivulet',  'examine', 'rivulet',  rivulet_examine_rivulet },
    { 'rivulet',  'west',    'clearing', rivulet_west_clearing },
    { 'tree',     'climb',   'woods',    tree_climb_woods },
    { 'tree',     'examine', 'tree',     tree_examine_tree },
    { 'woods',    'climb',   'tree',     woods_climb_tree },
    { 'woods',    'examine', 'woods',    woods_examine_woods },
    { 'woods',    'north',   'river',    woods_north_river },
    { 'start',    'begin',   'ground',   start_begin_ground }
})

roomswithenemies = {
    'cave',
    'clearing'
}

commands = {
    n = 'north',
    s = 'south',
    e = 'east',
    w = 'west',
    x = 'examine'
}

enemytypes = {
    'wolf_cub',
    'small_wolf',
    'wolf',
    'large_wolf'
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

game = {
    done = false,
    stop = false,
    name = nil,
    defaultname = 'Hiccup',
    introtext = wrap("\nWelcome {name}, You are riding your dragon over a tree on a hill. Suddenly you bump into the tree. Your dragon flies one way, and you fall, with the tree breaking your fall.")
}

inventory = {}

actions = actions or {}

local conditions = {
    milesinthemeadow = 0,
    bait = false
}


-- The start of creating an action: making the fishing rod
local function makefishingrod (step)
    return function (t)
        return function ()
            local r = stringifyaction(t)
            if step == 'vine_to_branch' then
                r = r .. '\n\n[The vine is now attached to the branch.]'
                deleteinventoryitem({
                    'the_strong_thin_vine',
                    'the_branch'
                })
                insertinventoryitem('the_branch_and_vine')
            elseif step == 'hook_to_vine' then
                r = r .. '\n\n[The the hook shaped bone is now attached to the vine.]'
                deleteinventoryitem({
                    'the_strong_thin_vine',
                    'the_hook_shaped_bone'
                })
                insertinventoryitem('the_hook_and_vine')
            elseif step == 'hook_to_branch_and_vine' then
                r = r .. "\n\n[Clever you; you've made a fishing rod.]"
                deleteinventoryitem({
                    'the_branch_and_vine',
                    'the_hook_shaped_bone'
                })
                insertinventoryitem('the_fishing_rod')
            elseif step == 'hook_and_vine_to_branch' then
                r = r .. "\n\n[Clever you; you've made a fishing rod.]"
                deleteinventoryitem({
                    'the_hook_and_vine',
                    'the_branch'
                })
                insertinventoryitem('the_fishing_rod')
            end
            return r
        end
    end
end

insertaction(
    actions,
    {
        verbs = {
            'put',
            'use',
        },
        nouns = {
            first = { 'the_strong_thin_vine' },
            second = { 'the_branch' }
        },
        predicates = {
            'on',
            'to',
            'with',
        }
    },
    makefishingrod('vine_to_branch')
)
insertaction(
    actions,
    {
        verbs = {
            'put',
            'use',
        },
        nouns = {
            first = { 'the_hook_and_vine' },
            second = { 'the_branch' }
        },
        predicates = {
            'on',
            'to',
            'with',
        }
    },
    makefishingrod('hook_and_vine_to_branch')
)
insertaction(
    actions,
    {
        verbs = {
            'put',
            'use',
        },
        nouns = {
            first = { 'the_hook_shaped_bone' },
            second = { 'the_strong_thin_vine' }
        },
        predicates = {
            'on',
            'to',
            'with',
        }
    },
    makefishingrod('hook_to_vine')
)
insertaction(
    actions,
    {
        verbs = {
            'put',
            'use',
        },
        nouns = {
            first = { 'the_hook_shaped_bone' },
            second = { 'the_branch_and_vine' }
        },
        predicates = {
            'on',
            'to',
            'with',
        }
    },
    makefishingrod('hook_to_branch_and_vine')
)

-- The start of creating an action: lighting the unlit torch
local function lighttorch (step)
    lighttorchsteps = {
        cloth_on_torch = false,
        flint_and_rock_over_tinder = false,
        tinder_to_cloth = false
    }
    return function (t)
        return function ()
            local r = stringifyaction(t)
            lighttorchsteps[step] = true
            if step == 'tinder_to_cloth' then
                if not (lighttorchsteps['flint_and_rock_over_tinder']
                    and lighttorchsteps['cloth_on_torch'])
                then
                    for k, _ in pairs(lighttorchsteps) do
                        lighttorchsteps[k] = false
                    end
                    r = failedaction(t)
                end
            elseif step == 'flint_and_rock_over_tinder' then
                r = r .. '\n\n[The tinder is now smoldering.]'
                deleteinventoryitem('the_tinder')
                insertinventoryitem('the_smoldering_tinder')
            elseif step == 'cloth_on_torch' then
                r = r .. '\n\n[You made a wrapped unlit torch out of the fishing rod.]'
                deleteinventoryitem({ 'the_oil_imbued_cloth', 'the_fishing_rod' })
                insertinventoryitem('the_wrapped_torch')
            end
            local check = true
            for k, v in pairs(lighttorchsteps) do
                if not v then check = false end
                break
            end
            if check then
                r = r .. '\n\n[The torch is now lit. (Good job.)]'
                deleteinventoryitem({ 'the_wrapped_torch', 'the_smoldering_tinder' })
                insertinventoryitem({ 'the_lit_torch', 'the_tinder' })
            end
            return r
        end
    end
end

insertaction(
    actions,
    {
        verbs = {
            'put',
            'use',
        },
        nouns = {
            first = { 'the_oil_imbued_cloth' },
            second = { 'the_fishing_rod' }
        },
        predicates = {
            'on',
            'over',
            'with',
        }
    },
    lighttorch('cloth_on_torch')
)
insertaction(
    actions,
    {
        verbs = {
            'hit'
        },
        nouns = {
            first = { 'the_flint_and_rock' },
            second = { 'the_tinder' }
        },
        predicates = {
            'over'
        }
    },
    lighttorch('flint_and_rock_over_tinder')
)
insertaction(
    actions,
    {
        verbs = {
            'drop',
            'push',
            'put',
            'throw',
            'touch',
            'use',
        },
        nouns = {
            first = { 'the_smoldering_tinder' },
            second = { 'the_wrapped_torch' }
        },
        predicates = {
            'on',
            'over',
            'to',
            'with',
        }
    },
    lighttorch('tinder_to_cloth')
)

-- The start of creating an action: fishing with the fishing rod
local function fishing (effective)
    return function (t)
        return function ()
            local r = stringifyaction(t)
            if effective then
                if detectinventoryitem('the_small_fly') or conditions.bait then
                    if not conditions.bait then
                        r = r .. '\n\nYou use the small fly as bait.'
                    else
                        conditions.bait = false
                    end
                    if math.random(1, 10) > 6 then
                        r = r .. '\n\n[You catch a fish.]'
                        if detectinventoryitem('the_nice_big_fish') then
                            r = r .. '\n\n[Since you already had a fish you eat this one; it was good.]'
                        else
                            insertinventoryitem('the_nice_big_fish')
                        end
                    else
                        r = r .. '\n\nNo fish and the fly is gone too. Better luck next time.'
                    end
                    deleteinventoryitem('the_small_fly')
                else
                    r = r .. '\n\nYou stand around for what feels like hours only to realize that you will catch nothing without bait.'
                end
            else
                r = r .. '\n\nPLUNK. The fishing rod slowly sinks to the bottom of the river. It takes awhile but you finally succeed at fishing for the fishing rod. (It was a good thing that the river is shallow.)'
            end
            return r
        end
    end
end

insertaction(
    actions,
    {
        verbs = {
            'push',
            'put',
            'touch',
            'use',
        },
        nouns = {
            first = { 'the_fishing_rod' },
            second = { 'the_river' }
        },
        predicates = {
            'at',
            'in',
            'on',
            'over',
            'to',
            'with',
            'under',
        }
    },
    fishing(true)
)
insertaction(
    actions,
    {
        verbs = {
            'drop',
            'throw',
        },
        nouns = {
            first = { 'the_fishing_rod' },
            second = { 'the_river' }
        },
        predicates = {
            'after',
            'apart_from',
            'at',
            'before',
            'in',
            'on',
            'over',
            'to',
            'with',
            'under',
        }
    },
    fishing(false)
)

-- The start of creating an action: getting the oil imbued cloth
local function oilimbuethecloth ()
    return function (t)
        return function ()
            local r = stringifyaction(t)
            r = r .. '\n\n[You have oil imbued the cloth.]'
            insertinventoryitem('the_oil_imbued_cloth')
            deleteinventoryitem({ 'the_fish_liver', 'thin_strip_of_cloth' })
            return r
        end
    end
end

insertaction(
    actions,
    {
        verbs = {
            'push',
            'put',
            'touch',
            'use',
        },
        nouns = {
            first = { 'the_fish_liver' },
            second = { 'thin_strip_of_cloth' }
        },
        predicates = {
            'at',
            'in',
            'on',
            'over',
            'to',
            'with',
            'under',
        }
    },
    oilimbuethecloth()
)

-- The start of creating an action: getting the liver
local function disembowelthefish ()
    return function (t)
        return function ()
            local r = stringifyaction(t)
            r = r .. "\n\n[You have removed the fish's liver.]"
            insertinventoryitem('the_fish_liver')
            return r
        end
    end
end

insertaction(
    actions,
    {
        verbs = {
            'push',
            'put',
            'touch',
            'use',
        },
        nouns = {
            first = { 'the_flint' },
            second = { 'the_nice_big_fish' }
        },
        predicates = {
            'at',
            'in',
            'on',
            'over',
            'to',
            'with',
            'under',
        }
    },
    disembowelthefish()
)

-- The start of creating an action: bait
local function bait ()
    return function (t)
        return function ()
            local r = stringifyaction(t)
            r = r .. '\n\n[You have baited the hook.]'
            deleteinventoryitem('the_small_fly')
            conditions.bait = true
            return r
        end
    end
end

insertaction(
    actions,
    {
        verbs = {
            'push',
            'put',
            'touch',
            'use',
        },
        nouns = {
            first = { 'the_small_fly' },
            second = {
                'the_fishing_rod',
                'the_hook_shaped_bone',
                'the_hook_and_vine'
            }
        },
        predicates = {
            'at',
            'in',
            'on',
            'over',
            'to',
            'with',
            'under',
        }
    },
    bait()
)

go()
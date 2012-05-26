require 'adventure'

game = {
    done = false,
    stop = false,
    defaultname = 'Tulkas',
    introtext = '\nWelcome {name}, to the shortest adventure ever.\n\nWhen your mother passed away your father brought you to this sad little land.\n"For a better life", he said. But this backward place has exiled your father.\nYou were away on an errand and were not at home when it happened.\nWhat little knowledge you have of this awful event you received by reading\na very short note hurriedly scrawled.\n\n\t"Dearest {name},\n\t    My homing ring is in dread cave.\n\tPutting it on you will come to me. Hurry...\n\n\t-- Your loving Dad"'
}

local goodclicks = {
    '[You hear a crisp click that echoes throughout the cave.]\n\n',
    '[You hear the sharp click of stone on stone.]\n\n',
    '[A satisfying click is heard.]\n\n',
    '[You hear a reassuring click off in the distance.]\n\n'
}

local badclicks = {
    '[You hear a faint grating sound.]\n\n',
    '[You hear a feeble rasping sound.]\n\n',
    '[You hear a dull scraping sound.]\n\n',
    '[You hear an awkward grinding sound.]\n\n'
}

local function atrium_south_intersection (event, state)
    return function ()
        gbl.description = 'It takes a moment for your eyes to adjust to the comparative darkness. You feel the coolness of the breeze upon your back.\n\nYou hear the sound of water to the East, the Southern opening is very dim, and to the North the largest opening whence comes the cool breeze.'
        gbl.options = {
            n = 'Go North; towards the natural atrium.',
            e = 'Go East; following the sounds of water.',
            w = 'Go West; back to the cleared cave-in.'
        }
        if not gbl.conditions.rockslide then
            gbl.options['s'] = 'Go South; towards the darkest opening.'
        end
        deleteinventoryitem('the_empty_sconce')
        return state
    end
end

local function chamber_east_intersection (event, state)
    return function ()
        gbl.description = 'Finally able to stand you unfold yourself stretching out and looking around. This is a cavernous space with sparkling stalactites hanging from its roof. You can dimly see that you are at a sort of intersection; openings head off in all directions.\n\nYou hear the sound of water to the East, the Southern opening is very dim, and to the North the largest opening whence comes the cool breeze.'
        gbl.options = {
            n = 'Go North; towards the largest opening and the breeze.',
            e = 'Go East; following the sounds of water.',
            w = 'Go West; back to the cleared cave-in.'
        }
        gbl.conditions.enemies = true
        if not gbl.conditions.rockslide then
            gbl.options['s'] = 'Go South; towards the darkest opening.'
        end
        return state
    end
end

local function chamber_west_crawlspace (event, state)
    return function ()
        gbl.description = 'Dusting yourself off you are back in the dark of the crawlspace. Your back hurts.'
        gbl.options = {
            w = 'Go West; back to the passage (where you can stand up).'
        }
        if gbl.conditions.cleared then
            gbl.options['e'] = 'Go East; still not an easy path.'
        elseif gbl.conditions.cavein then
            gbl.options['e'] = 'Go East; to see the dead-end. (Why you would do that?)'
        end
        return state
    end
end

local function crawlspace_east_chamber (event, state)
    return function ()
        gbl.options = {
            w = 'Go West; backing out of the collapsed chamber.'
        }
        if gbl.conditions.cleared then
            gbl.description = "It's an even tighter squeeze but with the cave-in cleared you shimmy by."
            gbl.options['e'] = 'Go East; continue squeezing on through.'
        elseif (gbl.conditions.cavein and not detectinventoryitem('the_pickax')) then
            gbl.description = 'Looks just like it did a moment ago only caved-in.'
        else
            gbl.description = 'You crawl in to a tight chamber beyond the crawlspace. The ground begins to shake, a roaring fills your ears, dust obscures your vision. When the dust settles you see a cave-in that makes further progress impossible.'
            gbl.conditions.cavein = true
        end
        if gbl.conditions.nsew > 1 and gbl.conditions.nsew < 6 then
            gbl.conditions.nsew = 1
            gbl.description = badclicks[math.random(#badclicks)] .. gbl.description
        end
        insertinventoryitem('the_rocks')
        return state
    end
end

local function crawlspace_west_passage (event, state)
    return function ()
        gbl.description = 'You are back in the entry passage. You feel much safer.'
        gbl.options = {
            n = 'Go North; continuing down the passage.',
            e = 'Go East; entering the foreboding crawlspace.',
            s = 'Go South; back to the entrance.',
        }
        if gbl.conditions.nsew == 5 then
            gbl.conditions.nsew = 6
            gbl.description = 'You hear the sound of gears meshing and turning ending in a resounding click.\n\nAn rock door swings open revealing an alcove.\n\n' .. gbl.description
        elseif gbl.conditions.nsew > 0 and gbl.conditions.nsew < 6 then
            gbl.conditions.nsew = gbl.conditions.nsew + 1
            gbl.description = goodclicks[math.random(#goodclicks)] .. gbl.description
        end
        return state
    end
end

local function entrance_north_passage (event, state)
    return function ()
        gbl.description = 'As you creep down the passage you feel the breeze coming from the East. There is a foreboding looking crawlspace from which the air is emanating.'
        gbl.options = {
            n = 'Go North; continuing down the passage.',
            e = 'Go East; entering the foreboding crawlspace.',
            s = 'Go South; back to the entrance.',
        }
        if gbl.conditions.nsew > 0 and gbl.conditions.nsew < 6 then
            gbl.conditions.nsew = gbl.conditions.nsew + 1
            gbl.description = goodclicks[math.random(#goodclicks)] .. gbl.description
        end
        return state
    end
end

local function entrance_south_outside (event, state)
    return function ()
        gbl.description = 'You have left the cave; scared?'
        gbl.options = {
            n = 'Go North; return to the cave.'
        }
        return state
    end
end

local function impasse_south_passage (event, state)
    return function ()
        gbl.description = 'You are back in the entry passage; and are not happy about going in the foreboding crawlspace.'
        gbl.options = {
            n = 'Go North; uselessly continuing down the dead-end passage.',
            e = 'Go East; entering the foreboding crawlspace.',
            s = 'Go South; back to the entrance.',
        }
        if gbl.conditions.nsew > 0  and gbl.conditions.nsew < 6 then
            gbl.conditions.nsew = gbl.conditions.nsew + 1
            gbl.description = goodclicks[math.random(#goodclicks)] .. gbl.description
        end
        return state
    end
end

local function intersection_east_lake (event, state)
    return function ()
        gbl.description = 'A lazily lapping subterranean lake bars any further exploration in this direction.'
        gbl.options = {
            w = 'Go West; slipping and stumbling.'
        }
        if gbl.conditions.raft then gbl.options['n'] = 'Go North; on the raft.' end
        if gbl.conditions.swim then
            gbl.description = gbl.description .. '\n\nYou stand well away from the edge.'
            if gbl.conditions.raft then gbl.description = gbl.description .. '\n\nBut there is that raft...' end
        else
            gbl.description = gbl.description .. "\n\nAs you walk closer to the edge of the water your foot slips. Suddenly you slide careening into the lake's slimy water. As it envelopes you panic starts to take hold. You start flailing thinking you will never come up for air again. You calm yourself and finally make it back to the edge. Clawing and scrabbling for a hold on the slippery bank you finally scramble up. Sopping wet but alive.\n\nAs you lie gasping you notice a raft."
            gbl.conditions.swim = true
            gbl.conditions.wet = true
        end
        return state
    end
end

local function intersection_north_atrium (event, state)
    return function ()
        if gbl.conditions.atrium then
            gbl.description = 'The cool breeze is a welcome change of pace. The empty sconce awaits in the center of the door.'
        else
            gbl.description = 'You have found the source of the cool breeze. The very center of the roof is open to the now evening sky. Dim light, bright as a noon day after the comparative darkness, streams in from above. You are immediately reminded of an atrium with stalactites and stalagmites meeting and forming the pillars of a natural colonnade going around the whole of the area.'
            gbl.conditions.atrium = true
        end
        gbl.options = {
            s = 'Go South; returning to the intersection.'
        }
        insertinventoryitem('the_empty_sconce')
        return state
    end
end

local function intersection_south_rockslide (event, state)
    return function ()
        gbl.description = "You go south scrambling over piles of rocks. It is obvious that there have been rock-slides in the past. You say to yourself that they were in the distant past; but you know better.\n\nSuddenly you hear a rumbling.\n\nCrash!\n\nROCKSLIDE!\n\nEven running you'll barely escape with your life."
        gbl.options = {
            n = 'Go North; RUN!'
        }
        gbl.conditions.rockslide = true
        return state
    end
end

local function intersection_west_chamber (event, state)
    return function ()
        gbl.description = 'You crawl in to a tight chamber beyond the crawlspace. you can see an intersection ahead.'
        gbl.options = {
            e = 'Go East; to the intersection.',
            w = 'Go West; back to the crawlspace.'
        }
        return state
    end
end

local function lake_north_river (event, state)
    return function ()
        gbl.description = 'You are riding on the raft in the center of a narrow, moving river.'
        gbl.options = {
            n = 'Go North; to the unknown and beyond!'
        }
        gbl.conditions.wet = false
        return state
    end
end

local function lake_west_intersection (event, state)
    return function ()
        gbl.description = 'Back in the intersection.'
        gbl.options = {
            n = 'Go North; towards the largest opening and the breeze.',
            e = "Go East; following the sounds of water. (Fancy a swim?)",
            w = 'Go West; back to the cleared cave-in.'
        }
        if gbl.conditions.wet then
            gbl.description = gbl.description .. ' You are soaking wet and definitely regretting your fall in to the lake.'
            gbl.conditions.wet = false
        end
        if not gbl.conditions.rockslide then
            gbl.options['s'] = 'Go South; towards the darkest opening.'
        end
        return state
    end
end

local function outside_north_entrance (event, state)
        return function ()
        gbl.description = 'You have bravely entered the cave. You are in the entry passage. A strange cool breeze is coming from the North.'
        gbl.options = {
            n = 'Go North; continuing down the passage.',
            s = 'Go South; exiting the cave.',
        }
        return state
    end
end

local function passage_east_crawlspace (event, state)
    return function ()
        if detectinventoryitem('the_lit_torch') then
            gbl.description = 'Getting on your hands and knees you put the flaming torch in to your mouth and squeeze in to the crawlspace. Coughing from the oily flame you nearly singe off whatever facial hair you have.'
        else
            gbl.description = 'Getting on your hands and knees you squeeze in to the crawlspace. It is pitch black. As you crawl you cannot even see the backs of your hands on the ground in front of your face. You feel very unsafe.'
        end
        gbl.options = {
            w = 'Go West; back to the passage.',
            e = 'Go East; tight chamber.'
        }
        if gbl.conditions.nsew == 4 then
            gbl.conditions.nsew = 5
            gbl.description = goodclicks[math.random(#goodclicks)] .. gbl.description
        elseif gbl.conditions.nsew < 4 and gbl.conditions.nsew > 0 then
            gbl.conditions.nsew = 1
            gbl.description = badclicks[math.random(#badclicks)] .. gbl.description
        end
        return state
    end
end

local function passage_north_impasse (event, state)
    return function ()
        if (gbl.conditions.impasse or detectinventoryitem('the_pickax')) then
            gbl.description = 'Still impassable...'
        else
            gbl.description = 'You have reached an impasse; solid rock. No amount of digging or climbing is going to buy passage.'
            gbl.conditions.impasse = true
        end
        gbl.options = {
            s = 'Go South; returning back to the passage.'
        }
        if gbl.conditions.nsew == 2 then
            gbl.conditions.nsew = 3
            gbl.description = goodclicks[math.random(#goodclicks)] .. gbl.description
        end
        return state
    end
end

local function passage_south_entrance (event, state)
    return function ()
        gbl.description = 'You are back in the entry passage.'
        gbl.options = {
            n = 'Go North; back down the passage.',
            s = 'Go South; exiting the cave.',
        }
        if (gbl.conditions.nsew > 0 and gbl.conditions.nsew < 6) then
            gbl.conditions.nsew = 1
            gbl.description = badclicks[math.random(#badclicks)] .. gbl.description
        end
        return state
    end
end

local function rapids_north_waterfall (event, state)
    return function ()
        gbl.description = 'You plunge head over raft in to an abyss.\n\n\nTHE END'
        game.done = true
        return state
    end
end

local function rapids_south_river (event, state)
    return function ()
        gbl.description = 'You paddle hard callousing both hands and winding yourself. With every muscle aching you manage to make landfall at the narrow edge. Exhausted you fall to the ground.'
        gbl.options = {
            s = 'Go South; ditching the raft to go back to the lake on foot.'
        }
        gbl.conditions.raft = false
        return state
    end
end

local function river_north_rapids (event, state)
    return function ()
        gbl.description = 'The water is getting dangerously fast. You are having second thoughts.'
        gbl.options = {
            s = 'Go South; returning to the slower flowing river.',
            n = 'Go North; continue in to the unknown!'
        }
        return state
    end
end

local function river_south_lake (event, state)
    return function ()
        gbl.description = "It's hard going but you slide and slip along the embankment back to the lake."
        gbl.options = {
            w = 'Go West; to the spacious and dry intersection.'
        }
        return state
    end
end

local function rockslide_north_intersection (event, state)
    return function ()
        gbl.description = "Wow! You just made it by the skin of your teeth! The South passage is completely blocked. And no, the pickax is not going to help. In fact it is whimpering."
        gbl.options = {
            n = 'Go North; towards the largest opening and the cool air current.',
            e = 'Go East; following the sounds of water.',
            w = 'Go West; back to the cleared cave-in.'
        }
        return state
    end
end

local function impasse_examine_impasse (event, state)
    return function ()
        if (gbl.conditions.impasse and gbl.conditions.cavein and not detectinventoryitem('the_pickax')) then
            print(wrap('\n\nYou start to examine the area, but you sit down in despair. Will you ever find the one thing that can reunite you to your beloved father?\n\nPutting your head in your hands you lean forward and see something half covered in the dim floor of an alcove. Moving the dirt and debris you see a rusted discarded pickax on the floor.\n\n(Pickax taken.)\n\n'))
            insertinventoryitem('the_pickax')
        else
            print('\nYour examination is fruitless.\n')
        end
        entertocontinue()
        return state
    end
end

local function passage_examine_passage (event, state)
    return function ()
        if gbl.conditions.nsew == 6 then
            print(wrap('\n\nIn the alcove you see a flint and steel, tinder, and an oil imbued strip of cloth.\n\n(You take the components.)\n\n'))
            insertinventoryitem({
                'the_flint_and_steel',
                'the_oil_imbued_cloth',
                'the_tinder'
            })
        else
            print('\nYour examination is fruitless.\n')
        end
        entertocontinue()
        return state
    end
end

local function atrium_examine_atrium (event, state)
    return function ()
        if not detectinventoryitem('the_unlit_torch') then
            print(wrap('\n\nAt the center of the North wall is the outline of a door made of the rock face. There is no doorknob, no hinges, no obvious way to open the door. The only feature is an empty sconce in the center of the door.\n\nAn unlit torch lies upon the floor next to deeply scrawled letters, "NSEW".\n\n(You take the unlit torch.)\n\n'))
            gbl.conditions.nsew = 1
            insertinventoryitem('the_unlit_torch')
        else
            print(wrap('\n\nAt the center of the North wall is the outline of a door made of the rock face. There is no doorknob, no hinges, no obvious way to open the door. The only feature is an empty sconce in the center of the door.\n\nOn the floor are deeply scrawled letters, "NSEW".\n\n'))
        end
        entertocontinue()
        return state
    end
end

local function start_begin_outside (event, state)
    return function ()
        gbl.description = 'You stand at the south entrance of the dread cave.'
        gbl.options = {
            n = 'Go North; entering the cave.'
        }
        return state
    end
end

locations = makeFSM({
    { 'atrium',       'examine', 'atrium',       atrium_examine_atrium },
    { 'atrium',       'south',   'intersection', atrium_south_intersection },
    { 'chamber',      'east',    'intersection', chamber_east_intersection },
    { 'chamber',      'examine', 'chamber',      fruitless_examination },
    { 'chamber',      'west',    'crawlspace',   chamber_west_crawlspace },
    { 'crawlspace',   'east',    'chamber',      crawlspace_east_chamber },
    { 'crawlspace',   'examine', 'crawlspace',   fruitless_examination },
    { 'crawlspace',   'west',    'passage',      crawlspace_west_passage },
    { 'entrance',     'examine', 'entrance',     fruitless_examination },
    { 'entrance',     'north',   'passage',      entrance_north_passage },
    { 'entrance',     'south',   'outside',      entrance_south_outside },
    { 'impasse',      'examine', 'impasse',      impasse_examine_impasse },
    { 'impasse',      'south',   'passage',      impasse_south_passage },
    { 'intersection', 'east',    'lake',         intersection_east_lake },
    { 'intersection', 'examine', 'intersection', fruitless_examination },
    { 'intersection', 'north',   'atrium',       intersection_north_atrium },
    { 'intersection', 'south',   'rockslide',    intersection_south_rockslide },
    { 'intersection', 'west',    'chamber',      intersection_west_chamber },
    { 'lake',         'examine', 'lake',         fruitless_examination },
    { 'lake',         'north',   'river',        lake_north_river },
    { 'lake',         'west',    'intersection', lake_west_intersection },
    { 'outside',      'examine', 'outside',      fruitless_examination },
    { 'outside',      'north',   'entrance',     outside_north_entrance },
    { 'passage',      'east',    'crawlspace',   passage_east_crawlspace },
    { 'passage',      'examine', 'passage',      passage_examine_passage },
    { 'passage',      'north',   'impasse',      passage_north_impasse },
    { 'passage',      'south',   'entrance',     passage_south_entrance },
    { 'rapids',       'examine', 'rapids',       fruitless_examination },
    { 'rapids',       'north',   'waterfall',    rapids_north_waterfall },
    { 'rapids',       'south',   'river',        rapids_south_river },
    { 'river',        'examine', 'river',        fruitless_examination },
    { 'river',        'north',   'rapids',       river_north_rapids },
    { 'river',        'south',   'lake',         river_south_lake },
    { 'rockslide',    'examine', 'rockslide',    fruitless_examination },
    { 'rockslide',    'north',   'intersection', rockslide_north_intersection },
    { 'start',        'begin',   'outside',      start_begin_outside }
})

actions = {}

-- The start of creating an action: clearing the cave-in
local function clearcavein (effective)
    local times = 1
    return function (t)
        return function ()
            local r = stringifyaction(t)
            if effective then
                if times > 1 then
                    r = r .. '\n\nYou have cleared away the cave-in.'
                    gbl.conditions.cleared = true
                    gbl.description = "It's an even tighter squeeze but with the cave-in cleared you shimmy by."
                    gbl.options['e'] = 'Go East; continue squeezing on through.'
                    deleteinventoryitem('the_rocks')
                else
                    r = r .. "\nIt's working. Some of the rocks are being cleared. It's going to take awhile, but with that pickax you could make it through."
                end
                times = times + 1
            else
                r = r .. ' Wow, is that all you got?\n\n(This is one of those rare times when more force is the answer.)'
            end
            return r
        end
    end
end

insertaction(
    actions,
    {
        verbs = {
            'drop',
            'pull',
            'push',
            'put',
            'throw',
            'touch',
            'use'
        },
        nouns = {
            first = {
                'the_rocks',
                'the_pickax'
            },
            second = {
                'the_rocks',
                'the_pickax'
            }
        },
        predicates = {
            'at',
            'in',
            'on',
            'to',
            'with'
        }
    },
    clearcavein(false)
)
insertaction(
    actions,
    {
        verbs = {
            'hit'
        },
        nouns = {
            first = { 'the_rocks' },
            second = { 'the_pickax' }
        },
        predicates = {
            'with'
        }
    },
    clearcavein(true)
)
insertaction(
    actions,
    {
        verbs = {
            'hit'
        },
        nouns = {
            first = { 'the_pickax' },
            second = { 'the_rocks' }
        },
        predicates = {
            'at',
            'on',
            'to'
        }
    },
    clearcavein(true)
)

-- The start of creating an action: lighting the unlit torch
local function lighttorch (step)
    return function (t)
        return function ()
            local r = stringifyaction(t)
            gbl.conditions[step] = true
            if step == 'tinder_to_cloth' then
                if not (gbl.conditions['flint_and_rock_over_tinder']
                    and gbl.conditions['cloth_on_torch'])
                then
                    gbl.conditions.cloth_on_torch = false
                    gbl.conditions.flint_and_rock_over_tinder = false
                    gbl.conditions.tinder_to_cloth = false
                    r = failedaction(t)
                end
            elseif step == 'flint_and_rock_over_tinder' then
                r = r .. '\n\n[The tinder is now smoldering.]'
                deleteinventoryitem('the_tinder')
                insertinventoryitem('the_smoldering_tinder')
            elseif step == 'cloth_on_torch' then
                r = r .. '\n\n[The unlit torch is now wrapped.]'
                deleteinventoryitem({ 'the_oil_imbued_cloth', 'the_unlit_torch' })
                insertinventoryitem('the_wrapped_torch')
            end
            local check = (
                gbl.conditions.cloth_on_torch and
                gbl.conditions.flint_and_rock_over_tinder and
                gbl.conditions.tinder_to_cloth
            )
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
            second = { 'the_unlit_torch' }
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
            first = { 'the_flint_and_steel' },
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

-- The start of creating an action: putting the lit torch in the sconce
local function torchinsconce ()
    return function (t)
        return function ()
            local r = ''
            local s = '\n\n[The lit torch is now permanently affixed in the sconce.]\n\nYou place the lit torch in the empty sconce. The door noiselessly swings inward on hidden hinges revealing a courtyard ringed with rock. In the center is a glowing pedestal upon which resides the ring. Placing the ring upon your finger a blinding flame of light envelops you whisking you away to your waiting father.\n\n\nTHE END'
            print('\n' .. wrap(s))
            game.done = true
            game.stop = true
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
            'use',
        },
        nouns = {
            first = { 'the_lit_torch' },
            second = { 'the_empty_sconce' }
        },
        predicates = {
            'in',
            'on',
            'to',
            'with',
        }
    },
    torchinsconce()
)

go({
    name = nil,
    roomswithenemies = {
        'atrium',
        'chamber',
        'crawlspace',
        'entrance',
        'impasse',
        'intersection',
        'lake',
        'passage',
        'rockslide'
    },
    commands = {
        n = 'north',
        s = 'south',
        e = 'east',
        w = 'west',
        i = 'inventory',
        x = 'examine'
    },
    enemytypes = {
        'mouse',
        'squirrel',
        'rat',
        'badger'
    },
    inventory = {
    },
    conditions = {
        impasse = false,
        cavein = false,
        cleared = false,
        rockslide = false,
        swim = false,
        wet = false,
        atrium = false,
        nsew = 0,
        raft = true,
        cloth_on_torch = false,
        flint_and_rock_over_tinder = false,
        tinder_to_cloth = false
    }
},
-- configuration for the fighting sub-engine
{
    hero = {
        hitmin = 3, -- where you start -- heroattack = math.random(cfg.hero.hitmin, cfg.hero.hitmax)
        hitmax = 5, -- max bad-ass-ness -- heroattack = math.random(cfg.hero.hitmin, cfg.hero.hitmax)
        tohit = 5 -- what the hero has to beat to hit the enemy -- heroattack > cfg.hero.tohit
    },
    enemy = {
        hitmin = 2, -- enemyattack = math.random(cfg.enemy.hitmin, cfg.enemy.hitmax)
        hitmax = 7, -- enemyattack = math.random(cfg.enemy.hitmin, cfg.enemy.hitmax)
        mintohit = 4, -- the min of what an enemy has to beat to hit the hero (the enemy is savage)
        maxtohit = 5, -- the max of what an enemy has to beat to hit the hero (the enemy is menacing)
        minhp = 1, -- the min hit points for an enemy (this matches the enemytypes)
        maxhp = 4, -- the max hit points for an enemy (this matches the enemytypes)
        hitmod = 3 -- the diff between the maxtohit and the two types of enemies (menacing, savage)
    }
})
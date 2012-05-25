math.randomseed(os.time())

local function iter (list_or_iter)
    if type(list_or_iter) == "function" then return list_or_iter end

    return coroutine.wrap (function()
        for i = 1, #list_or_iter do
            coroutine.yield(list_or_iter[i])
        end
    end)
end

local function each (list, func)
    for i in iter(list) do
        func(i)
    end
    return list
end

local function detect (list, func)
    for i in iter(list) do
        if func(i) then return i end
    end
    return nil
end

local function reject (list, func)
    local selected = {}
    for i in iter(list) do
        if not func(i) then selected[#selected + 1] = i end
    end
    return selected
end

-- leave as is, please
room = {
    location = '',
    description = '',
    options = {},
}

local allverbs = {
    'drop',
    'hit',
    'pull',
    'push',
    'put',
    'throw',
    'touch',
    'use',
}

local allpredicates = {
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

function insertaction (dst, src, f)
    for _, verb in pairs(src.verbs) do
        if dst[verb] == nil then
            dst[verb] = {}
        end
        for _, first in pairs(src.nouns.first) do
            if dst[verb][first] == nil then
                dst[verb][first] = {}
            end
            for _, predicate in pairs(src.predicates) do
                if dst[verb][first][predicate] == nil then
                    dst[verb][first][predicate] = {}
                end
                for _, second in pairs(src.nouns.second) do
                    if first ~= second then
                         dst[verb]
                            [first]
                            [predicate]
                            [second] = f({
                                verb,
                                first,
                                predicate,
                                second
                            })
                    end
                end
            end
        end
    end
end

local function failedaction(t)
    local verb, first, predicate, second = unpack(t)
    local r = string.gsub(
        'You tried to ' ..
        verb .. ' ' ..
        first .. ' ' ..
        predicate .. ' ' ..
        second ..
        " but it accomplished nothing.",
        '_',
        ' '
    )
    if verb == 'eat' then
        r = string.gsub(
            'You tried to ' ..
            verb .. ' ' ..
            first .. ' ' ..
            "but it accomplished nothing.\n(Other than make a disgusting mess when you realized you couldn't eat " .. first .. " and you spat it back out.)",
            '_',
            ' '
        )
    end
    return r
end

function deleteinventoryitem(t)
    if type(t) ~= 'table' then t = { t } end
    each(
        t,
        function (target)
            inventory = reject(
                inventory,
                function (item)
                    return item == target
                end
            )
        end
    )
end

function detectinventoryitem(item)
    return detect(inventory, function (i) return i == item end )
end

function insertinventoryitem(t)
    if type(t) ~= 'table' then t = { t } end
    each(
        t,
        function (new)
            if not detectinventoryitem(new) then table.insert(inventory, new) end
        end
    )
end

function stringifyaction(t)
    local verb, first, predicate, second = unpack(t)
    return string.gsub(
        'You ' ..
        verb .. ' ' ..
        first .. ' ' ..
        predicate .. ' ' ..
        second ..
        '.',
        '_',
        ' '
    )
end

local function tryaction(t)
    local verb, first, predicate, second = unpack(t)
    local r = failedaction(t)
    if actions[verb]
        and actions[verb][first]
        and actions[verb][first][predicate]
        and actions[verb][first][predicate][second] then
        r = actions[verb][first][predicate][second]()
    end
    return r
end

local function ununderscore (s)
    s = s:gsub('_', ' ')
    return s
end

function inventoryprompt(text, t, dst, test)
    text = text or 'one'
    test = test or function () return true end
    local r = ''
    local valid = {}
    table.sort(t)
    table.sort(inventory)
    repeat
        if (text:lower()):find('verb') then
            print('You can access the following items:\n')
            for _, v in pairs(inventory) do
                io.write('  ' .. ununderscore(v) .. '\n')
            end
            print()
        end
        print('Pick ' .. text .. ':')
        for i = 1, #t do
            if test(t[i]) then
                valid[i] = true
                print(
                    '\t' ..
                    i ..
                    ' ' ..
                    string.rep('.', 4) ..
                    ' ' ..
                    ununderscore(t[i])
                )
            end
        end
        print('\tx .... to exit')
        io.write('  --> ')
        r = string.lower(io.read())
        r = (r == 'x' and r or tonumber(r))
        print(((valid[r] or r == 'x') and '' or 'Invalid Response.\n'))
    until valid[r] or r == 'x'
    inventoryresponse[dst] = (r == 'x' and r or t[r])
end

function enterinventory()
    repeat
        if #inventory < 1 then
            print('\nYou have no items and there are no items here to interact with.')
            break
        elseif #inventory < 2 then
            print('You have access to the following items:\n')
            for _, v in pairs(inventory) do
                io.write('  ' .. ununderscore(v) .. '\n')
            end
            break
        else
            inventoryresponse = {
                verb = "",
                first = "",
                predicate = "",
                second = "",
            }

            inventoryprompt('a verb', allverbs, 'verb')
            if inventoryresponse.verb == 'x' then break end
            inventoryprompt('the first noun', inventory, 'first')
            if inventoryresponse.first == 'x' then break end
            inventoryprompt('an action', allpredicates, 'predicate')
            if inventoryresponse.predicate == 'x' then break end
            inventoryprompt(
                'a second noun',
                inventory,
                'second',
                function (second)
                    return second ~= inventoryresponse.first
                end
            )
            if inventoryresponse.second == 'x' then break end

            print(
                tryaction({
                    inventoryresponse.verb,
                    inventoryresponse.first,
                    inventoryresponse.predicate,
                    inventoryresponse.second
                })
            )

            if not (game.stop or game.done) then
                print("\n\tType 'x' to exit.\n\tHit [enter] to continue.")
            end
        end
    until string.lower(io.read()) == 'x' or game.stop or game.done
end

function makeFSM (t)
    local a = {}
    for _, v in ipairs(t) do
        local old, event, state, action = v[1], v[2], v[3], v[4]
        if a[old] == nil then a[old] = {} end
        a[old][event] = { state = state, action = action(event, state) }
    end
    return a
end

local function reportstate (event, state)
    local a = {
        "'re_",
        "'ve_been_",
        '_were_',
        '_got_'
    }
    local b = {
        '_feel_',
        "'ve_become_",
        '_are_now_',
        '_seem_'
    }
    local function getone (t)
        return string.gsub(t[math.random(1, #t)], '_', ' ')
    end
    local report = 'You' .. getone(a) .. event .. ' and you' .. getone(b) ..
          (event == 'healed' and 'only ' or '') .. state:gsub('_', ' ') .. '.'
    return function ()
        return {
            report = (state == 'healthy' and 'You are totally healed.' or report),
            state = state
        }
    end
end

kombat = makeFSM({
    { 'healthy',            'hit',    'lightly_wounded',    reportstate },
    { 'lightly_wounded',    'hit',    'seriously_wounded',  reportstate },
    { 'seriously_wounded',  'hit',    'grievously_wounded', reportstate },
    { 'grievously_wounded', 'hit',    'mortally_wounded',   reportstate },
    { 'mortally_wounded',   'hit',    'dead',               reportstate },
    { 'mortally_wounded',   'healed', 'grievously_wounded', reportstate },
    { 'grievously_wounded', 'healed', 'seriously_wounded',  reportstate },
    { 'seriously_wounded',  'healed', 'lightly_wounded',    reportstate },
    { 'lightly_wounded',    'healed', 'healthy',            reportstate }
})

local function reportprowess (event, state)
    local a = {
        '_feel',
        "'ve_become",
        '_are_now',
        '_seem'
    }
    return function ()
        return {
            report = 'You' .. string.gsub(a[math.random(1, #a)], '_', ' ') ..
                ' ' .. state:gsub('_', ' ') .. '.',
            state = state
        }
    end
end

prowesses = {
    'wimpy',
    'less_wimpy',
    'even_less_wimpy',
    'almost_dangerous',
    'dangerous',
    'very_dangerous',
    'lethal',
    'very_lethal'
}
local t = {}
for i = 1, #prowesses do
    if i < #prowesses then
        table.insert(t, { prowesses[i], 'trained', prowesses[i + 1], reportprowess })
    end
    prowesses[prowesses[i]] = (i / 2)
end
experience = makeFSM(t)

hero = {
    health = {
        state = 'healthy',
        report = ''
    },
    prowess = {
        state = 'wimpy',
        report = ''
    }
}

local function fight ()
    local stop = false

    local function makeenemy ()
        local ferocity = {
            'a_savage_',
            'a_menacing_'
        }
        local enemy = {
            hp = math.random(cfg.enemy.minhp, cfg.enemy.maxhp),
            tohit = math.random(cfg.enemy.mintohit, cfg.enemy.maxtohit),
            description = '',
            type = ''
        }
        enemy.type = string.gsub(enemytypes[enemy.hp], '_', ' ')
        enemy.description = string.gsub(ferocity[enemy.tohit - cfg.enemy.hitmod], '_', ' ') .. enemy.type
        return enemy
    end

    local enemy = makeenemy()
    local line = '\n' .. string.rep('*', 80)
    print(line .. '\n\tYou are attacked by ' .. enemy.description .. '!' .. line)
    repeat
        local heroattack = math.random(cfg.hero.hitmin, cfg.hero.hitmax) + prowesses[hero.prowess.state]
        if heroattack > cfg.hero.tohit then
            print('\n\tYou hit the ' .. enemy.type .. '.\n')
            enemy.hp = enemy.hp - 1
        else
            print('\n\tYou attack the ' .. enemy.type .. ' but it dodges out of the way.\n')
        end
        if enemy.hp < 1 then
            print('\tYou have killed ' .. enemy.description .. '.\n')
            stop = true
        else
            local enemyattack = math.random(cfg.enemy.hitmin, cfg.enemy.hitmax)
            if enemyattack >= enemy.tohit then
                hero.health = kombat[hero.health.state]['hit'].action()
                print('\t' .. hero.health.report .. '\n')
            else
                print('\tThe ' .. enemy.type .. ' misses you.\n')
            end
        end
        if (hero.health.state == 'dead' or enemy.hp == 0) then
            stop = true
        end
        entertocontinue()
    until stop
    if hero.health.state == 'dead' then
        game.stop = true
        room.description = ''
        room.options = {}
    else
        if hero.prowess.state ~= 'very_lethal' and hero.prowess.state ~= 'dead' then
            hero.prowess = experience[hero.prowess.state]['trained'].action()
            print('\n\t[' .. hero.prowess.report .. ']\n')
            entertocontinue()
        end
    end
end

function deletecommand(k)
    commands[k] = nil
end

function insertcommand(k, v)
    commands[k] = v
end

function entertocontinue ()
    print(string.rep('_', 80))
    io.write('\tHit [enter] to continue.')
    io.read()
    print('\n')
end

function fruitless_examination (event, state)
    return function ()
        print('\nYour examination is fruitless.\n')
        entertocontinue()
        return state
    end
end

function wrap (str, limit, indent01, indent02)
    local str = str:gsub('\n', '#@')
    str = str:gsub('#@', '\n')
    indent01 = indent01 or ''
    indent02 = indent02 or indent01
    limit = limit or 80
    local here = 1 - #indent02
    return indent02 .. str:gsub(
        '(%s+)()(%S+)()',
        function(sp, st, word, fi)
            if fi-here > limit then
                here = st - #indent01
                return '\n' .. indent01 .. word
            end
        end
    )
end

prompt = (function ()
    local r = ''

    local function exitmsg ()
        print('\n\nHit [enter] to exit.')
        io.read()
    end

    local function pairsByKeys (t, f)
        local a = {}
        for n in pairs(t) do table.insert(a, n) end
        table.sort(a, f)
        local i = 0
        local iter = function ()
            i = i + 1
            if a[i] == nil then return nil
            else return a[i], t[a[i]]
            end
        end
        return iter
    end

    local function duh (response)
        local wisecracks = {
            "You've got time to waste, huh?",
            "A hollow voice says 'PLUGH'",
            "You can read can't you?",
            "Is it really that hard?",
            "Why do I get all the slow learners?",
            "See that thing with the letters on it?\n\n\tGood! Now see that list of options?\n\n\tFind the letter and push it.",
            "Hey, monkey, off the computer!",
            game.name .. ", seriously?",
            "Why not just try typing 'win'?",
            "BONK!\n\n\tYou run right in to solid rock.\n\n\tYour nose is bleeding.\n\n\tHappy now?",
            game.name ..", really... it's not that hard."
        }
        local wisecrack = wisecracks[math.random(1, #wisecracks)]
        local line =  '\n' .. string.rep('=', 80) .. '\n'
        if response == 'win' or response == 'xyzzy' then
            print(line .. "\n\tPoof you won! Not!\n\n\tGood try, but that is an old worn-out magic word.\n" .. line)
        else
            print('\n' .. line .. '\n\t'.. wisecrack .. '\n\n\tTry an option actually listed.\n' .. line)
        end
    end

    local function intro ()
        print('  Enter your name:\n  (Or hit [enter] for ' .. game.defaultname .. '.)')
        io.write(' --> ')
        game.name = io.read()

        if game.name == '' then game.name = game.defaultname end
        local s = game.introtext:gsub('{name}', game.name)
        print(s)
    end

    return function ()
        if not game.name then intro() end
        local isenemy = (roomswithenemies[math.random(1, #roomswithenemies)] == room.location)
        if isenemy then fight() end

        if not game.stop then
            local line = '\n' .. string.rep('-', 80) .. '\n'
            local header = line .. room.location:upper() .. line
            print(header)

            print( wrap(room.description))

            if not game.done then
                room.options.q = 'Quit'
                room.options.x = 'Examine'
                room.options.i = 'Inventory'
                print('\n  Your options are:')
                for k, v in pairsByKeys(
                        room.options,
                        function (a, b)
                            return room.options[a] < room.options[b]
                        end
                    ) do
                    print(' ', k, v)
                end

                io.write(' --> ')
                r = io.read()

                if not isenemy then
                    if hero.health.state ~= 'healthy' then
                        hero.health = kombat[hero.health.state]['healed'].action()
                        print('\n\t[' .. hero.health.report .. ']\n')
                        entertocontinue()
                    end
                end
            else
                exitmsg()
            end
        else
            exitmsg()
        end

        r = (room.options[r] or r == 'win' or r == 'xyzzy') and r or ''
        if not game.stop and (r == '' or r == 'win' or r == 'xyzzy') then duh(r) end

        return r
    end
end)()

function go ()
    local previousaction = locations['start']['begin'].action
    local previousresponse = ''
    local response = ''
    room.location = previousaction()
    repeat
        previousresponse = response
        response = string.lower(prompt())
        --print(response, commands[response])
        if response == 'q' or game.stop or game.done then break end
        if response == 'i' then
            enterinventory()
            if previousresponse ~= '' and previousresponse ~= 'x' and previousresponse ~= 'i' then
                previousaction()
            end
        elseif commands[response] then
            previousaction = locations[room.location][commands[response]].action
            room.location = locations[room.location][commands[response]].action()
        end
    until game.stop
end
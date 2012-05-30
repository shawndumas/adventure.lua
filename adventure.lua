math.randomseed(os.time())

gbl = {}
cfg = {}

--============================================
-- generic utility functions
--============================================
local function iter (t)
  if type(t) == "function" then return t end

  return coroutine.wrap (function()
    for i = 1, #t do
      coroutine.yield(t[i])
    end
  end)
end

local function each (t, f)
  for i in iter(t) do
    f(i)
  end
  return t
end

local function detect (t, f)
  for i in iter(t) do
    if f(i) then return i end
  end
  return nil
end

local function reject (t, f)
  local _ = {}
  for i in iter(t) do
    if not f(i) then _[#_ + 1] = i end
  end
  return _
end

local function extend (dst, src)
  for k, v in pairs(src) do
    if type(v) == 'table' then
      dst[k] = {}
      extend (dst[k], v)
    else
      dst[k] = v
    end
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

function makeFSM (t)
  local a = {}
  for _, v in ipairs(t) do
    local old, event, state, action = v[1], v[2], v[3], v[4]
    if a[old] == nil then a[old] = {} end
    a[old][event] = { state = state, action = action(event, state) }
  end
  return a
end

local function fileexists (filename)
  local f, e = io.open(filename)
  local r = f ~= nil
  if f then f:close() end
  return r
end

local function writefile (filename, s)
  local f, e = io.open(filename, 'w')
  f:write(s)
  f:close()
  return true
end

local function readfile (filename)
  local f, e = io.open(filename, 'r')
  local s, e = f:read('*a')
  f:close()
  return s
end

function tabletostring (t)
  local set = ' = '
  local space = '  '
  local lines = {}
  local line = ''
  local tables = {}

  local function quoteifnecessary (v)
    if not v then
      return ''
    else
    if v:find ' ' then v = '"' .. v .. '"' end
    end
    return v
  end

  local function iskeyword (s)
    return
      type(s) == 'string' and
      s:find('^[%a_][%w_]*$') and
      not ({
        ["and"]      = true,
        ["break"]    = true,
        ["do"]       = true,
        ["else"]     = true,
        ["elseif"]   = true,
        ["end"]      = true,
        ["false"]    = true,
        ["for"]      = true,
        ["function"] = true,
        ["if"]       = true,
        ["in"]       = true,
        ["local"]    = true,
        ["nil"]      = true,
        ["not"]      = true,
        ["or"]       = true,
        ["repeat"]   = true,
        ["return"]   = true,
        ["then"]     = true,
        ["true"]     = true,
        ["until"]    = true,
        ["while"]    = true
      })[s]
  end

  local function quote (s)
    if type(s) == 'table' then
      return tabletostring(s, '')
    else
      return ('%q'):format(tostring(s))
    end
  end

  local function index (numkey, key)
    if not numkey then key = quote(key) end
    return '['..key..']'
  end

  local function put(s)
    if #s > 0 then
      line = line..s
    end
  end

  local function putln (s)
    if #line > 0 then
      line = line..s
      table.insert(lines, line)
      line = ''
    else
      table.insert(lines, s)
    end
  end

  local function eatlastcomma ()
    local n,lastch = #lines
    local lastch = lines[n]:sub(-1, -1)
    if lastch == ',' then
      lines[n] = lines[n]:sub(1, -2)
    end
  end

  local stringify
  stringify = function (t, oldindent, indent)
    local typ = type(t)
    if typ ~= 'string' and  typ ~= 'table' then
      putln(quoteifnecessary(tostring(t)) .. ',')
    elseif typ == 'string' then
      if t:find('\n') then
        putln('[[\n' .. t .. ']],')
      else
        putln(quote(t) .. ',')
      end
    elseif typ == 'table' then
      if tables[t] then
        putln('<cycle>,')
        return
      end
      tables[t] = true
      local newindent = indent .. space
      putln('{')
      local used = {}
      for i,val in ipairs(t) do
        put(indent)
        stringify(val, indent, newindent)
        used[i] = true
      end
      for key,val in pairs(t) do
        local numkey = type(key) == 'number'
        if not numkey or not used[key] then
          if numkey or not iskeyword(key) then
            key = index(numkey, key)
          end
          put(indent .. key .. set)
          stringify(val, indent, newindent)
        end
      end
      eatlastcomma()
      putln(oldindent .. '},')
    else
      putln(tostring(t) .. ',')
    end
  end
  stringify(t, '', space)
  eatlastcomma()
  return table.concat(lines, #space > 0 and '\n' or '')
end

--============================================
-- adventure.lua specific utility functions
--============================================
function entertocontinue ()
  print(string.rep('_', 80))
  io.write('\tHit [enter] to continue.')
  io.read()
  print('\n')
end

local function ununderscore (s)
  s = s:gsub('_', ' ')
  return s
end

function deletecommand(k)
  gbl.commands[k] = nil
end

function insertcommand(k, v)
  gbl.commands[k] = v
end

function fruitless_examination (event, state)
  return function ()
    print('\nYour examination is fruitless.\n')
    entertocontinue()
    return state
  end
end

--============================================
-- inventory / actions
--============================================
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

function deleteinventoryitem(t)
  if type(t) ~= 'table' then t = { t } end
  each(
    t,
    function (target)
      gbl.inventory = reject(
        gbl.inventory,
        function (item)
          return item == target
        end
      )
    end
  )
end

function detectinventoryitem(item)
  return detect(gbl.inventory, function (i) return i == item end )
end

function insertinventoryitem(t)
  if type(t) ~= 'table' then t = { t } end
  each(
    t,
    function (new)
      if not detectinventoryitem(new) then table.insert(gbl.inventory, new) end
    end
  )
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

-- inventory UI
function inventoryprompt(text, t, dst, test)
  text = text or 'one'
  test = test or function () return true end
  local r = ''
  local valid = {}
  table.sort(t)
  table.sort(gbl.inventory)
  repeat
    if (text:lower()):find('verb') then
      print('You can access the following items:\n')
      for _, v in pairs(gbl.inventory) do
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
    if #gbl.inventory < 1 then
      print('\nYou have no items and there are no items here to interact with.')
      break
    elseif #gbl.inventory < 2 then
      print('You have access to the following items:\n')
      for _, v in pairs(gbl.inventory) do
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
      inventoryprompt('the first noun', gbl.inventory, 'first')
      if inventoryresponse.first == 'x' then break end
      inventoryprompt('an action', allpredicates, 'predicate')
      if inventoryresponse.predicate == 'x' then break end
      inventoryprompt(
        'a second noun',
        gbl.inventory,
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

--============================================
-- fighting
--============================================
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
  { 'healthy',      'hit',  'lightly_wounded',  reportstate },
  { 'lightly_wounded',  'hit',  'seriously_wounded',  reportstate },
  { 'seriously_wounded',  'hit',  'grievously_wounded', reportstate },
  { 'grievously_wounded', 'hit',  'mortally_wounded',  reportstate },
  { 'mortally_wounded',  'hit', 'dead',        reportstate },
  { 'mortally_wounded',  'healed', 'grievously_wounded', reportstate },
  { 'grievously_wounded', 'healed', 'seriously_wounded',  reportstate },
  { 'seriously_wounded',  'healed', 'lightly_wounded',  reportstate },
  { 'lightly_wounded',  'healed', 'healthy',      reportstate }
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

-- fighting UI
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
    enemy.type = string.gsub(gbl.enemytypes[enemy.hp], '_', ' ')
    enemy.description = string.gsub(ferocity[enemy.tohit - cfg.enemy.hitmod], '_', ' ') .. enemy.type
    return enemy
  end

  local enemy = makeenemy()
  local line = '\n' .. string.rep('*', 80)
  print(line .. '\n\tYou are attacked by ' .. enemy.description .. '!' .. line)
  repeat
    local heroattack = math.random(cfg.hero.hitmin, cfg.hero.hitmax) + prowesses[gbl.prowess.state]
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
        gbl.health = kombat[gbl.health.state]['hit'].action()
        print('\t' .. gbl.health.report .. '\n')
      else
        print('\tThe ' .. enemy.type .. ' misses you.\n')
      end
    end
    if (gbl.health.state == 'dead' or enemy.hp == 0) then
      stop = true
    end
    entertocontinue()
  until stop
  if gbl.health.state == 'dead' then
    game.stop = true
    gbl.description = ''
    gbl.options = {}
  else
    if gbl.prowess.state ~= 'very_lethal' and gbl.prowess.state ~= 'dead' then
      gbl.prowess = experience[gbl.prowess.state]['trained'].action()
      print('\n\t[' .. gbl.prowess.report .. ']\n')
      entertocontinue()
    end
  end
end

--============================================
-- main UI
--============================================
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
      gbl.name .. ", seriously?",
      "Why not just try typing 'win'?",
      "BONK!\n\n\tYou run right in to solid rock.\n\n\tYour nose is bleeding.\n\n\tHappy now?",
      gbl.name ..", really... it's not that hard."
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
    print(' Enter your name:\n  (Or hit [enter] for ' .. game.defaultname .. '.)')
    io.write(' --> ')
    gbl.name = io.read()

    if gbl.name == '' then gbl.name = game.defaultname end
    local s = game.introtext:gsub('{name}', gbl.name)
    print(s)
  end

  return function ()
    if not gbl.name then intro() end
    local isenemy = (gbl.roomswithenemies[math.random(1, #gbl.roomswithenemies)] == gbl.location)
    if isenemy then fight() end

    if not game.stop then
      local line = '\n' .. string.rep('-', 80) .. '\n'
      local header = line .. ununderscore(gbl.location:upper()) .. line
      print(header)

      print(wrap(gbl.description))

      if not game.done then
        gbl.options.q = 'Quit'
        gbl.options.x = 'Examine'
        gbl.options.i = 'Inventory'
        if game.filename and game.filename ~= '' then
          gbl.options.v = 'Save'
          gbl.options.l = 'Load'
        end
        print('\n Your options are:')
        for k, v in pairsByKeys(
            gbl.options,
            function (a, b)
              return gbl.options[a] < gbl.options[b]
            end
          ) do
          print(' ', k, v)
        end

        io.write(' --> ')
        r = io.read()

        if not isenemy then
          if gbl.health.state ~= 'healthy' then
            gbl.health = kombat[gbl.health.state]['healed'].action()
            print('\n\t[' .. gbl.health.report .. ']\n')
            entertocontinue()
          end
        end
      else
        exitmsg()
      end
    else
      exitmsg()
    end

    r = (gbl.options[r] or r == 'win' or r == 'xyzzy') and r or ''
    if not game.stop and (r == '' or r == 'win' or r == 'xyzzy') then duh(r) end

    return r
  end
end)()

--============================================
-- main loop
--============================================
function go (g, c)
  extend(gbl, g)
  extend(gbl, {
    location = '',
    description = '',
    options = {},
    health = {
      state = 'healthy',
      report = ''
    },
    prowess = {
      state = 'wimpy',
      report = ''
    },
    previousresponse = ''
  })
  extend(cfg, c)
  local previousaction = locations['start']['begin'].action
  local response = ''
  gbl.location = previousaction()
  repeat
    gbl.previousresponse = response
    response = string.lower(prompt())
    if response == 'q' or game.stop or game.done then break end
    if response == 'i' then
      enterinventory()
      if
        gbl.previousresponse ~= '' and
        ({ i = false, l = false, v = false, x = false })[gbl.previousresponse]
      then
        previousaction()
      end
    elseif response == 'v' then
      writefile(game.filename, tabletostring(gbl))
      print('\n\nGame saved.')
      entertocontinue()
    elseif response == 'l' then
      if fileexists(game.filename) then
        assert(loadstring('gbl = ' .. readfile(game.filename)))()
        print('\n\nGame loaded.')
        entertocontinue()
      else
        print('\n\nNo saved game file to load.')
        entertocontinue()
      end
    elseif gbl.commands[response] then
      previousaction = locations[gbl.location][gbl.commands[response]].action
      gbl.location = locations[gbl.location][gbl.commands[response]].action()
    end
  until game.stop
end
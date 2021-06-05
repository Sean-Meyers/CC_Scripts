-- Contains functions, classes, variables used
-- by the custom UI startup program.

local menu = {}

--------------------------------------------------
-- Print text centered on the screen
--
-- Vertical offset can be specified to print
-- higher or lower. If specified, the text can be
-- printed slowly.
--
-- Parameters:
--    text  <string>: The text to write.
--    h_off <number>: Vertical offset, default 0.
--    slow <boolean>: Whether to print slow,
--                    default false.
--
function menu.print_centered(text, h_off, slow)

    -- Set defaults
    h_off = h_off or 0
    slow = slow or false

    -- Determine print position
    local w, h = term.getSize()
    w = (w / 2) - (#text / 2)
    h = (h / 2) + h_off

    -- Print to screen
    term.setCursorPos(w, h)
    if slow then
        textutils.slowPrint(text)
    else
        print(text)
    end

    term.setCursorPos(w, h + 1)
end

--------------------------------------------------
-- Class Menu
--
--
menu.Menu = {}
menu.Menu.__index = menu.Menu

    ----------------------------------------------
    --
    function menu.Menu:init(x, y, w, h, parent)

        local self = {}
        setmetatable(self, menu.Menu)

        self.x = x
        self.y = y
        self.w = w
        self.h = h

        self.parent = parent

        self.window = window.create(
            term.current(), self.x, self.y,
            self.w, self.h, false
        )

        -- Initialize default attributes
        self.bg = term.getBackgroundColor()
        self.border = self.bg
        self.title = {text  = '',
                      color = term.getTextColor()}

        self.buttons = {}
        setmetatable(self.buttons,
                                {__index = table})

        return self
    end    -- End of init()


    ----------------------------------------------
    --
    function menu.Menu:draw()

        -- Set menu as current terminal

        print(term.current())

        local parent_cur_x, parent_cur_y
                             = term.getCursorPos()
        local parent = term.redirect(self.window)

        -- Catch errors
        local status, err
        = pcall(
                -- Anon. func. for error handling
                function ()

                  -- Set background color
                  self.window.setBackgroundColor(
                                           self.bg)
                  self.window.clear()

                  -- Draw menu border
                  paintutils.drawBox(1, 1,
                                     self.w,
                                     self.h,
                                     self.border)

                  -- Draw menu title
                  self.window.setCursorPos(2, 1)

                  self.window.setTextColor(
                                 self.title.color)

                  self.window.write(
                                  self.title.text)

                  -- Draw menu buttons
                  for i, v in ipairs(self.buttons)
                      do
                      --print(i, 'text', #v.text, 'color', #v.text_color, 'bg', #v.text_bg)
                      v:draw()
                  end

                  self.window.setVisible(true)

                end  -- End of anon. func.
               )     -- End of call to pcall()

        -- Restore previous terminal to current
        term.redirect(parent)
        term.setCursorPos(parent_cur_x,
                                     parent_cur_y)

        -- Throw any caught errors
        if not status then
            error(err, 0)
        end

    end    -- End of draw()


    ----------------------------------------------
    --
    function menu.Menu:set_title(text, color)
        self.title.text = text
        self.title.color = color
    end


    ----------------------------------------------
    --
    function menu.Menu:create_button(x, y, w, h)

        -- Set menu to current terminal
        local parent = term.redirect(self.window)

        -- Catch errors
        local status, err
        = pcall(
                -- Anon. func. for error handling
                function ()

                    -- Instantiate button object
                    button
                    = menu.Button:init(x, y,
                                       w, h, self)

                end
            )     -- End of call to pcall()

        local butt = button
        button = nil

        -- Restore previous term to current
        term.redirect(parent)

        -- Throw any caught errors
        if not status then
            error(err, 0)
        end

        self.buttons:insert(butt)

        return butt

    end    -- End of create_button()

--End of Menu Class-------------------------------


--------------------------------------------------
-- Class Button
--
--
menu.Button = {}
menu.Button.__index = menu.Button

    ----------------------------------------------
    --
    --
    -- Parameters
    --
    --      parent <menu.Menu>:
    --              Allows accessing the parent
    --              menu's term object to aqcuire
    --              coords relative to native.
    --              (TODO: fix this crappy
    --              description)
    function menu.Button:init(x, y, w, h, parent)

        local self = {}
        setmetatable(self, menu.Button)

        -- Button position and size, should be
        -- updated if either is changed
        self.x = x
        self.y = y
        self.w = w
        self.h = h

        self.parent = parent

        self.window = window.create(
                            term.current(),
                            self.x, self.y,
                            self.w, self.h, false)

        -- Invert text and bg colors for contrast
        -- by default
        self.bg = term.getTextColor()
        self.border = self.bg

        self.text_color = colors.toBlit(
                        term.getBackgroundColor())

        self.text_bg = colors.toBlit(self.bg)
        self.text = ''

        -- State as in pressed, not pressed,
        -- pressed once, twice, under some
        -- condition, can have flexible meanings
        self.state = 0
        -- TODO: possibly add visibility and
        --       selected state flags.

        self.actions = {}

        return self
    end    -- End of Button:init()


    ----------------------------------------------
    --
    function menu.Button:set_text(arg)

        local text = {}
        setmetatable(text, {__index = table})
        local color = {}
        setmetatable(color, {__index = table})
        local bg = {}
        setmetatable(bg, {__index = table})

        -- Parse arguments
        for i, v in ipairs(arg) do

            -- Prepare containers and data
            local t_len = #(v.text or {})
            local all_vars =
            {
                c_vars =
                {
                    #(v.color or {}), color,
                    v.color, self.text_color
                },

                b_vars =
                {
                    #(v.bg or {}), bg,
                    v.bg, self.text_bg
                }
            }

            text:insert(v.text)

            -- Determine whether the strings are
            -- suitable for passing to
            -- term.blit(), and modify them if not
            for k, l in pairs(all_vars) do

                -- If wrong length of color strings
                if t_len > l[1] then

                    -- If color string arg is given
                    if l[1] >= 1 then

                        l[2]:insert(
                            self.text_pad_last(
                                            nil,
                                            l[3],
                                            t_len)
                        ) -- End of insert() call

                    else
                        l[2]:insert(
                            self.text_pad_last(
                                            nil,
                                            l[4],
                                            t_len)
                        ) -- End of insert() call
                    end
                else
                    -- If length is appropriate.
                    l[2]:insert(l[3])
                end

            end -- End of inner for loop

        end -- End of outer for loop (arg parsing)

        -- Build final strings to pass to blit()
        self.text = text:concat()
        self.text_color = table.concat(color)
        self.text_bg = table.concat(bg)
    end    -- End of set_text()


    ----------------------------------------------
    -- Given a string, ensure it has a certain
    -- length by repeating the last char in the
    -- string.
    --
    -- Parameters:
    --    text <string>: The string to pad.
    --    len <number>:  How long the string
    --                   should be.
    --
    -- Return the new padded string <string>.
    --
    function menu.Button:text_pad_last(text, len)

        return text .. (text:sub(#text):rep(
                                     len - #text))
    end


    ----------------------------------------------
    --
    function menu.Button:draw()

        -- Set button as current terminal
        local parent_cur_x, parent_cur_y
                             = term.getCursorPos()
        local parent = term.redirect(self.window)

        -- Catch errors
        local status, err
        = pcall(
                -- Anon. func. for error handling
                function ()

                  -- Draw button background.
                  self.window.setBackgroundColor(
                                           self.bg)
                  term.clear()

                  -- Draw button border.
                  paintutils.drawBox(1, 1,
                                     self.w,
                                     self.h,
                                     self.border)

                  -- Draw button text.
                  self.window.setCursorPos(2, 1)

                  if #self.text > 0 then
                      if #self.text
                          ~= #self.text_color
                          or #self.text
                              ~= #self.text_bg
                          then
                          term.write('blit error')
                      else
                          self.window.blit(
                                      self.text,
                                self.text_color,
                                      self.text_bg)
                      end
                  end
                  self.window.setVisible(true)
                end    -- End of anon. func.
               )    -- End of pcall() call.

        -- TODO: consider returning coords and/or
        --       modifying states for use by an
        --       event handler.

        -- Restore previous terminal to current
        term.redirect(parent)
        term.setCursorPos(parent_cur_x,
                                     parent_cur_y)
        -- Throw any caught errors
        if not status then
            error(err, 0)
        end

    end    -- End of draw()


    ----------------------------------------------
    -- Add a function to a button's action table
    --
    -- This provides a documented interface for
    -- adding event-action pairs to the action
    -- table. Otherwise accessing the table
    -- directly is just as good.
    --
    -- Parameters:
    --      event <string>: The event to be used
    --                      with os.pullEvent()
    --      func <function>: The function to be
    --                       executed when event
    --                       is pulled.
    function menu.Button:set_action(event, func)

        self.actions[event] = func
    end


    ----------------------------------------------
    --
    function menu.Button:execute_action(some_func)
        -- Where some func is an instance variable
        -- that has a function assigned to it.
        -- This is meant to be used by the event
        -- handler. It may also just be better to
        -- call the instance variables directly
        -- rather than through this function.
        -- TODO:
        print('todo')
    end

--End of Button Class-----------------------------


--------------------------------------------------
-- Class EventHandler
--
menu.EventHandler = {}
menu.EventHandler.__index = menu.EventHandler

    ----------------------------------------------
    --
    function menu.EventHandler:init()

        local self = {}
        setmetatable(self, menu.EventHandler)

        self.buttons = {}
        setmetatable(self.buttons,
                                {__index = table})

        return self
    end

    ----------------------------------------------
    --
    function menu.EventHandler:add_buttons(
                                         buttons)
        --debug
        --local c_x, c_y = term.getCursorPos()
        
        for i, v in ipairs(buttons) do
            local button = {}

            button['pos']
                        = {v.window.getPosition()}
            button['size'] = {v.window.getSize()}
            button['actions'] = v.actions

            button['size'][1]
                          = button['size'][1] - 1
            button['size'][2]
                          = button['size'][2] - 1

            --wip
            current = v.parent
            while true do
                if current == nil then
                    break
                else
                    local x, y
                    = current.window.getPosition()

                    button['pos'][1]
                        = button['pos'][1] + x - 1

                    button['pos'][2]
                        = button['pos'][2] + y - 1
                    
                    --debug
                    --term.setCursorPos(c_x, c_y)
                    --print('pos_x, pos_y: ',
                    --      button['pos'][1]..
                    --      ',', button['pos'][2])
                    --c_y = c_y + 1
                    --term.setCursorPos(c_x, c_y)
                    --print('offset x, y: ',
                    --                  x..',', y)
                    --c_y = c_y + 1
                    --term.setCursorPos(c_x, c_y)
                    --print('size w, h: ',
                    --      button['size'][1]..
                    --      ',', button['size'][2])
                    --c_y = c_y + 1
                    --if c_y > 15 then
                    --    c_y = 1
                    --end
                            
                    current = current.parent
                end
            end
            --end wip

            self.buttons:insert(button)
        end
    end

    ----------------------------------------------
    --
    function menu.EventHandler:handle_events()
        local event_data = {os.pullEvent()}
        local event = event_data[1]
        local x = event_data[3]
        local y = event_data[4]

        --debug
        --print(event)
        --c_x = 35
        --c_y = 1

        for i, v in ipairs(self.buttons) do
            x_start = v['pos'][1]
            y_start = v['pos'][2]

            x_end = v['pos'][1] + v['size'][1]
            y_end = v['pos'][2] + v['size'][2]

            --debug
            --term.setCursorPos(c_x, c_y)
            --c_y = c_y + 1
            --print(' start', x_start, y_start, ' ')
            --term.setCursorPos(c_x, c_y)
            --c_y = c_y + 1
            --print(' event', x, y, ' ')
            --term.setCursorPos(c_x, c_y)
            --c_y = c_y + 1
            --print(' end', x_end, y_end, ' ')
            --if c_y > 15 then
            --    c_y = 1
            --end

            if event == 'mouse_click' or
               event == 'mouse_up' then
                if (x >= x_start and x <= x_end)
                 and (y >= y_start and y <= y_end)
                then
                    if v['actions'][event] ~= nil
                    then
                        v['actions'][event]()
                        break
                    end
                end
            end
        end
    end

return menu

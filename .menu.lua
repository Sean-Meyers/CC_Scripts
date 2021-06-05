local menu = require('menu_lib')

-- Draw the home menu
local home = menu.Menu:init(2,4,15,15)
home.bg = colors.lightBlue
home.border = colors.cyan
home:set_title('Home', colors.brown)

-- Make the buttons
local button_paint
                 = home:create_button(3, 3, 11, 1)
button_paint.bg = colors.blue
button_paint.border = colors.blue
local text_data = {
                    {text = 'Paint',
                     color = '6',
                     bg = 'b'}
                  }                    
button_paint:set_text(text_data)

-- set button action
function paint()
    print('new image filename:')
    filename = io.read()
    if filename ~= 'exit' then
        local prog = shell.openTab('paint',
                                         filename)
        shell.switchTab(prog)
    end
end
button_paint:set_action('mouse_up', paint)

local button_shell
                 = home:create_button(3, 8, 11, 1)
text_data[1].text = 'Shell'
button_shell.border = colors.blue
button_shell:set_text(text_data)
                 
function terminal()
    local prog = shell.openTab('shell')
    shell.switchTab(prog)
end
button_shell:set_action('mouse_up', terminal)

local button_off = home:create_button(3, 13, 11, 1)
text_data[1].text = 'Shutdown'
button_off.border = colors.blue
button_off:set_text(text_data)

function shutdown()
    shell.run('shutdown')
end

button_off:set_action('mouse_up', shutdown)

-- Initialize event handler
local test_handler = menu.EventHandler:init()
test_handler:add_buttons(home.buttons)

home:draw()

while true do
    test_handler:handle_events()
end

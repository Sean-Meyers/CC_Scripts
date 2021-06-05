-- Starts the UI whenever the computer is turned
-- on.

local menu = require('menu_lib')

menu.print_centered('Booting up...')
menu.print_centered('#############', 1, true)
shell.run('.menu')

local file_args = {...}

local private = file_args[1]
local public = file_args[2]
local config = file_args[3]

--running alphaui as an addon to the existing interface instead of a replacer.
--this file creates an accessible UI for the various parts


return private, public, config
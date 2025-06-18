local actionlist = {}
local lastAction = 1
local dotimer = Timer()

local function actionhandler()
	if lastAction > #actionlist then
		lastAction = 1
	end
	
	if type(actionlist[lastAction]) == "function" then
		actionlist[lastAction]()
	end
	
	lastAction = lastAction + 1
	
	dotimer:SetTimeout(1, function() actionhandler() end)
	
end

actionhandler()



local function addTimedFunc(func)
	actionlist[#actionlist + 1] = func
	return addTimedFunc
end

local function remTimedFunc(index)
	for i=index, #actionlist do
		actionlist[i] = actionlist[i+1]
	end
end

return {
	addTimedFunc,
	remTimedFunc,
}
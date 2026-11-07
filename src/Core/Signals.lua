--[[
	Signals - a tiny synchronous event bus. Panels subscribe to store events
	instead of polling, which keeps the editor responsive.
]]

local Signals = {}
Signals.__index = Signals

type Handler = (any) -> ();

function Signals.new()
	return setmetatable({ _handlers = {} :: { [string]: { Handler } } }, Signals)
end

function Signals:on(event: string, handler: Handler): { disconnect: () -> () }
	local list = self._handlers[event]
	if not list then
		list = {}
		self._handlers[event] = list
	end
	table.insert(list, handler)

	local connection = {
		disconnect = function()
			local current = self._handlers[event]
			if not current then
				return
			end
			for index, item in ipairs(current) do
				if item == handler then
					table.remove(current, index)
					break
				end
			end
		end,
	}
	return connection
end

function Signals:fire(event: string, payload: any)
	local list = self._handlers[event]
	if not list then
		return
	end
	-- Copy so a handler may unsubscribe while we iterate.
	local snapshot = table.clone(list)
	for _, handler in ipairs(snapshot) do
		local ok, err = pcall(handler, payload)
		if not ok then
			warn("[VFX Studio] handler error on '" .. event .. "': " .. tostring(err))
		end
	end
end

function Signals:clear()
	self._handlers = {}
end

return Signals

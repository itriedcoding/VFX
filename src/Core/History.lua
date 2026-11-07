--[[
	History - two undo systems, because VFX Studio mutates two different things:

	1. The working spec (pure data). Tracked with an in-memory stack so slider
	   and field edits can be undone without touching the DataModel.
	2. Real instances in the place (export, insert, optimize). Tracked with
	   ChangeHistoryService recordings so Studio's own Ctrl+Z handles them.
]]

local Util = require(script.Parent.Util)

local History = {}
History.__index = History

type Entry = { label: string, snapshot: any };

function History.new(maxEntries: number?)
	return setmetatable({
		undoStack = {} :: { Entry },
		redoStack = {} :: { Entry },
		max = maxEntries or 64,
	}, History)
end

--- Records the state *before* a mutation. Call right before changing the spec.
function History:record(label: string, snapshot: any)
	table.insert(self.undoStack, { label = label, snapshot = Util.deepCopy(snapshot) })
	while #self.undoStack > self.max do
		table.remove(self.undoStack, 1)
	end
	self.redoStack = {}
end

--- Returns the previous snapshot, plus the label of the action undone.
function History:undo(current: any): (any?, string?)
	local entry = table.remove(self.undoStack)
	if not entry then
		return nil, nil
	end
	table.insert(self.redoStack, { label = entry.label, snapshot = Util.deepCopy(current) })
	return entry.snapshot, entry.label
end

function History:redo(current: any): (any?, string?)
	local entry = table.remove(self.redoStack)
	if not entry then
		return nil, nil
	end
	table.insert(self.undoStack, { label = entry.label, snapshot = Util.deepCopy(current) })
	return entry.snapshot, entry.label
end

function History:canUndo(): boolean
	return #self.undoStack > 0
end

function History:canRedo(): boolean
	return #self.redoStack > 0
end

function History:peekUndo(): string?
	local entry = self.undoStack[#self.undoStack]
	return entry and entry.label or nil
end

function History:peekRedo(): string?
	local entry = self.redoStack[#self.redoStack]
	return entry and entry.label or nil
end

function History:clear()
	self.undoStack = {}
	self.redoStack = {}
end

--- Wraps DataModel mutations in a ChangeHistoryService recording.
function History.beginRecording(name: string): any
	if ChangeHistoryService.TryBeginRecording then
		local ok, recording = pcall(function()
			return ChangeHistoryService:TryBeginRecording(name)
		end)
		if ok and recording then
			return recording
		end
	end
	return nil
end

function History.endRecording(recording: any, commit: boolean?)
	if recording and ChangeHistoryService.FinishRecording then
		local operation = Enum.FinishRecordingOperation.Commit
		if commit == false then
			operation = Enum.FinishRecordingOperation.Cancel
		end
		pcall(function()
			ChangeHistoryService:FinishRecording(recording, operation)
		end)
	elseif commit ~= false then
		pcall(function()
			ChangeHistoryService:SetWaypoint("VFX Studio")
		end)
	end
end

return History

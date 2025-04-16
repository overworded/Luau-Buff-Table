--------------------- // BUFF CLASS \\ ---------------------
---| Properties:
---|   Type (Buff identifier / name)
---|   Value (Value of buff, can be anything, but usually a number)
---|   Death time (when the buff no longer is alive)

local Buff = {}
Buff.__index = Buff

function Buff.new(Type: string, Value: any, Lifetime: number?)
	local self = setmetatable({}, Buff)

	self.Type = Type
	self.Value = Value
	self.Death = Lifetime and tick()+Lifetime or nil

	return self
end

function Buff:IsAlive()
	if self.Death then
		return tick() < self.Death
	end
	return true
end

--- Remove the buff from the list, patches the hole left by it as well
function Buff:Destroy()
	if self.Previous then
		self.Previous.Next = self.Next
	else-- first in list
		self.Table.List = self.Next
		self.Next.Table = self.Table
	end

	if self.Next then
		self.Next.Previous = self.Previous
	end
end

--------------------- // TABLE CLASS \\ ---------------------
---| Contains list of buffs.
---| each buff links to next buff as well as previous buff.
---| this may be refered to as a linked list.. i think?
---| idk i didnt really look into it i just typed what
---| the voices in my head told me to

local Table = {}
Table.__index = Table

function Table.new()
	local self = setmetatable({}, Table)

	self.List = nil

	return self
end

function Table:AddBuff(Type: string, Value: any, Lifetime: number?): {any}
	local NewBuff = Buff.new(Type, Value, Lifetime)
	
	if self.List == nil then
		NewBuff.Table = self
		self.List = NewBuff
		return NewBuff
	end

	local Current = self.List

	while Current.Next do -- find last in list
		Current = Current.Next
	end

	Current.Next = NewBuff
	NewBuff.Previous = Current

	return NewBuff
end

function Table:Print()
	local Current = self.List

	while Current do
		print(Current)
		Current = Current.Next
	end
end


function Table:Totals(): {[string]: any}
	local Buffs = {}
	
	if not self.List then
		return Buffs -- no buffs
	end

	local Current = self.List

	while Current do
		if Current:IsAlive() then
			Buffs[Current.Type] = (Buffs[Current.Type] or 0) + Current.Value
		else
			Current:Destroy()
		end
		Current = Current.Next
	end

	return Buffs
end

return Table

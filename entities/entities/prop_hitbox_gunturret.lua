AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "prop_deployablehitbox"

-- Give turret interaction a wider and slightly lower box so use traces are forgiving.
ENT.BoxMin = Vector(-28, -24, -8)
ENT.BoxMax = Vector(28, 24, 72)

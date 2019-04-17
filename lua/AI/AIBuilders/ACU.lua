local UCBC = '/lua/editor/UnitCountBuildConditions.lua'

local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Uveso/lua/AI/uvesoutilities.lua').GetDangerZoneRadii()

BuilderGroup {
    BuilderGroupName = 'UC ACU Attack Former',                                      -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
-- ================ --
--    ACU Former    --
-- ================ --
    Builder {
        BuilderName = 'UC CDR Attack',                                          -- Random Builder Name.
        PlatoonTemplate = 'CDR Attack',                                         -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates\"
        Priority = 19250,                                                       -- Priority. Higher priotity will be build more often then lower priotity.
        InstanceCount = 5,                                                      -- Number of plattons that will be formed with this template.
        BuilderData = {
            SearchRadius = 250,                                       -- Searchradius from main base for new target. (A 5x5 Map is 256 high)
--            ReturnToBaseAfterGameTime = 30,                                   -- Use this platoon only for the first 60 miutes.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AttackEnemyStrength = 400,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.ALLUNITS - (categories.ENGINEER * categories.TECH1 * categories.TECH2) - categories.AIR - categories.SCOUT , -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Attack these targets.
                'COMMAND',
                'EXPERIMENTAL',
                'INDIRECTFIRE, DIRECTFIRE',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  250, 'LocationType', 0, categories.ALLUNITS - (categories.ENGINEER * categories.TECH1 * categories.TECH2) - categories.AIR - categories.SCOUT }}, -- radius, LocationType, unitCount, categoryEnemy
            -- Don't build it if...
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.LAND - categories.SUPPORTFACTORY } },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}
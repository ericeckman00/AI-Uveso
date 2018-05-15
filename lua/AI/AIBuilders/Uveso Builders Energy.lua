-- Default economic builders for skirmish
local IBC = '/lua/editor/InstantBuildConditions.lua'
local SAI = '/lua/ScenarioPlatoonAI.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MABC = '/lua/editor/MarkerBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'

local MaxCapStructure = 0.14 -- 14% of all units can be structures (STRUCTURE -MASSEXTRACTION -DEFENSE -FACTORY)

-- ===================================================-======================================================== --
-- ==                                       Build Power TECH 1,2,3                                           == --
-- ===================================================-======================================================== --
BuilderGroup {
    -- Build Power TECH 1,2,3
    BuilderGroupName = 'EnergyBuilders Uveso',
    BuildersType = 'EngineerBuilder',
    -- ============ --
    --    TECH 1    --
    -- ============ --
    Builder {
        BuilderName = 'U1 Power Emergency',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 2100,
        DelayEqualBuildPlattons = {'Energy', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            { EBC, 'LessThanEconStorageRatio', { 2.00, 0.99}}, -- Ratio from 0 to 1. (1=100%)
            -- Have we the eco to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 } },
            { EBC, 'GreaterThanEconIncome',  { 1.0, 6.0}}, -- Absolut Base income
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.TECH1 } },
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
        },
        InstanceCount = 1,
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
--                AdjacencyCategory = categories.FACTORY * categories.STRUCTURE * (categories.AIR + categories.LAND),
                AdjacencyDistance = 50,
                BuildClose = false,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T1EnergyProduction',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U1 Power Emergency II',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 2100,
        DelayEqualBuildPlattons = {'Energy', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            { EBC, 'LessThanEconStorageRatio', { 2.00, 0.90}}, -- Ratio from 0 to 1. (1=100%)
            { UCBC, 'GreaterThanGameTimeSeconds', { 180 } },
            -- Have we the eco to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 } },
            { EBC, 'GreaterThanEconIncome',  { 1.0, 6.0}}, -- Absolut Base income
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.TECH1 } },
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
        },
        InstanceCount = 1,
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
--                AdjacencyCategory = categories.FACTORY * categories.STRUCTURE * (categories.AIR + categories.LAND),
                AdjacencyDistance = 50,
                BuildClose = false,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T1EnergyProduction',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U1 Power Push 500',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 2100,
        DelayEqualBuildPlattons = {'Energy', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'LessThanEnergyTrend', { 50.0 } },
            -- Have we the eco to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 } },
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.05}}, -- Ratio from 0 to 1. (1=100%)
            { EBC, 'GreaterThanEconIncome',  { 0.6, 6.0}}, -- Absolut Base income
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, -0.00}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.TECH1 }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.TECH1 } },
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapStructure , '<=', categories.STRUCTURE - categories.MASSEXTRACTION - categories.DEFENSE - categories.FACTORY } },
        },
        InstanceCount = 1,
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                AdjacencyCategory = 'FACTORY STRUCTURE AIR, FACTORY STRUCTURE LAND',
                AdjacencyDistance = 50,
                BuildClose = false,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T1EnergyProduction',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U-CDR Power Emergency',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 2100,
        BuilderConditions = {
            -- When do we want to build this ?
            { EBC, 'LessThanEconStorageRatio', { 2.00, 0.99}}, -- Ratio from 0 to 1. (1=100%)
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconIncome',  { 1.0, 6.0}}, -- Absolut Base income
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.TECH1 } },
        },
        InstanceCount = 1,
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'FACTORY STRUCTURE AIR, FACTORY STRUCTURE LAND',
                AdjacencyDistance = 50,
                BuildClose = false,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T1EnergyProduction',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U-CDR Power Push 500',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 2100,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'LessThanEnergyTrend', { 50.0 } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.05}}, -- Ratio from 0 to 1. (1=100%)
            { EBC, 'GreaterThanEconIncome',  { 0.6, 6.0}}, -- Absolut Base income
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, -0.00}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.TECH1 }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.TECH1 } },
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapStructure , '<=', categories.STRUCTURE - categories.MASSEXTRACTION - categories.DEFENSE - categories.FACTORY } },
        },
        InstanceCount = 1,
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'FACTORY STRUCTURE AIR, FACTORY STRUCTURE LAND',
                AdjacencyDistance = 50,
                BuildClose = false,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T1EnergyProduction',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U1 Power Hydrocarbon',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 2000,
        DelayEqualBuildPlattons = {'Energy', 1},
        InstanceCount = 1,
        BuilderConditions = {
            -- When do we want to build this ?
            { MABC, 'MarkerLessThanDistance',  { 'Hydrocarbon', 150}},
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconIncome',  { 0.4, 2.0}}, -- Absolut Base income 4 60
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.TECH1 }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.TECH1 } },
            { UCBC, 'HaveUnitRatioVersusCap', { 0.35, '<=', categories.STRUCTURE - categories.MASSEXTRACTION } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1HydroCarbon',
                }
            }
        }
    },
    Builder {
        BuilderName = 'U-CDR Energy RECOVER',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 7900,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.MASSEXTRACTION }},
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        InstanceCount = 1,
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'FACTORY STRUCTURE AIR, FACTORY STRUCTURE LAND',
                AdjacencyDistance = 50,
                BuildClose = false,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T1EnergyProduction',
                },
            }
        }
    },
    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder {
        BuilderName = 'U2 Power minimum',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 2200,
        DelayEqualBuildPlattons = {'Energy', 3},
        InstanceCount = 1,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.ENERGYPRODUCTION * ( categories.TECH2 + categories.TECH3 + categories.EXPERIMENTAL ) } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconIncome', { 0.6, 6.8 }},
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * ( categories.TECH2 + categories.TECH3 ) }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = true,
                AdjacencyCategory = 'SHIELD STRUCTURE, FACTORY TECH3, FACTORY TECH2, FACTORY TECH1',
                AvoidCategory = categories.ENERGYPRODUCTION * categories.TECH2,
                maxUnits = 1,
                maxRadius = 10,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T2EnergyProduction',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U2 Power Trend < 1000',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 2200,
        DelayEqualBuildPlattons = {'Energy', 3},
        InstanceCount = 1,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'LessThanEnergyTrend', { 100.0 } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'EngineerGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH2' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconIncome', { 0.6, 6.8 }},
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, -0.00}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * ( categories.TECH2 + categories.TECH3 ) }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3 } },
            { UCBC, 'HaveUnitRatioVersusCap', { 0.35, '<=', categories.STRUCTURE - categories.MASSEXTRACTION } },
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapStructure , '<=', categories.STRUCTURE - categories.MASSEXTRACTION - categories.DEFENSE - categories.FACTORY } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = true,
                AdjacencyCategory = 'SHIELD STRUCTURE, FACTORY TECH3, FACTORY TECH2, FACTORY TECH1',
                AvoidCategory = categories.ENERGYPRODUCTION * categories.TECH2,
                maxUnits = 1,
                maxRadius = 10,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T2EnergyProduction',
                },
            }
        }
    },
    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder {
        BuilderName = 'U3 Power minimum',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 2300,
        DelayEqualBuildPlattons = {'Energy', 10},
        InstanceCount = 1,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.ENERGYPRODUCTION * categories.TECH3 } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconIncome', { 0.5, 100.0 }},
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = true,
                AdjacencyCategory = 'SHIELD STRUCTURE, FACTORY TECH3, FACTORY TECH2, FACTORY TECH1',
                AvoidCategory = categories.ENERGYPRODUCTION * categories.TECH3,
                maxUnits = 1,
                maxRadius = 15,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T3EnergyProduction',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U3 Power Emergency',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 2300,
        DelayEqualBuildPlattons = {'Energy', 10},
        InstanceCount = 1,
        BuilderConditions = {
            -- When do we want to build this ?
            { EBC, 'LessThanEconStorageRatio', { 2.00, 0.99}}, -- Ratio from 0 to 1. (1=100%)
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconIncome', { 0.5, 100.0 }},
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 3, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3}},
            { UCBC, 'HaveUnitRatioVersusCap', { 0.35, '<=', categories.STRUCTURE - categories.MASSEXTRACTION } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = true,
                AdjacencyCategory = 'SHIELD STRUCTURE, FACTORY TECH3, FACTORY TECH2, FACTORY TECH1',
                AvoidCategory = categories.ENERGYPRODUCTION * categories.TECH3,
                maxUnits = 1,
                maxRadius = 15,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T3EnergyProduction',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U3 Power Push 6000',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 2300,
        DelayEqualBuildPlattons = {'Energy', 10},
        InstanceCount = 2,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'LessThanEnergyTrend', { 600.0 } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconIncome', { 0.5, 100.0 }},
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3}},
            { UCBC, 'HaveUnitRatioVersusCap', { 0.35, '<=', categories.STRUCTURE - categories.MASSEXTRACTION } },
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapStructure , '<=', categories.STRUCTURE - categories.MASSEXTRACTION - categories.DEFENSE - categories.FACTORY } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = true,
                AdjacencyCategory = 'SHIELD STRUCTURE, FACTORY TECH3, FACTORY TECH2, FACTORY TECH1',
                AvoidCategory = categories.ENERGYPRODUCTION * categories.TECH3,
                maxUnits = 1,
                maxRadius = 15,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T3EnergyProduction',
                },
            }
        }
    },
    -- =================== --
    --    EnergyStorage    --
    -- =================== --
    Builder {
        BuilderName = 'U1 Energy Storage Emergency',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 2500,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYSTORAGE }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 } },
            { UCBC, 'GreaterThanGameTimeSeconds', { 180 } },
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1,  'ENERGYSTORAGE' }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Location = 'LocationType',
            Construction = {
                BuildClose = false,
                AdjacencyCategory = 'STRUCTURE ENERGYPRODUCTION TECH3, STRUCTURE ENERGYPRODUCTION TECH2, STRUCTURE ENERGYPRODUCTION TECH1',
                LocationType = 'LocationType',
                BuildStructures = {
                    'EnergyStorage',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U1 Energy Storage I',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 1800,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.STRUCTURE * categories.ENERGYSTORAGE }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.95}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1,  'ENERGYSTORAGE' }},
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapStructure , '<=', categories.STRUCTURE - categories.MASSEXTRACTION - categories.DEFENSE - categories.FACTORY } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Location = 'LocationType',
            Construction = {
                BuildClose = false,
                AdjacencyCategory = 'STRUCTURE ENERGYPRODUCTION TECH3, STRUCTURE ENERGYPRODUCTION TECH2, STRUCTURE ENERGYPRODUCTION TECH1',
                LocationType = 'LocationType',
                BuildStructures = {
                    'EnergyStorage',
                },
            }
        }
    },
    -- ======================= --
    --    Reclaim Buildings    --
    -- ======================= --
    Builder {
        BuilderName = 'U1 Reclaim T1 Pgens',
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 790,
        InstanceCount = 2,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.00, 1.00}}, -- Ratio from 0 to 1. (1=100%)
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 }},
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.TECH1 * categories.ENERGYPRODUCTION }},
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 } },
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {'STRUCTURE ENERGYPRODUCTION TECH1'},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U-CDR Reclaim T1 Pgens',
        PlatoonTemplate = 'CommanderBuilder',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 790,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.00, 1.00}}, -- Ratio from 0 to 1. (1=100%)
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 }},
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.TECH1 * categories.ENERGYPRODUCTION }},
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 } },
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {'STRUCTURE ENERGYPRODUCTION TECH1'},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U1 Reclaim T2 Pgens',
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 750,
        InstanceCount = 2,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.00, 1.00}}, -- Ratio from 0 to 1. (1=100%)
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 }},
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.TECH2 * categories.ENERGYPRODUCTION - categories.HYDROCARBON }},
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 } },
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {'STRUCTURE ENERGYPRODUCTION TECH2'},
        },
        BuilderType = 'Any',
    },
}

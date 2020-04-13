#***************************************************************************
#*
#**  File     :  /lua/ai/AIBaseTemplates/NormalMain.lua
#**
#**  Summary  : Manage engineers for a location
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

BaseBuilderTemplate {
    BaseTemplateName = 'uvesooverwhelm',
    Builders = {
        -----------------------------------------------------------------------------
        -- ==== ACU ==== --
        -----------------------------------------------------------------------------
        -- Build Main Base (only once). Land/Air factory and basic Energy
        'UC ACU Attack Former',
        
        -----------------------------------------------------------------------------
        -- ==== Expansion Builders ==== --
        -----------------------------------------------------------------------------
        -- Build an Expansion
        'U1 Expansion Builder',

        -----------------------------------------------------------------------------
        -- ==== SCU ==== --
        -----------------------------------------------------------------------------

        -----------------------------------------------------------------------------
        -- ==== Engineer ==== --
        -----------------------------------------------------------------------------
        -- Build Engineers Tech 1,2,3 and SACU
        'U123 Engineer Builders',            -- Priority = 900
        -- Assistees
        'UC123 Assistees',
        -- Reclaim mass
        'U1 Engineer Reclaim',

        -----------------------------------------------------------------------------
        -- ==== Mass ==== --
        -----------------------------------------------------------------------------
        -- Build MassExtractors / Creators
        'U1 MassBuilders',                           -- Priority = 1100
        'U1 Mass Capture',
        -- Upgrade MassExtractors from Tech 1 to 2 AND from Tech 2 to 3
        'U123 ExtractorUpgrades',                      -- Priority = 1100
        -- Build Mass Storage (Adjacency)
        'U1 MassStorage Builder',                     -- Priority = 1100

        -----------------------------------------------------------------------------
        -- ==== Energy ==== --
        -----------------------------------------------------------------------------
        -- Build Power Tech 1,2,3
        'U123 Energy Builders',                       -- Priority = 1100

        -----------------------------------------------------------------------------
        -- ==== Factory ==== --
        -----------------------------------------------------------------------------
        -- Build Land/Air Factories
        'U1 Factory Builders 1st',
        'U1 Factory Builders ADAPTIVE',
        'U1 Factory Builders RECOVER',
        'U1 Gate Builders',
        -- Upgrade Factories TECH1->TECH2 and TECH2->TECH3
        'U123 Factory Upgrader Rush',
        -- Build Air Staging Platform to refill and repair air units.
        'U2 Air Staging Platform Builders',

        -----------------------------------------------------------------------------
        -- ==== Land Units BUILDER ==== --
        -----------------------------------------------------------------------------
        'U123 Land Builders Panic',
        'U123 Land Builders ADAPTIVE',
        'U3 SACU Builder',

        -----------------------------------------------------------------------------
        -- ==== Land Units FORMER==== --
        -----------------------------------------------------------------------------
        'U123 Land Formers PanicZone',
        'U123 Land Formers MilitaryZone',
        'U123 Land Formers EnemyZone',
        'U123 Land Formers Trasher',
        'U123 Land Formers Guards',

        -----------------------------------------------------------------------------
        -- ==== Hover Units FORMER==== --
        -----------------------------------------------------------------------------
        'U123 Hover Formers PanicZone',
        'U123 Hover Formers MilitaryZone',
        'U123 Hover Formers EnemyZone',
        'U123 Hover Formers Trasher',

        -----------------------------------------------------------------------------
        -- ==== Amphibious Units BUILDER ==== --
        -----------------------------------------------------------------------------
        'U123 Amphibious Builders',

        -----------------------------------------------------------------------------
        -- ==== Amphibious Units FORMER==== --
        -----------------------------------------------------------------------------
        'U123 Amphibious Formers PanicZone',
        'U123 Amphibious Formers MilitaryZone',
        'U123 Amphibious Formers EnemyZone',
        'U123 Amphibious Formers Trasher',

        -----------------------------------------------------------------------------
        -- ==== Air Units BUILDER ==== --
        -----------------------------------------------------------------------------
        'U123 Air Builders',
        -- Build Air Transporter
        'U123 Air Transport Builders',

        -----------------------------------------------------------------------------
        -- ==== Air Units FORMER==== --
        -----------------------------------------------------------------------------
        'U123 Air Formers PanicZone',
        'U123 Air Formers MilitaryZone',
        'U123 Air Formers EnemyZone',
        'U123 Air Formers Trasher',
        'U123 TorpedoBomber Formers',

        -----------------------------------------------------------------------------
        -- ==== EXPERIMENTALS BUILDER ==== --
        -----------------------------------------------------------------------------
        'U4 Land Experimental Builders',
        'U4 Air Experimental Builders',
        'U4 Economic Experimental Builders',
        'Paragon Turbo Experimentals', -- land, air and naval experimentals
        'Paragon Turbo FactoryUpgrader',
        'Paragon Turbo Air', -- T3 scouts, Fighter, Gunships, Bomber
        'Paragon Turbo Land',
        
        -----------------------------------------------------------------------------
        -- ==== EXPERIMENTALS FORMER ==== --
        -----------------------------------------------------------------------------
        'U4 Land Experimental Formers PanicZone',
        'U4 Land Experimental Formers MilitaryZone',
        'U4 Land Experimental Formers EnemyZone',
        'U4 Land Experimental Formers Trasher',
        'U4 Air Experimental Formers PanicZone',
        'U4 Air Experimental Formers MilitaryZone',
        'U4 Air Experimental Formers EnemyZone',
        'U4 Air Experimental Formers Trasher',

        -----------------------------------------------------------------------------
        -- ==== Structure Shield BUILDER ==== --
        -----------------------------------------------------------------------------
        'U23 Shields Builder',
        'U23 Shields Upgrader',
        'U234 Repair Shields Former',

        -----------------------------------------------------------------------------
        -- ==== Defenses BUILDER ==== --
        -----------------------------------------------------------------------------
        'U2 Tactical Missile Launcher minimum',
        'U2 Tactical Missile Launcher maximum',
        'U2 Tactical Missile Launcher Builder',
        'U2 Tactical Missile Defenses Builder',
        'U3 Strategic Missile Launcher Builder',
        'U4 Strategic Missile Launcher NukeAI',
        'U4 Strategic Missile Defense Builders',
        'U4 Strategic Missile Defense Anti-NukeAI',
        'U4 Artillery Builders',
        'U4 Artillery Formers', -- also needed for UEF SATELLITE
        -- Build Anti Air near AirFactories
        'U123 Defense Anti Air Builders',
        -- Ground Defense Builder
        'U123 Defense Anti Ground Builders',

        -----------------------------------------------------------------------------
        -- ==== FireBase BUILDER ==== --
        -----------------------------------------------------------------------------
        'U1 FirebaseBuilders',

        -----------------------------------------------------------------------------
        -- ==== Sniper Former ==== --
        -----------------------------------------------------------------------------
        'U3 SACU Teleport Formers',

        -- We need this even if we have Omni View to get target informations for experimentals attack.
        -----------------------------------------------------------------------------
        -- ==== Scout BUILDER ==== --
        -----------------------------------------------------------------------------
        'U1 Land Scout Builders',
        'U1 Air Scout Builders',

        -----------------------------------------------------------------------------
        -- ==== Scout FORMER ==== --
        -----------------------------------------------------------------------------
        'U1 Land Scout Formers',
        'U13 Air Scout Formers', 

        -----------------------------------------------------------------------------
        -- ==== Intel/CounterIntel BUILDER ==== --
        -----------------------------------------------------------------------------
        'U1 Land Radar Builders',
        'U1 Land Radar Upgrader',

        'CounterIntelBuilders',

        'AeonOptics',
        'CybranOptics',

    },
    -- Not used by Uveso's AI. We always need intel in case the commander is dead.
    NonCheatBuilders = {

    },

    BaseSettings = {
        FactoryCount = {
            Land = 5,
            Air = 5,
            Sea = 4,
            Gate = 2,
        },
        EngineerCount = {
            Tech1 = 6,
            Tech2 = 3,
            Tech3 = 3,
            SCU = 3,
        },
        MassToFactoryValues = {
            T1Value = 6,
            T2Value = 15,
            T3Value = 22.5
        },
    },
    ExpansionFunction = function(aiBrain, location, markerType)
        return -1
    end,
    FirstBaseFunction = function(aiBrain)
        local personality = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
        if personality == ('uvesooverwhelm' or 'uvesooverwhelmcheat') then
            --LOG('### M-FirstBaseFunction '..personality)
            return 1000, 'uvesooverwhelm' -- AIPersonality
        end
        return -1
    end,
}

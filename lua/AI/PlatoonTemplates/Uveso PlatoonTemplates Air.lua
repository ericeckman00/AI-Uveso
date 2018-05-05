PlatoonTemplate {
    Name = 'U123-EnemyAntiAirInterceptor 10 20', 
    Plan = 'InterceptorAIUveso', -- is targetting in order from Platoondata.PrioritizedCategories.
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR - categories.EXPERIMENTAL - categories.ANTINAVY, 10, 20, 'Attack', 'GrowthFormation' },
    }
}
PlatoonTemplate {
    Name = 'U123-EnemyAntiGround Bomber 10 20',
    Plan = 'InterceptorAIUveso', -- is targetting in order from Platoondata.PrioritizedCategories.
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.BOMBER - categories.EXPERIMENTAL - categories.ANTINAVY, 10, 20, 'Attack', 'GrowthFormation' },
    }
}
PlatoonTemplate {
    Name = 'U123-EnemyAntiGround Gunship 10 20',
    Plan = 'InterceptorAIUveso', -- is targetting in order from Platoondata.PrioritizedCategories.
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.EXPERIMENTAL - categories.ANTINAVY , 10, 20, 'Attack', 'GrowthFormation' }
    }
}

-- Bomber
PlatoonTemplate {
    Name = 'U123-ExperimentalAttackBomberGrow 3 100',
    Plan = 'InterceptorAIUveso', -- is targetting in order from Platoondata.PrioritizedCategories.
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.BOMBER - categories.EXPERIMENTAL - categories.ANTINAVY, 3, 100, 'Attack', 'GrowthFormation' },
    }
}
--
PlatoonTemplate {
    Name = 'U123-TorpedoBomber 1 100',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTINAVY - categories.EXPERIMENTAL, 1, 100, 'Attack', 'GrowthFormation' },
    }
}

PlatoonTemplate {
    Name = 'U123-AntiAirPanic 1 500', 
    Plan = 'InterceptorAIUveso', -- is targetting in order from Platoondata.PrioritizedCategories.
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.EXPERIMENTAL, 1, 500, 'Attack', 'GrowthFormation' },
    }
}
PlatoonTemplate {
    Name = 'U123-AntiGroundPanic 1 500', 
    Plan = 'InterceptorAIUveso', -- is targetting in order from Platoondata.PrioritizedCategories.
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * ( categories.GROUNDATTACK + categories.BOMBER ) - categories.EXPERIMENTAL, 1, 500, 'Attack', 'GrowthFormation' },
    }
}
PlatoonTemplate {
    Name = 'U12-AntiAirCap 1 500', 
    Plan = 'InterceptorAIUveso', -- is targetting in order from Platoondata.PrioritizedCategories.
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR * ( categories.TECH1 + categories.TECH2 ), 1, 500, 'Attack', 'GrowthFormation' },
    }
}
PlatoonTemplate {
    Name = 'U12-AntiGroundCap 1 500', 
    Plan = 'InterceptorAIUveso', -- is targetting in order from Platoondata.PrioritizedCategories.
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * ( categories.GROUNDATTACK + categories.BOMBER ) * ( categories.TECH1 + categories.TECH2 ), 1, 500, 'Attack', 'GrowthFormation' },
    }
}
PlatoonTemplate {
    Name = 'U123-TransportInterceptor 1 12', 
    Plan = 'InterceptorAIUveso', -- is targetting in order from Platoondata.PrioritizedCategories.
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.EXPERIMENTAL, 1, 12, 'Attack', 'GrowthFormation' },
    }
}
PlatoonTemplate {
    Name = 'U123-ExperimentalAttackGunshipGrow 3 100',
    Plan = 'InterceptorAIUveso', -- is targetting in order from Platoondata.PrioritizedCategories.
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.EXPERIMENTAL - categories.ANTINAVY , 3, 100, 'Attack', 'GrowthFormation' }
    }
}
PlatoonTemplate {
    Name = 'U123-ExperimentalAttackInterceptorGrow 3 100',
    Plan = 'InterceptorAIUveso', -- is targetting in order from Platoondata.PrioritizedCategories.
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.EXPERIMENTAL - categories.ANTINAVY, 3, 100, 'Attack', 'GrowthFormation' },
    }
}
PlatoonTemplate {
    Name = 'U4-ExperimentalInterceptor 1 1',
    Plan = 'InterceptorAIUveso', -- is targetting in order from Platoondata.PrioritizedCategories.
    GlobalSquads = {
        { categories.EXPERIMENTAL * categories.AIR * categories.MOBILE - categories.INSIGNIFICANTUNIT, 1, 1, 'attack', 'GrowthFormation' }
    },
}


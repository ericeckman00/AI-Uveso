-- Air Fighter
PlatoonTemplate {
    Name = 'U123-Fighter-Intercept 1 2', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR - categories.GROUNDATTACK - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY, 1, 2, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U123-Fighter-Intercept 3 5', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR - categories.GROUNDATTACK - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY, 3, 5, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U123-Fighter-Intercept 10', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR - categories.GROUNDATTACK - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY, 10, 10, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U123-Fighter-Intercept 20', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR - categories.GROUNDATTACK - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY, 20, 20, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U123-Fighter-Intercept 30 50', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR - categories.GROUNDATTACK - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY, 30, 50, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U123-Fighter-Intercept 1 30', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR - categories.GROUNDATTACK - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY, 1, 30, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U123-Fighter-Intercept 1 50', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR - categories.GROUNDATTACK - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY, 1, 50, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U123-Fighter-Intercept 10 500', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR - categories.GROUNDATTACK - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY, 10, 500, 'Attack', 'none' },
    }
}
-- Gunship
PlatoonTemplate {
    Name = 'U123-Gunship-Intercept 1 2',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.HIGHALTAIR - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY , 1, 2, 'Attack', 'none' }
    }
}
PlatoonTemplate {
    Name = 'U12-Gunship-Intercept 3 5',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.GROUNDATTACK * (categories.TECH1 + categories.TECH2) - categories.HIGHALTAIR - categories.TRANSPORTFOCUS - categories.ANTINAVY , 3, 5, 'Attack', 'none' }
    }
}
PlatoonTemplate {
    Name = 'U123-Gunship-Intercept 3 5',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.HIGHALTAIR - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY , 3, 5, 'Attack', 'none' }
    }
}
-- Bomber
PlatoonTemplate {
    Name = 'U123-Bomber-Intercept 1 2', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.BOMBER - categories.EXPERIMENTAL - categories.ANTINAVY, 1, 2, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U123-Bomber-Intercept 1 3', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.BOMBER - categories.EXPERIMENTAL - categories.ANTINAVY, 1, 3, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U12-Bomber-Intercept 1 3', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.BOMBER * (categories.TECH1 + categories.TECH2) - categories.ANTINAVY, 1, 3, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U12-Bomber-Intercept 3 5', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.BOMBER * (categories.TECH1 + categories.TECH2) - categories.ANTINAVY, 3, 5, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U123-Bomber-Intercept 3 5', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.BOMBER - categories.EXPERIMENTAL - categories.ANTINAVY, 3, 5, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U123-Bomber-Intercept 15 20', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.BOMBER - categories.EXPERIMENTAL - categories.ANTINAVY, 15, 20, 'Attack', 'none' },
    }
}
-- Torpedo Bomber
PlatoonTemplate {
    Name = 'U123-Torpedo-Intercept 3 5',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTINAVY - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL, 3, 5, 'Attack', 'AttackFormation' },
    }
}
-- Gunship + Bomber
PlatoonTemplate {
    Name = 'U123-Gunship+Bomber-Intercept 1 2',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * ( categories.GROUNDATTACK + categories.BOMBER ) - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY , 1, 2, 'Attack', 'GrowthFormation' }
    }
}
PlatoonTemplate {
    Name = 'U123-Gunship+Bomber-Intercept 3 5',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * ( categories.GROUNDATTACK + categories.BOMBER ) - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY , 3, 5, 'Attack', 'GrowthFormation' }
    }
}
PlatoonTemplate {
    Name = 'U123-Gunship+Bomber-Intercept 1 50',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * ( categories.GROUNDATTACK + categories.BOMBER ) - categories.EXPERIMENTAL - categories.ANTINAVY , 1, 50, 'Attack', 'none' }
    }
}
PlatoonTemplate {
    Name = 'U123-Gunship-Intercept 15 20', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.EXPERIMENTAL - categories.ANTINAVY, 15, 20, 'Attack', 'none' },
    }
}


-- Unsorted
-- Unsorted
-- Unsorted


PlatoonTemplate {
    Name = 'U123-PanicGround 1 500', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * ( categories.GROUNDATTACK + categories.BOMBER ) - categories.EXPERIMENTAL - categories.ANTINAVY, 1, 500, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U123-PanicAir 1 500', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.EXPERIMENTAL - categories.GROUNDATTACK - categories.BOMBER, 1, 500, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U123-MilitaryAntiTransport 1 12', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR - categories.GROUNDATTACK - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL, 1, 12, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U123-MilitaryAntiBomber 1 12', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR - categories.GROUNDATTACK - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL, 1, 12, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U123-MilitaryAntiAir 2 500', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR - categories.GROUNDATTACK - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL, 2, 500, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U123-MilitaryAntiGround Gunship 2 500', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.HIGHALTAIR - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY , 2, 500, 'Attack', 'none' }
    }
}
PlatoonTemplate {
    Name = 'U123-EnemyAntiAir 10 10', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.GROUNDATTACK - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.GROUNDATTACK - categories.BOMBER, 10, 10, 'Attack', 'none' },
    }
}






PlatoonTemplate {
    Name = 'U123-EnemyAntiAirInterceptor 10 20', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY, 10, 20, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U123-EnemyAntiGround Bomber 3 5',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.BOMBER - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY, 3, 5, 'Attack', 'AttackFormation' },
    }
}
PlatoonTemplate {
    Name = 'U123-EnemyAntiGround Gunship 3 20',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.HIGHALTAIR - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY , 3, 20, 'Attack', 'none' }
    }
}

-- Bomber
PlatoonTemplate {
    Name = 'U123-ExperimentalAttackBomberGrow 3 100',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.BOMBER - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY, 3, 100, 'Attack', 'AttackFormation' },
    }
}
PlatoonTemplate {
    Name = 'U123-TorpedoBomber 1 100',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTINAVY - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL, 1, 100, 'Attack', 'AttackFormation' },
    }
}

PlatoonTemplate {
    Name = 'U12-AntiAirCap 1 500', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR * ( categories.TECH1 + categories.TECH2 ), 1, 500, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U12-AntiGroundCap 1 500', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * ( categories.GROUNDATTACK + categories.BOMBER ) * ( categories.TECH1 + categories.TECH2 ) - categories.ANTINAVY, 1, 500, 'Attack', 'AttackFormation' },
    }
}
PlatoonTemplate {
    Name = 'U12-AntiGroundCap 30 40', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * ( categories.GROUNDATTACK + categories.BOMBER ) * ( categories.TECH1 + categories.TECH2 ) - categories.ANTINAVY, 30, 40, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U123-ExperimentalAttackGunshipGrow 3 100',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.HIGHALTAIR - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY , 3, 100, 'Attack', 'AttackFormation' }
    }
}
PlatoonTemplate {
    Name = 'U123-ExperimentalAttackInterceptorGrow 3 100',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY, 3, 100, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U4-ExperimentalInterceptor 1 1',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.EXPERIMENTAL * categories.AIR * categories.MOBILE - categories.SATELLITE - categories.INSIGNIFICANTUNIT, 1, 1, 'attack', 'none' },
    },
}
PlatoonTemplate {
    Name = 'U4-ExperimentalInterceptor 3 8',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.EXPERIMENTAL * categories.AIR * categories.MOBILE - categories.SATELLITE - categories.INSIGNIFICANTUNIT, 3, 8, 'attack', 'none' },
    },
}

PlatoonTemplate {
    Name = 'U1234-AirSuicide 1 1',
    Plan = 'AirSuicideAI',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * ( categories.GROUNDATTACK + categories.BOMBER ) - categories.SATELLITE - categories.INSIGNIFICANTUNIT, 1, 1, 'attack', 'none' }
    },
}

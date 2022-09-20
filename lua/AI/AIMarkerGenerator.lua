
local getTerrainHeight = GetTerrainHeight
local mathmax = math.max
local mathfloor = math.floor
local mathabs = math.abs
local mathceil = math.ceil
local mathatan2 = math.atan2

local AIAttackUtils = import('/lua/ai/aiattackutilities.lua')
local WantedGridCellSize = 14
local playableArea
local PlayableMapSizeX
local PlayableMapSizeZ
local MarkerGridCountX
local MarkerGridCountZ
local MarkerGridSizeX
local MarkerGridSizeZ
local MarkerGrid = {}
local PathMap = {}


function InitMarkerGenerator()
    playableArea = import("/mods/AI-Uveso/lua/AI/AITargetManager.lua").GetPlayableArea()
    PlayableMapSizeX = playableArea[3] - playableArea[1]
    PlayableMapSizeZ = playableArea[4] - playableArea[2]
    MarkerGridCountX = mathfloor(PlayableMapSizeX / WantedGridCellSize)
    MarkerGridCountZ = mathfloor(PlayableMapSizeZ / WantedGridCellSize)
    MarkerGridSizeX = PlayableMapSizeX / MarkerGridCountX
    MarkerGridSizeZ = PlayableMapSizeZ / MarkerGridCountZ
end

function SetWantedGridCellSize(size)
    AIDebug("* AI-Uveso: Function SetWantedGridCellSize() Grid size for AI marker set to: "..size, true)
    WantedGridCellSize = size
    InitMarkerGenerator()
    return
end

function MarkerGridCountXZ()
    return MarkerGridCountX, MarkerGridCountZ
end

function GetMarkerGridIndexFromPosition(Position)
    --AILog("GetHeatMapGridIndexFromPosition unit Pos"..Position[1].." "..Position[3].."")
    local x = math.floor( (Position[1] - playableArea[1]) / MarkerGridSizeX ) 
    local z = math.floor( (Position[3] - playableArea[2]) / MarkerGridSizeZ )
    --AILog("GetHeatMapGridIndexFromPosition area Pos"..x.." "..z.."")
    -- Make sure that x and z are inside the playable area
    x = math.max( 0, x )
    x = math.min( MarkerGridCountX - 1, x )
    z = math.max( 0, z )
    z = math.min( MarkerGridCountZ - 1, z )
    --AILog("GetHeatMapGridIndexFromPosition math Pos"..x.." "..z.."")
    return x, z
end

function GetMarkerGridPositionFromIndex(x, z)
    --AILog("GetHeatMapGridPositionFromIndex index x "..x.." - z "..z.."")
    local posX = x * MarkerGridSizeX + MarkerGridSizeX / 2 + playableArea[1]
    local posZ = z * MarkerGridSizeZ + MarkerGridSizeZ / 2 + playableArea[2]
    local posY = 0
    --AILog("GetHeatMapGridPositionFromIndex MapPos"..posX.." "..posZ.."")
    return {posX, posY, posZ}
end

function BuildTerrainPathMap()
    AIDebug("* AI-Uveso: Function BuildTerrainPathMap() started.", true)
    local PathMap = PathMap
    local waterDepth
    for x = playableArea[1], playableArea[3] do
        PathMap[x] = {}
        for z = playableArea[2], playableArea[4] do
            PathMap[x][z] = {}
            -- check for water depth. -21 would be 21 beyond the water surface
            waterDepth = getTerrainHeight(x, z) - GetSurfaceHeight(x, z)
            -- set the layer depending on the water depth
            if waterDepth >= 0 then
                -- 0+ is land / hover / amphibious (not naval)
                PathMap[x][z].layer = "Land"
            elseif waterDepth >= -1.6 then
                -- -1.8 to 0 is hover / amphibious (not land or naval)
                PathMap[x][z].layer = "Beach"
            elseif waterDepth >= -24.9 then
                -- -24.9 to -1.8 is hover / amphibious / naval (not land)
                PathMap[x][z].layer = "Seabed"
            else
                -- -25 to xx is hover / naval (not amphibious / land)
                --AIWarn("Found very deep water!")
                PathMap[x][z].layer = "Abyss"
                PathMap[x][z].blocked = true
            end
            -- check for pathing. (check also water for seabed pathing except Abyss)
            if PathMap[x][z].layer ~= "Abyss" then
                PathMap[x][z].blocked = not IsPathable(x,z)
            end
        end
    end
end
local maxcounter = 0
function IsPathable(x,z)
    if not GetTerrainType(x,z).Blocking then
        local U, D, L, R, LU, RU, LD, RD
        M = getTerrainHeight(x + 0.50, z + 0.50 )
        U = getTerrainHeight(x + 0.50, z + 0.01 )
        D = getTerrainHeight(x + 0.50, z + 0.99)
        L = getTerrainHeight(x + 0.01, z + 0.50)
        R = getTerrainHeight(x + 0.99, z + 0.50)
        LU = getTerrainHeight(x + 0.153, z + 0.153)
        RU = getTerrainHeight(x + 0.847, z + 0.153)
        LD = getTerrainHeight(x + 0.153, z + 0.847)
        RD = getTerrainHeight(x + 0.847, z + 0.847)

--[[
--        if (x == 246 or x == 247) and (z == 200 or z == 201) then
--        if (x == 35 or x == 36) and (z == 46 or z == 47) then
        if (x == 11 or x == 410) and (z == 12 or z == 411) then
            AIWarn("["..x.."]["..z.."] mathabs(M-U) "..math.floor(mathabs(M-U)*100))
            AIWarn("["..x.."]["..z.."] mathabs(M-D) "..math.floor(mathabs(M-D)*100))
            AIWarn("["..x.."]["..z.."] mathabs(M-L) "..math.floor(mathabs(M-L)*100))
            AIWarn("["..x.."]["..z.."] mathabs(M-R) "..math.floor(mathabs(M-R)*100))
            AIWarn("["..x.."]["..z.."] mathabs(M-LU) "..math.floor(mathabs(M-LU)*100))
            AIWarn("["..x.."]["..z.."] mathabs(M-RU) "..math.floor(mathabs(M-RU)*100))
            AIWarn("["..x.."]["..z.."] mathabs(M-LD) "..math.floor(mathabs(M-LD)*100))
            AIWarn("["..x.."]["..z.."] mathabs(M-RD) "..math.floor(mathabs(M-RD)*100))
        end
--]]
        return mathmax( mathabs(M-U), mathabs(M-D), mathabs(M-L), mathabs(M-R) ) < 0.36 and mathmax( mathabs(M-LU), mathabs(M-RU), mathabs(M-LD), mathabs(M-RD) ) < 0.44
    end
    return false
end

local layerOffsets = {
    ['Air']        = { ['color'] = 'ffffffff', ['colorBlocked'] = 'ffff0000' },
    ['Land']       = { ['color'] = 'fff4a460', ['colorBlocked'] = 'ffFFa460' },
    ['Beach']      = { ['color'] = 'ff1e90ff', ['colorBlocked'] = 'ffFF90ff' },
    ['Seabed']     = { ['color'] = 'ff0e80Ef', ['colorBlocked'] = 'ffFF80Ef' },
    ['Abyss']      = { ['color'] = 'ff27408b', ['colorBlocked'] = 'ffFF408b' },
}

local markerOffsets = {
    ['Air']        = { [1] =  0.0, [2] =  0.0, [3] =  0.0, ['color'] = 'ffffffff', },
    ['Land']       = { [1] =  0.0, [2] =  0.0, [3] =  0.0, ['color'] = 'fff4a460', },
    ['Amphibious'] = { [1] =  0.2, [2] =  0.0, [3] =  0.2, ['color'] = 'ff657b3f', },
    ['Hover']      = { [1] =  0.3, [2] =  0.0, [3] =  0.3, ['color'] = 'ff63b8ff', },
    ['Water']      = { [1] =  0.1, [2] =  0.0, [3] =  0.1, ['color'] = 'ff191970', },
}

local colors = {
    ['counter'] = 0,
    ['countermax'] = 0,
    ['lastcolorindex'] = 1,
    [1] = 'ff000000',
    [2] = 'ff202000',
    [3] = 'ff404000',
    [4] = 'ff606000',
    [5] = 'ff808000',
    [6] = 'ffA0A000',
    [7] = 'ffC0C000',
    [8] = 'ffE0E000',

    [9] = 'ffFFFF00',
    [10] = 'ffFFFF00',
    [11] = 'ffFFFF00',

    [12] = 'ffE0E000',
    [13] = 'ffC0C000',
    [14] = 'ffA0A000',
    [15] = 'ff808000',
    [16] = 'ff606000',
    [17] = 'ff404000',
    [18] = 'ff202000',
    [19] = 'ff000000',
}

function PathableTerrainRenderThread()
    while true do
        coroutine.yield(2)
        for x = playableArea[1], playableArea[3], 1 do
            for z = playableArea[2], playableArea[4], 1 do
                if PathMap[x][z].blocked then
                    if PathMap[x][z].layer == "Land" then
                        DrawCircle({x + 0.50, getTerrainHeight(x + 0.5, z + 0.5) , z + 0.50}, 0.5, layerOffsets[PathMap[x][z].layer].colorBlocked )
                    elseif PathMap[x][z].layer == "Beach" then
                        DrawCircle({x + 0.50, getTerrainHeight(x + 0.5, z + 0.5) , z + 0.50}, 0.5, layerOffsets[PathMap[x][z].layer].colorBlocked )
                    elseif PathMap[x][z].layer == "Seabed" then
                        DrawCircle({x + 0.50, getTerrainHeight(x + 0.5, z + 0.5) , z + 0.50}, 0.5, layerOffsets[PathMap[x][z].layer].colorBlocked )
                    elseif PathMap[x][z].layer == "Abyss" then
                        DrawCircle({x + 0.50, getTerrainHeight(x + 0.5, z + 0.5) , z + 0.50}, 0.5, layerOffsets[PathMap[x][z].layer].colorBlocked )
                    end
                end
            end
        end
    end
end

--function DebugLayerRenderThread(movementLayer)
--    AIDebug("* AI-Uveso: Function DebugLayerRenderThread("..movementLayer..") started.", true)
--    local MarkerPosition = {}
--    local Marker2Position = {}
--    local adjancents
--    local otherMarker
--    while GetGameTimeSeconds() < 5 do
--        coroutine.yield(10)
--    end
--    local MarkerPosition = {0,0,0}
--    local Marker2Position = {0,0,0}
--    while true do
--        for x, MarkerGridYrow in MarkerGrid[movementLayer] do
--            for y, markerInfo in MarkerGridYrow or {} do
--                -- Draw the marker path node
--                MarkerPosition[1] = markerInfo.position[1] + (markerOffsets[movementLayer][1])
--                MarkerPosition[2] = markerInfo.position[2] + (markerOffsets[movementLayer][2])
--                MarkerPosition[3] = markerInfo.position[3] + (markerOffsets[movementLayer][3])
--                DrawCircle( markerInfo.position, 2.5, markerOffsets[movementLayer]['color'] )
--                -- Draw the connecting lines to its adjacent nodes
--                for i, node in markerInfo.adjacentTo or {} do
--                    otherMarker = MarkerGrid[movementLayer][node[1]][node[2]]
--                    if otherMarker then
--                        Marker2Position[1] = otherMarker.position[1] + markerOffsets[movementLayer][1]
--                        Marker2Position[2] = otherMarker.position[2] + markerOffsets[movementLayer][2]
--                        Marker2Position[3] = otherMarker.position[3] + markerOffsets[movementLayer][3]
--                        DrawLinePop( MarkerPosition, Marker2Position, markerOffsets[movementLayer]['color'] )
--                    end
--                end
--            end
--        end
--        coroutine.yield(2)
--    end
--end

function GraphRenderThread()
    -- wait 10 seconds at gamestart before we start debuging
    while GetGameTimeSeconds() < 5 do
        coroutine.yield(10)
    end
    AIDebug('* AI-Uveso: Function GraphRenderThread() started.', true)
    while true do
        -- draw all paths with location radius and AI Pathfinding
        if ScenarioInfo.Options.AIPathingDebug == 'pathlocation'
        or ScenarioInfo.Options.AIPathingDebug == 'path'
        or ScenarioInfo.Options.AIPathingDebug == 'paththreats'
        or ScenarioInfo.Options.AIPathingDebug == 'imapthreats'
        then
            if GetGameTimeSeconds() < 10 then
                -- only display the expansions
                DrawPathGraph('NoPathDraw', false)
            elseif GetGameTimeSeconds() < 15 then
                -- display first all land nodes (true will let them blink)
                DrawPathGraph('Amphibious', false)
                DrawPathGraph('Hover', false)
                DrawPathGraph('Land', false)
                DrawPathGraph('Water', false)
            elseif GetGameTimeSeconds() < 20 then
                DrawPathGraph('Land', true)
            -- water nodes
            elseif GetGameTimeSeconds() < 25 then
                DrawPathGraph('Water', true)
            -- display amphibious nodes
            elseif GetGameTimeSeconds() < 30 then
                DrawPathGraph('Amphibious', true)
            -- display hover nodes
            elseif GetGameTimeSeconds() < 35 then
                DrawPathGraph('Hover', true)
            -- air nodes
            elseif GetGameTimeSeconds() < 40 then
                DrawPathGraph('Air', true)
            elseif GetGameTimeSeconds() < 45 then
                DrawPathGraph('Amphibious', false)
                DrawPathGraph('Hover', false)
                DrawPathGraph('Land', false)
                DrawPathGraph('Water', false)
            elseif GetGameTimeSeconds() < 50 then
                -- only display the expansions
                DrawPathGraph('NoPathDraw', false)
            end
            -- Draw the radius of each base(manager)
            if ScenarioInfo.Options.AIPathingDebug == 'pathlocation' then
                DrawBaseRanger()
            -- Draw the IMAP threat
            elseif ScenarioInfo.Options.AIPathingDebug == 'imapthreats' then
                DrawIMAPThreats()
            end
            DrawAIPathCache()
        -- Display land path permanent
        elseif ScenarioInfo.Options.AIPathingDebug == 'land' then
            DrawPathGraph('DefaultLand', false)
            DrawAIPathCache('DefaultLand')
        -- Display water path permanent
        elseif ScenarioInfo.Options.AIPathingDebug == 'water' then
            DrawPathGraph('DefaultWater', false)
            DrawAIPathCache('DefaultWater')
        -- Display amph path permanent
        elseif ScenarioInfo.Options.AIPathingDebug == 'amph' then
            DrawPathGraph('DefaultAmphibious', false)
            DrawAIPathCache('DefaultAmphibious')
        -- Display air path permanent
        elseif ScenarioInfo.Options.AIPathingDebug == 'air' then
            DrawPathGraph('DefaultAir', false)
            DrawAIPathCache('DefaultAir')
        end
        coroutine.yield(2)
    end
end

function DrawPathGraph(DrawOnly,Blink)
    local color
    if Blink then
        colors['counter'] = colors['counter'] + 1
        if colors['counter'] > colors['countermax'] then
            colors['counter'] = 0
            --AILog('lastcolorindex:'..colors['lastcolorindex']..' - table.getn(colors)'..table.getn(colors))
            if colors['lastcolorindex'] >= (table.getn(colors)) then
                colors['lastcolorindex'] = 1
            else
                colors['lastcolorindex'] = colors['lastcolorindex'] + 1
            end
        end
        color = colors[colors['lastcolorindex']]
    else
        color = markerOffsets[DrawOnly]['color']
    end

    local MarkerPosition = {0,0,0}
    local Marker2Position = {0,0,0}
    -- Render the connection between the path nodes for the specific graph
    local otherMarker
    for Layer, LayerMarkers in AIAttackUtils.GetPathGraphs() do
        for graph, GraphMarkers in LayerMarkers do
            for nodename, markerInfo in GraphMarkers do
                if not DrawOnly or DrawOnly == markerInfo.layer then
                    MarkerPosition[1] = markerInfo.position[1] + (markerOffsets[markerInfo.layer][1])
                    MarkerPosition[2] = markerInfo.position[2] + (markerOffsets[markerInfo.layer][2])
                    MarkerPosition[3] = markerInfo.position[3] + (markerOffsets[markerInfo.layer][3])
                    -- Draw the marker path node
                    DrawCircle(MarkerPosition, 2.5, color)
                    -- Draw the connecting lines to its adjacent nodes
                    for i, node in markerInfo.adjacent do
                        otherMarker = GraphMarkers[node]
                        if otherMarker then
                            Marker2Position[1] = otherMarker.position[1] + markerOffsets[otherMarker.layer][1]
                            Marker2Position[2] = otherMarker.position[2] + markerOffsets[otherMarker.layer][2]
                            Marker2Position[3] = otherMarker.position[3] + markerOffsets[otherMarker.layer][3]
                            --DrawLinePop(MarkerPosition, Marker2Position, GraphOffsets[otherMarker.layer]['color'])
                            DrawLinePop(MarkerPosition, Marker2Position, color )
                        end
                    end
                end
            end
        end
    end
    for nodename, markerInfo in Scenario.MasterChain._MASTERCHAIN_.Markers or {} do
        if markerInfo['type'] == 'Blank Marker' then
            DrawCircle(markerInfo['position'], 8, 'ffFF0000' )
            DrawCircle(markerInfo['position'], 7.5, 'ff000000' )
            DrawCircle(markerInfo['position'], 9, 'ffF4A460' )
        end
        if markerInfo['type'] == 'Expansion Area' then
            DrawCircle(markerInfo['position'], 5, 'ffFF0000' )
            DrawCircle(markerInfo['position'], 4.5, 'ff808080' )
            DrawCircle(markerInfo['position'], 6, 'ffF4A460' )
        end
        if markerInfo['type'] == 'Large Expansion Area' then
            DrawCircle(markerInfo['position'], 10, 'ffFF0000' )
            DrawCircle(markerInfo['position'], 9.5, 'ffFFFFFF' )
            DrawCircle(markerInfo['position'], 11, 'ffF4A460' )
        end
        if markerInfo['type'] == 'Naval Area' then
            DrawCircle(markerInfo['position'], 8, 'ffFF0000' )
            DrawCircle(markerInfo['position'], 7.5, 'ff808080' )
            DrawCircle(markerInfo['position'], 9, 'ffF0F0FF' )
        end
    end
end

function DrawAIPathCache(DrawOnly)
    -- loop over all players in the game
    local FocussedArmy = GetFocusArmy()
    local LineCountOffset
    local LastNode

    for ArmyIndex, aiBrain in ArmyBrains do
        -- only draw the pathcache from the focussed army
        if FocussedArmy == ArmyIndex then
            -- is the player an AI-Uveso ?
            if aiBrain.PathCache then
                -- Loop over all paths that starts from "StartNode"
                for StartNode, EndNodeCache in aiBrain.PathCache do
                    LineCountOffset = 0
                    -- Loop over all paths starting from StartNode and ending in EndNode
                    for EndNode, Path in EndNodeCache do
                        -- Loop over all threatWeighted paths
                        for threatWeight, PathNodes in Path do
                            -- Display only valid paths
                            if PathNodes.path ~= 'bad' then
                                LastNode = false
                                if PathNodes.path.path then
                                    -- loop over all path waypoints and draw lines.
                                    for NodeIndex, PathNode in PathNodes.path.path do
                                        -- continue if we don't want to draw this graph node
                                        if not DrawOnly or DrawOnly == PathNode.layer then
                                            if LastNode then
                                                -- If we draw a horizontal line, then draw the next line "under" the last line
                                                if mathabs(LastNode.position[1] - PathNode.position[1]) > mathabs(LastNode.position[3] - PathNode.position[3]) then
                                                    DirectionOffsetX = 0
                                                    DirectionOffsetY = 0.2
                                                -- else we are drawing vertical, then draw the next line "Right" near the last line
                                                else
                                                    DirectionOffsetX = 0.2
                                                    DirectionOffsetY = 0
                                                end
                                                DrawLinePop({LastNode.position[1] + LineCountOffset + DirectionOffsetX,     LastNode.position[2], LastNode.position[3] + LineCountOffset + DirectionOffsetY},     {PathNode.position[1] + LineCountOffset + DirectionOffsetX,     PathNode.position[2],PathNode.position[3] + LineCountOffset + DirectionOffsetY},     'ff000000' )
                                                DrawLinePop({LastNode.position[1] + LineCountOffset,                        LastNode.position[2], LastNode.position[3] + LineCountOffset},                        {PathNode.position[1] + LineCountOffset,                        PathNode.position[2],PathNode.position[3] + LineCountOffset},                        markerOffsets[PathNode.layer]['color'] )
                                                DrawLinePop({LastNode.position[1] + LineCountOffset + DirectionOffsetX * 2, LastNode.position[2], LastNode.position[3] + LineCountOffset + DirectionOffsetY * 2}, {PathNode.position[1] + LineCountOffset + DirectionOffsetX * 2, PathNode.position[2],PathNode.position[3] + LineCountOffset + DirectionOffsetY * 2}, markerOffsets[PathNode.layer]['color'] )
                                            end
                                            LastNode = PathNode
                                        end
                                    end
                                    LineCountOffset = LineCountOffset + 0.3
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function CreateMarkerGrid(movementLayer)
    AIDebug("* AI-Uveso: Function CreateMarkerGrid("..movementLayer..") started.", true)
    local MarkerGrid = MarkerGrid
    local posX
    local posZ
    MarkerGrid[movementLayer] = {}
    for x = 0, MarkerGridCountX - 1 do
        --AIDebug("* AI-Uveso: Function CreateMarkerGrid("..movementLayer..") working on row "..x.."", true)
        MarkerGrid[movementLayer][x] = {}
        for z = 0, MarkerGridCountZ - 1 do
            -- don't search for a free marker place for Air
            if movementLayer == "Air" then
                posX = x * MarkerGridSizeX + MarkerGridSizeX / 2 + playableArea[1]
                posZ = z * MarkerGridSizeZ + MarkerGridSizeZ / 2 + playableArea[2]
            else
                posX, posZ = getFreeMarkerPosition(x, z, movementLayer)
            end
            if posX then -- we asume that posZ is present like posX.
                MarkerGrid[movementLayer][x][z] =
                    {
                        ['position'] = VECTOR3( posX, GetSurfaceHeight(posX,posZ), posZ ),
                        ['adjacentTo'] = {},
                    }
            end
        end
    end
    return
end

function GetMarkerTable(movementLayer)
    return MarkerGrid[movementLayer]
end

function ConnectMarkerWithPathing(movementLayer)
    local MarkerGrid = MarkerGrid
    local xA
    local zA
    for x = 0, MarkerGridCountX - 1 do
        for z = 0, MarkerGridCountZ - 1 do
            if MarkerGrid[movementLayer][x][z] then
                -- connecting marker x,z with adjacents
                --AIDebug("* AI-Uveso: Function ConnectMarkerWithoutPathing() connecting marker ("..x..", "..z..") with adjacents.", true)
-- this is to draw the pathing on a specific marker
-- ConnectMarkerWithPathing need to be run as forkedThread
--if x == 5 and z == 16 then
--while true do
--coroutine.yield(2)
                -- search up/right, right and down/right
                xA = 1
                if x + xA <= MarkerGridCountX - 1 then
                    for zA = -1, 1, 1 do
                        if z + zA >= 0 and z + zA <= MarkerGridCountZ - 1 then
                            if movementLayer == "Air" or CanPathBetweenMarker(x, z, x + xA, z + zA, movementLayer) then
                                -- add the new marker to the old adjacentTo table
                                table.insert(MarkerGrid[movementLayer][x][z].adjacentTo,{x + xA, z + zA})
                                -- add the old marker to the new adjacentTo table
                                table.insert(MarkerGrid[movementLayer][x + xA][z + zA].adjacentTo,{x, z})
                            end
                        end
                    end
                end
                -- search down/left
                xA = 0
                zA = 1
                if z + zA <= MarkerGridCountZ - 1 then
                    if movementLayer == "Air" or CanPathBetweenMarker(x, z, x + xA, z + zA, movementLayer) then
                        -- add the new marker to the old adjacentTo table
                        table.insert(MarkerGrid[movementLayer][x][z].adjacentTo,{x + xA, z + zA})
                        -- add the old marker to the new adjacentTo table
                        table.insert(MarkerGrid[movementLayer][x + xA][z + zA].adjacentTo,{x, z})
                    end
                end
--end
--end
            end
        end
    end
end

function CanPathBetweenMarker(x, z, xA, zA, movementLayer, useAbsolutCoords)
    local PathMap = PathMap
    --AIWarn("* AI-Uveso: Function CanPathBetweenMarker() from grid ["..x.."]["..z.."] to adjacent ["..xA.."]["..zA.."].", true)
    local pos
    local posA
    -- check if we use marker index or map position
    if not useAbsolutCoords then
        pos = MarkerGrid[movementLayer][x][z].position
        posA = MarkerGrid[movementLayer][xA][zA].position
    else
        pos = {x, 0, z}
        posA = {xA, 0, zA}
    end
    if not pos or not posA then
        return
    end

    --AIWarn("* AI-Uveso: Function CanPathBetweenMarker() from pos1("..pos[1]..", "..pos[3]..") to posA("..posA[1]..", "..posA[3]..").", true)
    local distance = VDist2(pos[1], pos[3], posA[1], posA[3])
    local steps = mathceil(distance) * 1.1
    local xstep = (posA[1] - pos[1]) / steps
    local zstep = (posA[3] - pos[3]) / steps
    --AIWarn("xstep: "..xstep.." - zstep: "..zstep.."")


    -- orientation layerOffsets
    local alpha = mathatan2(pos[3] - posA[3] ,pos[1] - posA[1]) * ( 180 / math.pi )
    --AIWarn("alpha "..alpha)
    --   45  90  135
    --    0  ##  180
    --  -45 -90 -135 
    if mathabs(alpha) <= 22.5 or mathabs(alpha) >= 157.5 then
        --AIWarn("- L R")
        xH = 0
        zH = 1
        -- L R
    elseif mathabs(alpha) >= 67.5 and mathabs(alpha) <= 112.5 then
        --AIWarn("| U D")
        xH = 1
        zH = 0
        -- U D
    elseif alpha >= 22.5 and alpha <= 67.5 or alpha <= -112.5 and alpha >= -157.5 then
        --AIWarn("\\ LU RD")
        xH = -0.8
        zH = 0.8
        -- LU RD
    else
        --AIWarn("/ LD RU")
        xH = -0.8
        zH = -0.8
        -- LD RU
    end

    local passed = 0
    local layerrestricted, lineBlocked, cellBlocked, shoreline, posX, posZ
    for o = -2, 2, 2 do
        lineBlocked = false
        for i = 0, steps do
            posX = mathfloor(o*xH + pos[1] +  (xstep * i))
            posZ = mathfloor(o*zH + pos[3] +  (zstep * i))
            layerrestricted = false
            if movementLayer == "Land" then
                if PathMap[posX][posZ].layer ~= "Land" then
                    layerrestricted = true
                end
            elseif movementLayer == "Water" then
                if PathMap[posX][posZ].layer ~= "Seabed" and PathMap[posX][posZ].layer ~= "Abyss" then
                    layerrestricted = true
                end
            elseif movementLayer == "Amphibious" then
                if PathMap[posX][posZ].layer == "Abyss" then
                    layerrestricted = true
                end
            elseif movementLayer == "Hover" then
                layerrestricted = false
            end
            cellBlocked = PathMap[posX][posZ].blocked 
                or PathMap[posX-1][posZ].blocked
                or PathMap[posX][posZ-1].blocked
                or PathMap[posX+1][posZ+1].blocked
                or PathMap[posX-1][posZ-1].blocked
            if movementLayer == "Hover" then
                -- special rule for Hover, we can't be blocked by terrain on beach, seabed or Abyss
                -- except the shoreline on beach 1 cell near land
                shoreline = PathMap[posX][posZ].layer == "Land"
                    or PathMap[posX-1][posZ].layer == "Land"
                    or PathMap[posX][posZ-1].layer == "Land"
                    or PathMap[posX+1][posZ+1].layer == "Land"
                    or PathMap[posX-1][posZ-1].layer == "Land"
                if lineBlocked or layerrestricted or (cellBlocked and shoreline) then
                    --AIWarn("blocked", true)
                    --DrawLine( {pos[1] + o*xH, pos[2] + 0.1, pos[3] + o*zH}, { posX, pos[2] + 0.1, posZ}, 'ffFF0000' )
                    lineBlocked = true
                    break
                else
                    --DrawLine( {pos[1] + o*xH, pos[2] + 0.1, pos[3] + o*zH}, { posX, pos[2] + 0.1, posZ}, 'ff0000FF' )
                    --AIWarn("free", true)
                end
            else
                if lineBlocked or layerrestricted or (cellBlocked and movementLayer ~= "Water") then
                    --AIWarn("blocked", true)
                    --DrawLine( {pos[1] + o*xH, pos[2] + 0.1, pos[3] + o*zH}, { posX, pos[2] + 0.1, posZ}, 'ffFF0000' )
                    lineBlocked = true
                    break
                else
                    --DrawLine( {pos[1] + o*xH, pos[2] + 0.1, pos[3] + o*zH}, { posX, pos[2] + 0.1, posZ}, 'ff0000FF' )
                    --AIWarn("free", true)
                end
            end
            --DrawLine( {pos[1] , pos[2] + 0.1, pos[3]}, { mathfloor( pos[1] + (xstep * i)), pos[2] + 0.1, mathfloor(pos[3] + (zstep * i))}, 'ffFFFFFF' )
        end
        if not lineBlocked then
            passed = passed + 1
            if passed >= 1 then
                return true
            end
        end
        --AIWarn(" "..mathfloor(o*xH).." "..mathfloor(o*zH).." BLOCKED")
    end
    return false
end

function getFreeMarkerPosition(x, z, movementLayer)
    local PathMap = PathMap
    local debugPrint = false
--    if x == 6 and z == 18 then
--        debugPrint = true
--    end
    local zcStart = mathfloor(z * MarkerGridSizeZ + playableArea[2])
    local zcEnd = mathfloor(z * MarkerGridSizeZ + MarkerGridSizeZ + playableArea[2])
    local xcStart =  mathfloor(x * MarkerGridSizeX + playableArea[1])
    local xcEnd = mathfloor(x * MarkerGridSizeX + MarkerGridSizeX + playableArea[1])
    
    local area = 0
    local blocked, AreaNeedReplace, layerrestricted
    local cellBlocked, shoreBlocked, land, water
    for zc = zcStart, zcEnd do
        --AIWarn("* AI-Uveso:  "..zc.."#####################################################", debugPrint)
        if not blocked then
            blocked = true
            area = area + 1
        end
        for xc = xcStart, xcEnd do
            layerrestricted = false
            if movementLayer == "Land" then
                if PathMap[xc][zc].layer ~= "Land" then
                    layerrestricted = true
                end
            elseif movementLayer == "Water" then
                if PathMap[xc][zc].layer ~= "Seabed" and PathMap[xc][zc].layer ~= "Abyss" then
                    layerrestricted = true
                end
            elseif movementLayer == "Amphibious" then
                if PathMap[xc][zc].layer == "Abyss" then
                    layerrestricted = true
                end
            elseif movementLayer == "Hover" then
                layerrestricted = false
            end
            -- special rule for hover and amphibious, don't make a marker on the shoreline between land and water if its blocked
            cellBlocked = PathMap[xc][zc].blocked 
                or PathMap[xc-1][zc].blocked
                or PathMap[xc][zc-1].blocked
                or PathMap[xc+1][zc+1].blocked
                or PathMap[xc-1][zc-1].blocked
            land = PathMap[xc][zc].layer == "Land"
                or PathMap[xc-1][zc].layer == "Land"
                or PathMap[xc][zc-1].layer == "Land"
                or PathMap[xc+1][zc+1].layer == "Land"
                or PathMap[xc-1][zc-1].layer == "Land"
            water = PathMap[xc][zc].layer == "Water"
                or PathMap[xc-1][zc].layer == "Water"
                or PathMap[xc][zc-1].layer == "Water"
                or PathMap[xc+1][zc+1].layer == "Water"
                or PathMap[xc-1][zc-1].layer == "Water"
            shoreBlocked = cellBlocked and land and water
            if (movementLayer == "Hover" or movementLayer == "Amphibious") and (PathMap[xc][zc].blocked or shoreBlocked or layerrestricted) then
                PathMap[xc][zc].cellArea = 0
                if not blocked then
                    blocked = true
                    area = area + 1
                end
                --AIWarn("* AI-Uveso:  "..xc.." "..zc.." "..area.." blocked 1 for layer "..movementLayer.." Blocked:"..repr(PathMap[xc][zc].blocked).." Restricted:"..repr(layerrestricted).." Maplayer:"..repr(PathMap[xc][zc].layer), debugPrint)
            elseif movementLayer ~= "Hover" and ((PathMap[xc][zc].blocked and movementLayer ~= "Water") or layerrestricted) then
                PathMap[xc][zc].cellArea = 0
                if not blocked then
                    blocked = true
                    area = area + 1
                end
                --AIWarn("* AI-Uveso:  "..xc.." "..zc.." "..area.." blocked 2 for layer "..movementLayer.." Blocked:"..repr(PathMap[xc][zc].blocked).." Restricted:"..repr(layerrestricted).." Maplayer:"..repr(PathMap[xc][zc].layer), debugPrint)
            else
                if zc - 1 >= zcStart and PathMap[xc][zc-1].cellArea and PathMap[xc][zc-1].cellArea > 0 then
                    --AIWarn("* AI-Uveso:  "..xc.." "..zc.." "..area.." UP", debugPrint)
                    if xc - 1 >= xcStart and PathMap[xc-1][zc].cellArea and PathMap[xc-1][zc].cellArea > 0 then
                        AreaNeedReplace = PathMap[xc][zc-1].cellArea
                        PathMap[xc][zc].cellArea = PathMap[xc-1][zc].cellArea
                    else
                        PathMap[xc][zc].cellArea = PathMap[xc][zc-1].cellArea
                        AreaNeedReplace = area
                    end
                    --AIWarn("* AI-Uveso:  "..xc.." "..zc.." "..area.." change "..AreaNeedReplace.." to "..PathMap[xc][zc].cellArea, debugPrint)
                    if PathMap[xc][zc].cellArea ~= AreaNeedReplace then
                        for zm = zcStart, zcEnd do
                            for xm = xcStart, xcEnd do
                                if PathMap[xm][zm].cellArea == AreaNeedReplace then
                                    PathMap[xm][zm].cellArea = PathMap[xc][zc].cellArea
                                end
                            end
                        end
                    end
                elseif xc - 1 >= xcStart and PathMap[xc-1][zc].cellArea and PathMap[xc-1][zc].cellArea > 0 then
                    --AIWarn("* AI-Uveso:  "..xc.." "..zc.." "..area.." LEFT", debugPrint)
                    PathMap[xc][zc].cellArea = PathMap[xc-1][zc].cellArea
                else
                    if blocked then
                        blocked = false
                    else
                        area = area + 1
                    end
                    PathMap[xc][zc].cellArea = area
                    --AIWarn("* AI-Uveso:  "..xc.." "..zc.." "..area.." NEW", debugPrint)
                end
            end
        end
    end

    -- count graph fileds to find the biggest graph area inside the grid
--    local text
    local count = {}
    local countMax, countMaxGraph = 0, nil
    for zc = zcStart, zcEnd do
--        text = ""
        for xc = xcStart, xcEnd do
            if PathMap[xc][zc].cellArea ~= 0 then
                if count[PathMap[xc][zc].cellArea] then
                    count[PathMap[xc][zc].cellArea] = count[PathMap[xc][zc].cellArea] + 1
                else
                    count[PathMap[xc][zc].cellArea] = 1
                end
                if count[PathMap[xc][zc].cellArea] > countMax then
                    countMax = count[PathMap[xc][zc].cellArea]
                    countMaxGraph = PathMap[xc][zc].cellArea
                end
            end
--            text = text.." "..PathMap[xc][zc].cellArea or "x"
        end
--        AIWarn(text, debugPrint)
    end
    -- if we don't have at least 1 free graph area, then return false
    if not countMaxGraph then
        return false, false
    end
    -- check if we have only 1 graph (free place) and if the middle is not blocked
    if count[1] and not count[2] then
        local returnX = mathfloor(x * MarkerGridSizeX + MarkerGridSizeX/ 2 + playableArea[1])
        local returnZ = mathfloor(z * MarkerGridSizeZ + MarkerGridSizeZ / 2 + playableArea[2])
        if PathMap[returnX][returnZ].cellArea ~= 0 then
            --AIWarn("Short cut count[1] and not count[2] "..repr(count), true)
            return returnX, returnZ
        end
    end

--    AIWarn("Grid Areas: "..repr(count), debugPrint)
--    AIWarn("Biggest area ID: "..countMaxGraph.." with "..countMax.." positions", debugPrint)
--    AIWarn("Search grid "..xcStart.." "..xcEnd.." "..zcStart.." "..zcEnd.." ", debugPrint)

    -- search for the center position of MaxGraph
    local centerX, centerZ, centerCount = 0, 0, 0
    for zc = zcStart, zcEnd do
        for xc = xcStart, xcEnd do
            --AIWarn("* AI-Uveso:  "..xc.." "..zc.." cellArea:"..repr(PathMap[xc][zc].cellArea), debugPrint)
            if PathMap[xc][zc].cellArea == countMaxGraph then
                centerX = centerX + xc
                centerZ = centerZ + zc
                centerCount = centerCount + 1
            end
        end
    end
    centerX = mathfloor(centerX / centerCount)
    centerZ = mathfloor(centerZ / centerCount)
    --AIWarn("* AI-Uveso: centerX:"..centerX.." - centerZ:"..centerZ.."", debugPrint)
--    if 1 == 1 then
--        return centerX, centerZ
--    end

    -- search for all possible free places inside the grid
    local markerSize = 6
    local blockedTolerance = 0
    local blocked
    local possiblePositions = {}
    
    -- fast search for free center position
    blocked = 0
    for zm = mathfloor(centerZ - markerSize / 2), mathceil(centerZ + markerSize / 2) do
--        text = ""
        for xm = mathfloor(centerX - markerSize / 2), mathceil(centerX + markerSize / 2) do
            if PathMap[xm][zm].cellArea then
                if PathMap[xm][zm].cellArea ~= countMaxGraph then
                    blocked = blocked + 1
                    --text = text..PathMap[xm][zm].cellArea
--                else
--                    text = text.."+"
                end
            end
        end
        if blocked > blockedTolerance then
            break
        end
--        AIWarn(text, debugPrint)
    end
    -- is the square a valid place ?
    if blocked <= blockedTolerance then
        return centerX, centerZ
    end

    -- deep search for free position
    markerSize = 5
    blockedTolerance = 2
    if not possiblePositions[1] then
        for zc = zcStart - 3, zcEnd - markerSize + 3 do
            for xc = xcStart - 3, xcEnd - markerSize + 3 do
                blocked = 0
                for zm = zc, zc + markerSize - 1 do
                    for xm = xc, xc + markerSize - 1 do
                        if PathMap[xm][zm].cellArea then
                            if PathMap[xm][zm].cellArea ~= countMaxGraph then
                                blocked = blocked + 1
                            end
                        end
                        if blocked > blockedTolerance then
                            break
                        end
                    end
                    if blocked > blockedTolerance then
                        break
                    end
                end
                -- is the square a valid place ?
                if blocked <= blockedTolerance then
                    --AIWarn("place valid; "..(xc + markerSize / 2).." "..(zc + markerSize / 2).." ", debugPrint)
                    table.insert(possiblePositions, {mathfloor(xc + markerSize / 2), mathfloor (zc + markerSize / 2), blocked  })
                    blockedTolerance = blocked
                end
            end
        end
    end

    if not possiblePositions[1] then
        return false, false
    end

    -- remove positions with high block rate
    for index, freePostions in possiblePositions do
        if freePostions[3] > blockedTolerance then
            possiblePositions[index] = nil
            --AIWarn("place has to much blocked areas: possiblePositions["..index.."] = "..freePostions[3], debugPrint)
        end
    end
 
    -- now search for the closest free place to the center position
    local dist, closestDist, closestPos
    for index, freePostions in possiblePositions do
        dist = VDist2(freePostions[1], freePostions[2], centerX, centerZ)
        --AIWarn("dist "..dist, debugPrint)
        if not closestDist or closestDist > dist then
            --AIWarn("found closest free place! ", debugPrint)
            closestDist = dist
            closestPos = freePostions
        end
    end
    --AIWarn("Closest free place: "..repr(closestPos), debugPrint)
    if closestPos then
        return closestPos[1], closestPos[2]
    end
    -- no place for the marker found
    return false, false
end

function BuildGraphAreas(movementLayer)
    local old
    local GraphIndex = 0
    for xc, MarkerGridYrow in MarkerGrid[movementLayer] do
        for zc, markerInfo in MarkerGridYrow or {} do
            -- Do we have already an Index number for this Graph area ?
            if not markerInfo.GraphArea then
                GraphIndex = GraphIndex + 1
                markerInfo.GraphArea = GraphIndex
            end
            -- check adjancents
            for i, node in markerInfo.adjacentTo or {} do
                -- check if the new node has not a GraphIndex 
                if not MarkerGrid[movementLayer][node[1]][node[2]].GraphArea then
                    MarkerGrid[movementLayer][node[1]][node[2]].GraphArea = markerInfo.GraphArea
                -- the node has already a graph index. Overwrite all nodes connected to this node with the new index
                elseif MarkerGrid[movementLayer][node[1]][node[2]].GraphArea ~= markerInfo.GraphArea then
                    -- save the old index here, we will overwrite Markers[node].GraphArea
                    old = MarkerGrid[movementLayer][node[1]][node[2]].GraphArea
                    for xc2, MarkerGridYrow2 in MarkerGrid[movementLayer] do
                        for zc2, markerInfo2 in MarkerGridYrow2 or {} do
                            -- has this node the same index then our main marker ?
                            if markerInfo2.GraphArea == old then
                                markerInfo2.GraphArea = markerInfo.GraphArea
                            end
                        end
                    end
                end
            end
        end
    end
--[[
    -- Validate (only for debug printing)
    local GraphCountIndex = {}
    for x, MarkerGridYrow in MarkerGrid[movementLayer] do
        for z, markerInfo in MarkerGridYrow or {} do
            if markerInfo.GraphArea then
                GraphCountIndex[markerInfo.GraphArea] = GraphCountIndex[markerInfo.GraphArea] or 1
                GraphCountIndex[markerInfo.GraphArea] = GraphCountIndex[markerInfo.GraphArea] + 1
            end
        end
    end
    AIDebug('* AI-Uveso: BuildGraphAreas(): for '..movementLayer..' '..repr(GraphCountIndex), true)
--]]
end

function CreateNavalExpansions()
    AIDebug("* AI-Uveso: Function CreateNavalExpansions started.", true)
    local NavalMarkerPositions = {}
    local Blocked
    local markerInfo
    -- Search for naval areas
    for X, MarkerGridYrow in MarkerGrid["Water"] do
        for Z, markerInfo in MarkerGridYrow or {} do
            Blocked = false
            -- check if we are in the middle of water nodes 3x3 grid
            for ZW = -1, 1 do
                for XW = -1, 1 do
                    if not MarkerGrid["Water"][X+XW][Z+ZW] then
                        Blocked = true
                    end
                end
            end
            if not Blocked then
                Blocked = true
                -- check if we are sourrounded with land nodes (transition water/land) 5x5 grid outer ring
                for ZD = -2, 2 do
                    for XD = -2, 2 do
                        if (ZD == -2 or ZD == 2) or (XD == -2 or XD == 2) then
                            -- do we have land in 2 cells distance?
                            if MarkerGrid["Land"][X+XD][Z+ZD] then
                                -- check if we have an amphibious way from this land node to water
                                for i, nodePos in MarkerGrid["Hover"][X+XD][Z+ZD].adjacentTo or {} do
                                    -- checking node, if it has a conection to our naval marker
                                    for i2, nodePos2 in MarkerGrid["Hover"][nodePos[1]][nodePos[2]].adjacentTo or {} do
                                        if nodePos2[1] == X and nodePos2[2] == Z then
                                            -- check if the land and amphibious marker are at the same place
                                            if VDist2( MarkerGrid["Land"][X+XD][Z+ZD].position[1], MarkerGrid["Land"][X+XD][Z+ZD].position[3], MarkerGrid["Hover"][X+XD][Z+ZD].position[1], MarkerGrid["Hover"][X+XD][Z+ZD].position[3]) < 0.1 then
                                                Blocked = false
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if not Blocked then
                    -- check if we have a naval marker close to this area
                    for index, NAVALpostition in NavalMarkerPositions do
                        -- is this marker farther away than 60
                        if VDist2( markerInfo.position[1], markerInfo.position[3], NAVALpostition.x, NAVALpostition.z) < 60 then
                            Blocked = true
                            break
                        end
                    end
                    if not Blocked then
                        table.insert(NavalMarkerPositions, {x = markerInfo.position[1], z = markerInfo.position[3], GraphArea = MarkerGrid["Water"][X][Z].GraphArea } )
                    end
                end
            end
        end
    end
    return NavalMarkerPositions
end

function CreateLandExpansions()
    AIDebug("* AI-Uveso: Function CreateLandExpansions started.", true)
    local MassMarker = {}
    local MexInMarkerRange = {}
    local StartPosition = {}
    local NewExpansion = {}
    local alreadyUsed = {}
    local IndexTable = {}
    local gridX, gridZ, posX, posZ, MexInRange, UseThisMarker, count
    -- get player start positions
    for nodename, markerInfo in Scenario.MasterChain._MASTERCHAIN_.Markers or {} do
        if markerInfo['type'] == 'Blank Marker' then
            table.insert(StartPosition, {Position = markerInfo.position} )
        end
    end
    -- get all mass spots
    for _, v in Scenario.MasterChain._MASTERCHAIN_.Markers do
        if v.type == 'Mass' then
            if v.position[1] <= 8 or v.position[1] >= ScenarioInfo.size[1] - 8 or v.position[3] <= 8 or v.position[3] >= ScenarioInfo.size[2] - 8 then
                -- mass marker is too close to border, skip it.
            else
                table.insert(MassMarker, {Position = v.position})
            end
        end
    end
    -- search for areas with mex in range
    for X, MarkerGridYrow in MarkerGrid["Land"] do
        for Z, markerInfo in MarkerGridYrow or {} do
            -- check how many masspoints are located near the marker
            for k, v in MassMarker do
                if VDist2(markerInfo.position[1], markerInfo.position[3], v.Position[1], v.Position[3]) <= 30 then
                    MexInMarkerRange[X.."-"..Z] = MexInMarkerRange[X.."-"..Z] or {}
                    table.insert(MexInMarkerRange[X.."-"..Z], {Position = v.Position} )
                    -- insert mexcount into table
                    MexInMarkerRange[X.."-"..Z].mexcount = table.getn(MexInMarkerRange[X.."-"..Z])
                end
            end
        end
    end
    -- build table with index and minimum 2 mex spots
    count = 0
    for _, array in MexInMarkerRange do
        if array.mexcount > 1 then
            count = count +1
            IndexTable[count] = array
        end
    end
    -- sort table by mex count
    table.sort(IndexTable, function(a, b) return a.mexcount > b.mexcount end)
    -- Search for the center location of all mexes inside an expansion for pathing
    for k, v in IndexTable do
        count = 0
        posX = 0
        posZ = 0
        if type(v) == 'table' then
            for k2, v2 in v do
                if type(v2) == 'table' then
                    count = count + 1
                    posX = posX + v[k2].Position[1]
                    posZ = posZ + v[k2].Position[3]
                end
            end
            v.x =  posX / count
            v.z =  posZ / count
        end
    end
    -- make path check from center position to mex spot
    for k, v in IndexTable do
        if type(v) == 'table' then
            for k2, v2 in v do
                if type(v2) == 'table' then
                    if not CanPathBetweenMarker(v.x, v.z, v2.Position[1], v2.Position[3], "Land", true) then
                        -- delete this mex spot, we cant find a path to it
                        table.remove(v,k2)
                        v.mexcount = table.getn(v)
                    end
                end
            end
            -- if we have only 1 mex left, then this is no longer a possible expansion
            if v.mexcount < 2 then
                IndexTable[k] = nil
            end
        end
    end
    -- remove mexes that are already assigned to another expansion
    for k, v in IndexTable do
        if type(v) == 'table' then
            for k2, v2 in v do
                if type(v2) == 'table' then
                    if not alreadyUsed[v2.Position] then
                        alreadyUsed[v2.Position] = true
                    else
                        -- delete this mex spot, its already part of another expansion
                        table.remove(v,k2)
                        v.mexcount = table.getn(v)
                    end
                end
            end
            -- if we have only 1 mex left, then this is no longer a possible expansion
            if v.mexcount < 2 then
                IndexTable[k] = nil
            end
        end
    end
    -- Search again for the center location for marker placement
    for k, v in IndexTable do
        count = 0
        posX = 0
        posZ = 0
        if type(v) == 'table' then
            for k2, v2 in v do
                if type(v2) == 'table' then
                    count = count + 1
                    posX = posX + v[k2].Position[1]
                    posZ = posZ + v[k2].Position[3]
                end
            end
            v.x =  posX / count
            v.z =  posZ / count
        end
    end
    -- remove expansion areas that are to close to start or other expansion areas
    for k, v in IndexTable do
        MexInRange = v.mexcount
        UseThisMarker = true
        -- Search if we are near a start position
        for ks, vs in StartPosition do
            if VDist2(v.x, v.z, vs.Position[1], vs.Position[3]) < 80 then
                -- we are to close to a start position, don't use it as expansion
                UseThisMarker = false
                break
            end
        end
        -- check if we are to close to an expansion
        for ks, vn in NewExpansion do
            if VDist2(v.x, v.z, vn.x, vn.z) < 50 then
                -- we are to close to another expansion, don't use it
                UseThisMarker = false
                break
            end
        end
        -- save the expansion position
        if UseThisMarker then
            table.insert(NewExpansion, {x = v.x, z = v.z, MexInRange = v.mexcount} )
        end
    end
    -- make sure markers are placed on flat area
    for index, expansion in NewExpansion do
        gridX, gridZ = GetMarkerGridIndexFromPosition({expansion.x, 0, expansion.z})
        posX, posZ = getFreeMarkerPosition(gridX, gridZ, "Land")
        if posX then
            expansion.x = posX
            expansion.z = posZ
            expansion.GraphArea = MarkerGrid["Land"][gridX][gridZ].GraphArea
        else
            NewExpansion[index] = nil
        end
    end    
    return NewExpansion
end

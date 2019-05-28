--WARN('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] * AI-Uveso: offset simInit.lua' )

-- hooks for map validation on game start and debugstuff for pathfinding and base ranger.
local CREATEAIMARKERS = true
local MaxPassableElevation = 48
local MaxSlope = 0.36 -- 36
local MaxAngle = 0.18 -- 18
local CREATEDMARKERS = {}
local MarkerCountX = 30
local MarkerCountY = 30
local ScanResolution = 0.4
local FootprintSize = 0.20

--local DebugMarker = 'Marker0-9' -- TKP Lakes
--local DebugMarker = 'Marker1-0' -- Twin Rivers
local DebugMarker = false
local DebugValidMarkerPosition = false
local TraceEast = false
local TraceSouth = false
local TraceSouthEast = false
local TraceSouthWest = false

local OldSetupSessionFunction = SetupSession
function SetupSession()
    OldSetupSessionFunction()
    ValidateMapAndMarkers()
end

local OldBeginSessionFunction = BeginSession
function BeginSession()
    OldBeginSessionFunction()
    ValidateModFiles()
    if ScenarioInfo.Options.AIPathingDebug ~= 'off' then
        LOG('ForkThread(GraphRender)')
        ForkThread(GraphRender)
    end
    if CREATEAIMARKERS then
        LOG('ForkThread(RenderMarkerCreator)')
        ForkThread(RenderMarkerCreator)
    end
    if CREATEAIMARKERS then
        -- In case we are debugging with linedraw and waits we need to fork this function
        if DebugValidMarkerPosition then
            LOG('* AI-Uveso: Debug: ForkThread(CreateAIMarkers)')
            ForkThread(CreateAIMarkers)
        -- Fist calculate markers, then continue with the game start sequence.
        else
            LOG('* AI-Uveso: Function CreateAIMarkers() started!')
            local START = GetSystemTimeSecondsOnlyForProfileUse()
            CreateAIMarkers()
            local END = GetSystemTimeSecondsOnlyForProfileUse()
            LOG(string.format('* AI-Uveso: Function CreateAIMarkers() finished, runtime: %.2f seconds.', END - START  ))

        end
    end
end

local OldOnCreateArmyBrainFunction = OnCreateArmyBrain
function OnCreateArmyBrain(index, brain, name, nickname)
    OldOnCreateArmyBrainFunction(index, brain, name, nickname)
    -- check if we have an Ai brain that is not a civilian army
    if brain.BrainType == 'AI' and nickname ~= 'civilian' then
        -- check if we need to set a new unitcap for the AI. (0 = we are using the player unit cap)
        if tonumber(ScenarioInfo.Options.AIUnitCap) > 0 then
            LOG('* AI-Uveso: OnCreateArmyBrain: Setting AI unit cap to '..ScenarioInfo.Options.AIUnitCap..' ('..nickname..')')
            SetArmyUnitCap(index,tonumber(ScenarioInfo.Options.AIUnitCap))
        end
    end
end

local KnownMarkerTypes = {
    ['Air Path Node']=true,
    ['Amphibious Path Node']=true,
    ['Blank Marker']=true,
    ['Camera Info']=true,
    ['Combat Zone']=true,
    ['Defensive Point']=true,
    ['Effect']=true,
    ['Expansion Area']=true,
    ['Hydrocarbon']=true,
    ['Island']=true,
    ['Land Path Node']=true,
    ['Large Expansion Area']=true,
    ['Mass']=true,
    ['Naval Area']=true,
    ['Naval Defensive Point']=true,
    ['Naval Exclude']=true,
    ['Naval Link']=true,
    ['Naval Rally Point']=true,
    ['Protected Experimental Construction']=true,
    ['Rally Point']=true,
    ['Transport Marker']=true,
    ['Water Path Node']=true,
    ['Weather Definition']=true,
    ['Weather Generator']=true,
 }
local BaseLocations = {
    ['Blank Marker']         = { ['priority'] = 4 },
    ['Naval Area']           = { ['priority'] = 3 },
    ['Large Expansion Area'] = { ['priority'] = 2 },
    ['Expansion Area']       = { ['priority'] = 1 },
}
local Offsets = {
    ['DefaultLand']       = { [1] =  0.0, [2] =  0.0, [3] =  0.0, ['color'] = 'ffF4A460', },
    ['DefaultWater']      = { [1] = -0.5, [2] =  0.0, [3] = -0.5, ['color'] = 'ff000080', },
    ['DefaultAmphibious'] = { [1] = -1.0, [2] =  0.0, [3] = -1.0, ['color'] = 'ff00BFFF', },
    ['DefaultAir']        = { [1] = -1.5, [2] =  0.0, [3] = -1.5, ['color'] = 'ffEFEFFF', },
}

local MarkerDefaults = {
    ['Land Path Node']          = { ['graph'] ='DefaultLand',       ['color'] = 'ff808080', },
    ['Water Path Node']         = { ['graph'] ='DefaultWater',      ['color'] = 'ff0000ff', },
    ['Amphibious Path Node']    = { ['graph'] ='DefaultAmphibious', ['color'] = 'ff404060', },
    ['Air Path Node']           = { ['graph'] ='DefaultAir',        ['color'] = 'ffffffff', },
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
function ValidateMapAndMarkers()
    -- Check norushradius
    if ScenarioInfo.norushradius and ScenarioInfo.norushradius > 0 then
        if ScenarioInfo.norushradius < 10 then
            WARN('* AI-Uveso: ValidateMapAndMarkers: norushradius is too smal ('..ScenarioInfo.norushradius..')! Set radius to minimum (15).')
            ScenarioInfo.norushradius = 15
        else
            LOG('* AI-Uveso: ValidateMapAndMarkers: norushradius is OK. ('..ScenarioInfo.norushradius..')')
        end
    else
        WARN('* AI-Uveso: ValidateMapAndMarkers: norushradius is missing! Set radius to default (20).')
        ScenarioInfo.norushradius = 20
    end

    -- Check map markers
    local TEMP = {}
    local UNKNOWNMARKER
    local dist
    for k, v in Scenario.MasterChain._MASTERCHAIN_.Markers do
        -- Check if the marker is known. If not, send a debug message
        if not KnownMarkerTypes[v.type] then
            if not UNKNOWNMARKER[v.type] then
                LOG('* AI-Uveso: ValidateMapAndMarkers: Unknown MarkerType: [\''..v.type..'\']=true,')
                UNKNOWNMARKER[v.type] = true
            end
        end
        -- Check Mass Marker
        if v.type == 'Mass' then
            if v.position[1] <= 8 or v.position[1] >= ScenarioInfo.size[1] - 8 or v.position[3] <= 8 or v.position[3] >= ScenarioInfo.size[2] - 8 then
                WARN('* AI-Uveso: ValidateMapAndMarkers: MarkerType: [\''..v.type..'\'] is too close to map border. IndexName = ['..k..']. (Mass marker deleted!!!)')
                Scenario.MasterChain._MASTERCHAIN_.Markers[k] = nil
            end
        end
        -- Check Waypoint Marker
        if MarkerDefaults[v.type] then
            if v.adjacentTo then
                local adjancents = STR_GetTokens(v.adjacentTo or '', ' ')
                if adjancents[0] then
                    for i, node in adjancents do
                        --local otherMarker = Scenario.MasterChain._MASTERCHAIN_.Markers[node]
                        if not Scenario.MasterChain._MASTERCHAIN_.Markers[node] then
                            WARN('* AI-Uveso: ValidateMapAndMarkers: adjacentTo is wrong in marker ['..k..'] - MarkerType: [\''..v.type..'\']. - Adjacent marker ['..node..'] is missing.')
                        end
                    end
                else
                    --WARN('* AI-Uveso: ValidateMapAndMarkers: adjacentTo is empty in marker ['..k..'] - MarkerType: [\''..v.type..'\']. - Pathmarker must have an adjacent marker for pathing.')
                end
            else
                --WARN('* AI-Uveso: ValidateMapAndMarkers: adjacentTo is missing in marker ['..k..'] - MarkerType: [\''..v.type..'\']. - Pathmarker must have an adjacent marker for pathing.')
            end
            -- Checking marker type/graph 
            if MarkerDefaults[v.type]['graph'] ~= v.graph then
                WARN('* AI-Uveso: ValidateMapAndMarkers: graph missmatch in marker ['..k..'] - MarkerType: [\''..v.type..'\']. - marker.type is ('..repr(v.graph)..'), but should be ('..MarkerDefaults[v.type]['graph']..').')
                -- save the correct graph type 
                v.graph = MarkerDefaults[v.type]['graph']
            end
            -- Checking colors (for debug)
            if MarkerDefaults[v.type]['color'] ~= v.color then
                -- we actual don't print a debugmessage here. This message is for debuging a debug function :)
                --LOG('* AI-Uveso: ValidateMapAndMarkers: color missmatch in marker ['..k..'] - MarkerType: [\''..v.type..'\']. marker.color is ('..repr(v.color)..'), but should be ('..MarkerDefaults[v.type]['color']..').')
                v.color = MarkerDefaults[v.type]['color']
            end
        -- Check BaseLocations distances to other locations
        elseif BaseLocations[v.type] then
            for k2, v2 in Scenario.MasterChain._MASTERCHAIN_.Markers do
                if BaseLocations[v2.type] and v ~= v2 then
                    local dist = VDist2( v.position[1], v.position[3], v2.position[1], v2.position[3] )
                    -- Are we checking a Start location, and another marker is nearer then 80 units ?
                    if v.type == 'Blank Marker' and v2.type ~= 'Blank Marker' and dist < 80 then
                        LOG('* AI-Uveso: ValidateMapAndMarkers: Marker [\''..k2..'\'] is to close to Start Location [\''..k..'\']. Distance= '..math.floor(dist)..' (under 80).')
                        --Scenario.MasterChain._MASTERCHAIN_.Markers[k2] = nil
                    -- Check if we have other locations that have a low distance (under 60)
                    elseif v.type ~= 'Blank Marker' and v2.type ~= 'Blank Marker' and dist < 60 then
                        -- Check priority from small locations up to main base.
                        if BaseLocations[v.type].priority >= BaseLocations[v2.type].priority then
                            LOG('* AI-Uveso: ValidateMapAndMarkers: Marker [\''..k2..'\'] is to close to Marker [\''..k..'\']. Distance= '..math.floor(dist)..' (under 60).')
                            -- Not used at the moment, but we can delete the location with the lower priority here.
                            -- This is used for debuging the locationmanager, so we can be sure that locations are not overlapping.
                            --Scenario.MasterChain._MASTERCHAIN_.Markers[k2] = nil
                        end
                    end
                end
            end
        end
    end
end

function GraphRender()
    -- wait 10 seconds at gamestart before we start debuging
    WaitTicks(100)
    while true do
        -- draw all paths with location radius and AI Pathfinding
        if ScenarioInfo.Options.AIPathingDebug == 'all' or ScenarioInfo.Options.AIPathingDebug == 'path' then
            -- display first all land nodes (true will let them blink)
            if GetGameTimeSeconds() < 15 then
                DrawPathGraph('DefaultLand', false)
                DrawPathGraph('DefaultAmphibious', false)
                DrawPathGraph('DefaultWater', false)
                --DrawPathGraph('DefaultAir', false)
            elseif GetGameTimeSeconds() < 20 then
                --DrawPathGraph('DefaultAmphibious', false)
                --DrawPathGraph('DefaultWater', false)
                --DrawPathGraph('DefaultAir', false)
                DrawPathGraph('DefaultLand', true)
            -- display amphibious nodes
            elseif GetGameTimeSeconds() < 25 then
                --DrawPathGraph('DefaultLand', false)
                --DrawPathGraph('DefaultWater', false)
                --DrawPathGraph('DefaultAir', false)
                DrawPathGraph('DefaultAmphibious', true)
            -- water nodes
            elseif GetGameTimeSeconds() < 30 then
                --DrawPathGraph('DefaultLand', false)
                --DrawPathGraph('DefaultAmphibious', false)
                --DrawPathGraph('DefaultAir', false)
                DrawPathGraph('DefaultWater', true)
            -- air nodes
            elseif GetGameTimeSeconds() < 35 then
                --DrawPathGraph('DefaultLand', false)
                --DrawPathGraph('DefaultAmphibious', false)
                --DrawPathGraph('DefaultWater', false)
                DrawPathGraph('DefaultAir', true)
            elseif GetGameTimeSeconds() < 40 then
                DrawPathGraph('DefaultLand', false)
                DrawPathGraph('DefaultAmphibious', false)
                DrawPathGraph('DefaultWater', false)
                --DrawPathGraph('DefaultAir', false)
            end
            -- Draw the radius of each base(manager)
            if ScenarioInfo.Options.AIPathingDebug == 'all' then
                DrawBaseRanger()
            end
            DrawAIPatchCache()
        -- Display land path permanent
        elseif ScenarioInfo.Options.AIPathingDebug == 'land' then
            DrawPathGraph('DefaultLand', false)
            DrawAIPatchCache('DefaultLand')
        -- Display water path permanent
        elseif ScenarioInfo.Options.AIPathingDebug == 'water' then
            DrawPathGraph('DefaultWater', false)
            DrawAIPatchCache('DefaultWater')
        -- Display amph path permanent
        elseif ScenarioInfo.Options.AIPathingDebug == 'amph' then
            DrawPathGraph('DefaultAmphibious', false)
            DrawAIPatchCache('DefaultAmphibious')
        -- Display air path permanent
        elseif ScenarioInfo.Options.AIPathingDebug == 'air' then
            DrawPathGraph('DefaultAir', false)
            DrawAIPatchCache('DefaultAir')
        end
        WaitTicks(2)
    end
end

function DrawBaseRanger()
    -- get the range of combat zones
    local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Uveso/lua/AI/uvesoutilities.lua').GetDangerZoneRadii()
    -- Render the radius of any base and expansion location
    if Scenario.MasterChain._MASTERCHAIN_.BaseRanger then
        for Index, ArmyRanger in Scenario.MasterChain._MASTERCHAIN_.BaseRanger do
            for nodename, markerInfo in ArmyRanger do
                if nodename == 'MAIN' then
                    DrawCircle(markerInfo.Pos, BasePanicZone, 'ffFF0000')
                    DrawCircle(markerInfo.Pos, BaseMilitaryZone, 'ffFF0000')
                end
                -- Draw the inner circle black
                DrawCircle(markerInfo.Pos, markerInfo.Rad-0.5, 'ff000000')
                -- Draw the main circle white
                DrawCircle(markerInfo.Pos, markerInfo.Rad, 'ffFFE0E0')
            end
        end
    end
end

function DrawPathGraph(DrawOnly,Blink)
    local color
    if Blink then
        colors['counter'] = colors['counter'] + 1
        if colors['counter'] > colors['countermax'] then
            colors['counter'] = 0
            --LOG('lastcolorindex:'..colors['lastcolorindex']..' - table.getn(colors)'..table.getn(colors))
            if colors['lastcolorindex'] >= (table.getn(colors)) then
                colors['lastcolorindex'] = 1
            else
                colors['lastcolorindex'] = colors['lastcolorindex'] + 1
            end
        end
        color = colors[colors['lastcolorindex']]
    else
        color = Offsets[DrawOnly]['color']
    end
    local AIAttackUtils = import('/lua/ai/aiattackutilities.lua')
    local MarkerPosition = {0,0,0}
    local Marker2Position = {0,0,0}
    -- Render the connection between the path nodes for the specific graph
    for Layer, LayerMarkers in AIAttackUtils.GetPathGraphs() do
        for graph, GraphMarkers in LayerMarkers do
            for nodename, markerInfo in GraphMarkers do
                if DrawOnly and DrawOnly ~= markerInfo.graphName then
                    continue
                end
                MarkerPosition[1] = markerInfo.position[1] + (Offsets[markerInfo.graphName][1])
                MarkerPosition[2] = markerInfo.position[2] + (Offsets[markerInfo.graphName][2])
                MarkerPosition[3] = markerInfo.position[3] + (Offsets[markerInfo.graphName][3])
                -- Draw the marker path node
                DrawCircle(MarkerPosition, 5, Offsets[markerInfo.graphName]['color'] or colors[colors['lastcolorindex']] )
                -- Draw the connecting lines to its adjacent nodes
                for i, node in markerInfo.adjacent do
                    local otherMarker = Scenario.MasterChain._MASTERCHAIN_.Markers[node]
                    if otherMarker then
                        Marker2Position[1] = otherMarker.position[1] + Offsets[otherMarker.graph][1]
                        Marker2Position[2] = otherMarker.position[2] + Offsets[otherMarker.graph][2]
                        Marker2Position[3] = otherMarker.position[3] + Offsets[otherMarker.graph][3]
                        --DrawLinePop(MarkerPosition, Marker2Position, GraphOffsets[otherMarker.graph]['color'])
                        DrawLinePop(MarkerPosition, Marker2Position, color )
                    end
                end
            end
        end
    end
end

function DrawAIPatchCache(DrawOnly)
    -- loop over all players in the game
    for ArmyIndex, aiBrain in ArmyBrains do
        -- is the player an AI-Uveso ?
        if aiBrain.Uveso and aiBrain.PathCache then
            local LineCountOffset = 0
            local Pos1 = {}
            local Pos2 = {}
            -- Loop over all paths that starts from "StartNode"
            for StartNode, EndNodeCache in aiBrain.PathCache do
                LineCountOffset = 0
                -- Loop over all paths starting from StartNode and ending in EndNode
                for EndNode, Path in EndNodeCache do
                    -- Loop over all threatWeighted paths
                    for threatWeight, PathNodes in Path do
                        -- Display only valid paths
                        if PathNodes.path ~= 'bad' then
                            local LastNode = false
                            if not PathNodes.path.path then
                                continue
                            end
                            -- loop over all path waypoints and draw lines.
                            for NodeIndex, PathNode in PathNodes.path.path do
                                -- continue if we don't want to draw this graph node
                                if DrawOnly and DrawOnly ~= PathNode.graphName then
                                    continue
                                end
                                if LastNode then
                                    -- If we draw a horizontal line, then draw the next line "under" the last line
                                    if math.abs(LastNode.position[1] - PathNode.position[1]) > math.abs(LastNode.position[3] - PathNode.position[3]) then
                                        DirectionOffsetX = 0
                                        DirectionOffsetY = 0.2
                                    -- else we are drawing vertical, then draw the next line "Right" near the last line
                                    else
                                        DirectionOffsetX = 0.2
                                        DirectionOffsetY = 0
                                    end
                                    DrawLinePop({LastNode.position[1] + LineCountOffset + DirectionOffsetX,     LastNode.position[2], LastNode.position[3] + LineCountOffset + DirectionOffsetY},     {PathNode.position[1] + LineCountOffset + DirectionOffsetX,     PathNode.position[2],PathNode.position[3] + LineCountOffset + DirectionOffsetY},     'ff000000' )                   

                                    DrawLinePop({LastNode.position[1] + LineCountOffset,                        LastNode.position[2], LastNode.position[3] + LineCountOffset},                        {PathNode.position[1] + LineCountOffset,                        PathNode.position[2],PathNode.position[3] + LineCountOffset},                        Offsets[PathNode.graphName]['color'] )                   
                                    DrawLinePop({LastNode.position[1] + LineCountOffset + DirectionOffsetX * 2, LastNode.position[2], LastNode.position[3] + LineCountOffset + DirectionOffsetY * 2}, {PathNode.position[1] + LineCountOffset + DirectionOffsetX * 2, PathNode.position[2],PathNode.position[3] + LineCountOffset + DirectionOffsetY * 2}, Offsets[PathNode.graphName]['color'] )                             

                                end
                                LastNode = PathNode
                            end
                            LineCountOffset = LineCountOffset + 0.3
                        end
                    end
                end
            end
        end
    end
end


function RenderMarkerCreator()
    local MarkerPosition = {}
    local Marker2Position = {}
    WaitTicks(10)
    while true do
        for nodename, markerInfo in CREATEDMARKERS or {} do
            MarkerPosition[1] = markerInfo.position[1]
            MarkerPosition[2] = markerInfo.position[2]
            MarkerPosition[3] = markerInfo.position[3]
            -- Draw the marker path node
            DrawCircle(MarkerPosition, 4, Offsets[markerInfo.graph]['color'] or 'ff000000' )
            -- Draw the connecting lines to its adjacent nodes
            if markerInfo.adjacentTo then
                local adjancents = STR_GetTokens(markerInfo.adjacentTo or '', ' ')
                if adjancents[0] then
                    for i, node in adjancents do
                        local otherMarker = CREATEDMARKERS[node]
                        if otherMarker then
                            if markerInfo.graph == 'DefaultLand' and otherMarker.graph == 'DefaultLand' then
                                Color = Offsets['DefaultLand']['color']
                            elseif markerInfo.graph == 'DefaultWater' and otherMarker.graph == 'DefaultWater' then
                                Color = Offsets['DefaultWater']['color']
                            elseif markerInfo.graph == 'DefaultAmphibious' or otherMarker.graph == 'DefaultAmphibious' then
                                Color = Offsets['DefaultAmphibious']['color']
                            elseif markerInfo.graph == 'DefaultLand' and otherMarker.graph == 'DefaultWater' then
                                Color = Offsets['DefaultAmphibious']['color']
                            elseif markerInfo.graph == 'DefaultWater' and otherMarker.graph == 'DefaultLand' then
                                Color = Offsets['DefaultAmphibious']['color']
                            else
                                continue
                            end
                            Marker2Position[1] = otherMarker.position[1]
                            Marker2Position[2] = otherMarker.position[2]
                            Marker2Position[3] = otherMarker.position[3]
                            DrawLinePop(MarkerPosition, Marker2Position, Color )
                        end
                    end
                end
            end
        end
        for nodename, markerInfo in Scenario.MasterChain._MASTERCHAIN_.Markers or {} do
            if markerInfo['type'] == 'Naval Area' then
                DrawCircle(markerInfo['position'], 8, 'ff0000FF' )
                DrawCircle(markerInfo['position'], 9, 'ffF0F0FF' )
            end
        end
        
        WaitTicks(2)
        if GetGameTimeSeconds() > 5 and not DebugValidMarkerPosition then
            return
        end
    end
end

function CreateAIMarkers()
    if ScenarioInfo.Options.AIMapMarker == 'map' then
        LOG('* AI-Uveso: Using the original marker from the map.')
        return
    elseif ScenarioInfo.Options.AIMapMarker == 'off' then
        LOG('* AI-Uveso: Running without markers, deleting map marker.')
        CREATEDMARKERS = {}
        CopyMarkerToMASTERCHAIN('Land')
        CopyMarkerToMASTERCHAIN('Water')
        CopyMarkerToMASTERCHAIN('Amphibious')
        CopyMarkerToMASTERCHAIN('Air')
        return
    elseif ScenarioInfo.Options.AIMapMarker == 'miss' then
        local count = 0
        for k, v in Scenario.MasterChain._MASTERCHAIN_.Markers do
            if MarkerDefaults[v.type] then
                count = count + 1
            end
        end
        if count > 1 then
            LOG('* AI-Uveso: No autogenerating. Map has '..count..' marker.')
            return
        else
            LOG('* AI-Uveso: Map has no markers; Generating marker, please wait...')
        end
    elseif ScenarioInfo.Options.AIMapMarker == 'all' then
        LOG('* AI-Uveso: Generating marker, please wait...')
    end
    -- Map size like 20x10 and 10x20
    if ScenarioInfo.size[1] > ScenarioInfo.size[2] then
        MarkerCountY = MarkerCountY / 2
    elseif ScenarioInfo.size[1] < ScenarioInfo.size[2] then
        MarkerCountX = MarkerCountX / 2
    end
    -- Playable area
    if  ScenarioInfo.MapData.PlayableRect then
        playablearea = ScenarioInfo.MapData.PlayableRect
    else
        playablearea = {0, 0, ScenarioInfo.size[1], ScenarioInfo.size[2]}
    end
    LOG('* AI-Uveso: playable area coordinates are ' .. repr(playablearea))
    -- Create Air Marker
    CREATEDMARKERS = {}
    local DistanceBetweenMarkers = ScenarioInfo.size[1] / ( MarkerCountX/2 )
    for Y = 0, MarkerCountY/2 - 1 do
        for X = 0, MarkerCountX/2 - 1 do
            local PosX = X * DistanceBetweenMarkers + DistanceBetweenMarkers / 2
            local PosY = Y * DistanceBetweenMarkers + DistanceBetweenMarkers / 2
                CREATEDMARKERS['Marker'..X..'-'..Y] = {
                    ['position'] = VECTOR3( PosX, GetSurfaceHeight(PosX,PosY), PosY ),
                    ['graph'] = 'DefaultAir',
                }
            if PosX < playablearea[1] or PosX > playablearea[3] or PosY < playablearea[2] or PosY > playablearea[4] then
                CREATEDMARKERS['Marker'..X..'-'..Y].graph = 'Blocked'
            end
        end
    end
    -- connect air markers
    for Y = 0, MarkerCountY/2 - 1 do
        for X = 0, MarkerCountX/2 - 1 do
            if not DebugValidMarkerPosition then
                ConnectMarker(X,Y)
            end
        end
    end
    -- Copy Markers to the Scenario.MasterChain._MASTERCHAIN
    CopyMarkerToMASTERCHAIN('Air')

    -- create Land/Water/Amphibious marker grid
    CREATEDMARKERS = {}
    local DistanceBetweenMarkers = ScenarioInfo.size[1] / ( MarkerCountX )
    for Y = 0, MarkerCountY - 1 do
        for X = 0, MarkerCountX - 1 do
            local PosX = X * DistanceBetweenMarkers + DistanceBetweenMarkers / 2
            local PosY = Y * DistanceBetweenMarkers + DistanceBetweenMarkers / 2
                CREATEDMARKERS['Marker'..X..'-'..Y] = {
                    ['position'] = VECTOR3( PosX, GetSurfaceHeight(PosX,PosY), PosY ),
                }
        end
    end
    -- define marker as land, amp, water
    for Y = 0, MarkerCountY - 1 do
        for X = 0, MarkerCountX - 1 do
            local ReturnGraph
            local MarkerIndex = 'Marker'..X..'-'..Y
            local MarkerPosition = CREATEDMARKERS[MarkerIndex].position
            if MarkerPosition[1] > playablearea[1] and MarkerPosition[1] < playablearea[3] and MarkerPosition[3] > playablearea[2] and MarkerPosition[3] < playablearea[4] then
                ReturnGraph = CheckValidMarkerPosition(MarkerIndex)
            else
                ReturnGraph = 'Blocked'
            end
            if DebugMarker == MarkerIndex then
                ReturnGraph = 'DefaultAir'
            end
            --LOG('Marker '..'Marker '..X..'-'..Y..' TerrainType = '..ReturnGraph)
            CREATEDMARKERS[MarkerIndex].graph = ReturnGraph
        end
    end
    -- connect markers
    for Y = 0, MarkerCountY - 1 do
        for X = 0, MarkerCountX - 1 do
            ConnectMarker(X,Y)
        end
    end
    -- optimize
    
    -- Copy Markers to the Scenario.MasterChain._MASTERCHAIN
    CopyMarkerToMASTERCHAIN('Land')
    CopyMarkerToMASTERCHAIN('Water')
    CopyMarkerToMASTERCHAIN('Amphibious')

    --create naval Areas
    CreateNavalExpansions()

    CleanMarkersInMASTERCHAIN('Land')
    CleanMarkersInMASTERCHAIN('Water')
    CleanMarkersInMASTERCHAIN('Amphibious')


    if ScenarioInfo.Options.AIMapMarker == 'print' then
        LOG('map: Printing markers to game.log')
        PrintMASTERCHAIN()
    end

end

function CleanMarkersInMASTERCHAIN(layer)
    for Y = 0, MarkerCountY - 1 do
        for X = 0, MarkerCountX - 1 do
            if Scenario.MasterChain._MASTERCHAIN_.Markers[layer..X..'-'..Y] then
                --LOG('Cleaning marker '..layer..X..'-'..Y)
                -- check if we have 8 adjacentTo. If yes, delete this Marker
                local adjancents = STR_GetTokens(Scenario.MasterChain._MASTERCHAIN_.Markers[layer..X..'-'..Y].adjacentTo or '', ' ')
                if adjancents[7] then
                    --LOG('markers has 8 adjacentTo: '..Scenario.MasterChain._MASTERCHAIN_.Markers[layer..X..'-'..Y].adjacentTo)
                    Scenario.MasterChain._MASTERCHAIN_.Markers[layer..X..'-'..Y] = nil
                    -- delete adjacentTo from near markers
                    for YD = -1, 1 do
                        for XD = -1, 1 do
                            --LOG('XD '..XD..' - YD '..YD..'')
                            if Scenario.MasterChain._MASTERCHAIN_.Markers[layer..(X+XD)..'-'..(Y+YD)] then
                                local adjancentsD = STR_GetTokens(Scenario.MasterChain._MASTERCHAIN_.Markers[layer..(X+XD)..'-'..(Y+YD)].adjacentTo or '', ' ')
                                local NewadjacentTo = nil
                                for i, node in adjancentsD do
                                    if node ~= layer..X..'-'..Y then
                                        --LOG('adding node '..node..' this is never'..layer..X..'-'..Y)
                                        if not NewadjacentTo then
                                            NewadjacentTo = node
                                        else
                                            NewadjacentTo = NewadjacentTo..' '..node
                                        end
                                    end
                                end
                                -- We deleted this marker, so we scan't set it
                                --LOG('Set new adjacent to marker : '..layer..(X+XD)..'-'..(Y+YD) )
                                Scenario.MasterChain._MASTERCHAIN_.Markers[layer..(X+XD)..'-'..(Y+YD)].adjacentTo = NewadjacentTo
                                --LOG('validate: '..repr(Scenario.MasterChain._MASTERCHAIN_.Markers[layer..(X+XD)..'-'..(Y+YD)].adjacentTo))
                            end
                        end
                    end
                end
            end
        end
    end
end

function CopyMarkerToMASTERCHAIN(layer)
    --LOG('Delete original marker from MASTERCHAIN for Layer: '..layer)
    -- Deleting all previous markers from MASTERCHAIN
    for nodename, markerInfo in Scenario.MasterChain._MASTERCHAIN_.Markers or {} do
        if markerInfo['graph'] == 'Default'..layer then
            Scenario.MasterChain._MASTERCHAIN_.Markers[nodename] = nil
            --LOG('Removed from Masterchain: '..nodename)
        end
    end
    -- Copy marker
    --LOG('Copy new marker to MASTERCHAIN for Layer: '..layer)
    for nodename, markerInfo in CREATEDMARKERS do
        -- check if we have the right layer
        if markerInfo['graph'] == 'Default'..layer or layer == 'Amphibious' then
            local NewNodeName = string.gsub(nodename, 'Marker', layer)
            Scenario.MasterChain._MASTERCHAIN_.Markers[NewNodeName] = table.copy(markerInfo)
            -- Validate adjacentTo
            local NewadjacentTo = nil
            local adjancents = STR_GetTokens(Scenario.MasterChain._MASTERCHAIN_.Markers[NewNodeName].adjacentTo or '', ' ')
            if adjancents[0] then
                for i, node in adjancents do
                    -- Does the node on this layer exist ? 
                    if CREATEDMARKERS[node] and (CREATEDMARKERS[node]['graph'] == 'Default'..layer or layer == 'Amphibious') then
                        if not NewadjacentTo then
                            NewadjacentTo = string.gsub(node, 'Marker', layer)
                        else
                            NewadjacentTo = NewadjacentTo..' '..string.gsub(node, 'Marker', layer)
                        end
                    end
                end
            end
            -- copy the new adjancents to the masterchain marker
            if NewadjacentTo then
                Scenario.MasterChain._MASTERCHAIN_.Markers[NewNodeName].adjacentTo = NewadjacentTo
            else
                Scenario.MasterChain._MASTERCHAIN_.Markers[NewNodeName].adjacentTo = ''
            end
            -- add data for a real marker
            Scenario.MasterChain._MASTERCHAIN_.Markers[NewNodeName].color = MarkerDefaults[layer.." Path Node"]['color']
            Scenario.MasterChain._MASTERCHAIN_.Markers[NewNodeName].hint = true
            Scenario.MasterChain._MASTERCHAIN_.Markers[NewNodeName].orientation = { 0, 0, 0 }
            Scenario.MasterChain._MASTERCHAIN_.Markers[NewNodeName].prop = "/env/common/props/markers/M_Path_prop.bp"
            Scenario.MasterChain._MASTERCHAIN_.Markers[NewNodeName].type = layer.." Path Node"
            Scenario.MasterChain._MASTERCHAIN_.Markers[NewNodeName].graph = 'Default'..layer
        end
    end

end

function CheckValidMarkerPosition(MarkerIndex)
    local MarkerLayer = 'DefaultLand'
    if GetTerrainHeight(CREATEDMARKERS[MarkerIndex].position[1], CREATEDMARKERS[MarkerIndex].position[3]) < GetSurfaceHeight(CREATEDMARKERS[MarkerIndex].position[1], CREATEDMARKERS[MarkerIndex].position[3]) then
        MarkerLayer = 'DefaultWater'
    end
    local UHigh, DHigh, LHigh, RHigh = 0,0,0,0
    local LUHigh, RUHigh, LDHigh, RDHigh = 0,0,0,0
    local Elevation1, Elevation2, Elevation3, RDHigh = 0,0,0
    local FAIL = 0
    local MaxFails = 8 * 1/ScanResolution
    local MarkerPos = CREATEDMARKERS[MarkerIndex].position
    local ASCIIGFX = ''
    ------------------
    -- Check X Axis --
    ------------------
    for Y = -4, 4, ScanResolution do
        FAIL = 0
        ASCIIGFX = ''
        for X = -4, 4, ScanResolution do
            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                --DrawLine( {MarkerPos[1] -4, MarkerPos[2], MarkerPos[3] + Y}, {MarkerPos[1] + X, MarkerPos[2], MarkerPos[3] + Y}, 'ffFFE0E0' )
                --WaitTicks(1)
            end
            local Block = false
            -- Check a square with FootprintSize if it has less then MaxPassableElevation ((circle 16:20  1:20*16 = 0.8))
            High = GetSurfaceHeight( MarkerPos[1] + X, MarkerPos[3] + Y )
            UHigh = High - GetSurfaceHeight( MarkerPos[1] + X, MarkerPos[3] + Y-FootprintSize )
            DHigh = High - GetSurfaceHeight( MarkerPos[1] + X, MarkerPos[3] + Y-FootprintSize )
            LHigh = High - GetSurfaceHeight( MarkerPos[1] + X-FootprintSize, MarkerPos[3] + Y )
            RHigh = High - GetSurfaceHeight( MarkerPos[1] + X+FootprintSize, MarkerPos[3] + Y )
            LUHigh = High - GetSurfaceHeight( MarkerPos[1] + X-FootprintSize*0.8, MarkerPos[3] + Y-FootprintSize*0.8 )
            RUHigh = High - GetSurfaceHeight( MarkerPos[1] + X+FootprintSize*0.8, MarkerPos[3] + Y-FootprintSize*0.8 )
            LDHigh = High - GetSurfaceHeight( MarkerPos[1] + X-FootprintSize*0.8, MarkerPos[3] + Y+FootprintSize*0.8 )
            RDHigh = High - GetSurfaceHeight( MarkerPos[1] + X+FootprintSize*0.8, MarkerPos[3] + Y+FootprintSize*0.8 )
            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                LOG('*ConnectMarker slope  : '..string.format("slope:  %.2f  %.2f  %.2f  %.2f   angle:  %.2f  %.2f  %.2f  %.2f ... %.2f  %.2f  %.2f  %.2f", math.abs(UHigh - DHigh), math.abs(LHigh - RHigh), math.abs(LUHigh - RDHigh), math.abs(RUHigh - LDHigh), math.abs(UHigh), math.abs(DHigh), math.abs(LHigh), math.abs(RHigh), math.abs(LUHigh), math.abs(RUHigh), math.abs(LDHigh), math.abs(RDHigh) ) )
            end
            if math.abs(UHigh - DHigh) > MaxSlope or math.abs(LHigh - RHigh) > MaxSlope or math.abs(LUHigh - RDHigh) > MaxSlope or math.abs(RUHigh - LDHigh) > MaxSlope then
                if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouthWest then
                    WARN('*ConnectMarker slope  : '..string.format("%.2f %.2f %.2f %.2f", math.abs(UHigh - DHigh), math.abs(LHigh - RHigh), math.abs(LUHigh - RDHigh), math.abs(RUHigh - LDHigh) ) )
                end
                Block = true
            end
            if math.abs(UHigh) > MaxAngle or math.abs(DHigh) > MaxAngle or math.abs(LHigh) > MaxAngle or math.abs(RHigh) > MaxAngle or math.abs(LUHigh) > MaxAngle or math.abs(RUHigh) > MaxAngle or math.abs(LDHigh) > MaxAngle or math.abs(RDHigh) > MaxAngle then
                if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouthWest then
                    WARN('*ConnectMarker angle  : '..string.format("%.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f", math.abs(UHigh), math.abs(DHigh), math.abs(LHigh), math.abs(RHigh), math.abs(LUHigh), math.abs(RUHigh), math.abs(LDHigh), math.abs(RDHigh) ) )
                end
                Block = true
            end
            if Block == true then
                if DebugMarker == MarkerIndex then
                    --WARN('*ConnectMarker MaxPassableElevation Blocked!!! '..Elevation )
                end
                FAIL = FAIL + 1
                ASCIIGFX = ASCIIGFX..'----'
            else
                ASCIIGFX = ASCIIGFX..'....'
            end
            -- check Land / Water passage
            SHigh = GetSurfaceHeight( MarkerPos[1] + X, MarkerPos[3] + Y )
            THigh = GetTerrainHeight( MarkerPos[1] + X, MarkerPos[3] + Y )
            if MarkerLayer ~= 'DefaultAmphibious' then
                if THigh < SHigh then
                    if MarkerLayer ~= 'DefaultWater' then
                        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                            WARN('*CheckValidMarkerPosition Land / Water passage!!!')
                        end
                        MarkerLayer = 'DefaultAmphibious'
                    end
                else
                    if MarkerLayer == 'DefaultWater' then
                        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                            WARN('*CheckValidMarkerPosition Land / Water passage!!!')
                        end
                        MarkerLayer = 'DefaultAmphibious'
                    end
                end
            end
        end
        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
            LOG(ASCIIGFX)
        end
        if FAIL >= MaxFails then
            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                WARN('*CheckValidMarkerPosition X Axis ('..FAIL..') Failed')
            end
            return 'Blocked'
        end
    end
    if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
        LOG('*CheckValidMarkerPosition X Axis ('..FAIL..')')
    end
    ------------------
    -- Check Y Axis --
    ------------------
    for X = -4, 4, ScanResolution do
        FAIL = 0
        ASCIIGFX = ''
        for Y = -4, 4, ScanResolution do
            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                --DrawLine( {MarkerPos[1] + X , MarkerPos[2], MarkerPos[3] -4}, {MarkerPos[1] + X, MarkerPos[2], MarkerPos[3] + Y}, 'ffFFE0E0' )
                --WaitTicks(1)
            end
            local Block = false
            -- Check a square with FootprintSize if it has less then MaxPassableElevation ((circle 16:20  1:20*16 = 0.8))
            High = GetSurfaceHeight( MarkerPos[1] + X, MarkerPos[3] + Y )
            UHigh = High - GetSurfaceHeight( MarkerPos[1] + X, MarkerPos[3] + Y-FootprintSize )
            DHigh = High - GetSurfaceHeight( MarkerPos[1] + X, MarkerPos[3] + Y-FootprintSize )
            LHigh = High - GetSurfaceHeight( MarkerPos[1] + X-FootprintSize, MarkerPos[3] + Y )
            RHigh = High - GetSurfaceHeight( MarkerPos[1] + X+FootprintSize, MarkerPos[3] + Y )
            LUHigh = High - GetSurfaceHeight( MarkerPos[1] + X-FootprintSize*0.8, MarkerPos[3] + Y-FootprintSize*0.8 )
            RUHigh = High - GetSurfaceHeight( MarkerPos[1] + X+FootprintSize*0.8, MarkerPos[3] + Y-FootprintSize*0.8 )
            LDHigh = High - GetSurfaceHeight( MarkerPos[1] + X-FootprintSize*0.8, MarkerPos[3] + Y+FootprintSize*0.8 )
            RDHigh = High - GetSurfaceHeight( MarkerPos[1] + X+FootprintSize*0.8, MarkerPos[3] + Y+FootprintSize*0.8 )
            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                LOG('*ConnectMarker slope  : '..string.format("slope:  %.2f  %.2f  %.2f  %.2f   angle:  %.2f  %.2f  %.2f  %.2f ... %.2f  %.2f  %.2f  %.2f", math.abs(UHigh - DHigh), math.abs(LHigh - RHigh), math.abs(LUHigh - RDHigh), math.abs(RUHigh - LDHigh), math.abs(UHigh), math.abs(DHigh), math.abs(LHigh), math.abs(RHigh), math.abs(LUHigh), math.abs(RUHigh), math.abs(LDHigh), math.abs(RDHigh) ) )
            end
            if math.abs(UHigh - DHigh) > MaxSlope or math.abs(LHigh - RHigh) > MaxSlope or math.abs(LUHigh - RDHigh) > MaxSlope or math.abs(RUHigh - LDHigh) > MaxSlope then
                if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouthWest then
                    WARN('*ConnectMarker slope  : '..string.format("%.2f %.2f %.2f %.2f", math.abs(UHigh - DHigh), math.abs(LHigh - RHigh), math.abs(LUHigh - RDHigh), math.abs(RUHigh - LDHigh) ) )
                end
                Block = true
            end
            if math.abs(UHigh) > MaxAngle or math.abs(DHigh) > MaxAngle or math.abs(LHigh) > MaxAngle or math.abs(RHigh) > MaxAngle or math.abs(LUHigh) > MaxAngle or math.abs(RUHigh) > MaxAngle or math.abs(LDHigh) > MaxAngle or math.abs(RDHigh) > MaxAngle then
                if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouthWest then
                    WARN('*ConnectMarker angle  : '..string.format("%.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f", math.abs(UHigh), math.abs(DHigh), math.abs(LHigh), math.abs(RHigh), math.abs(LUHigh), math.abs(RUHigh), math.abs(LDHigh), math.abs(RDHigh) ) )
                end
                Block = true
            end
            if Block == true then
                if DebugMarker == MarkerIndex then
                    --WARN('*ConnectMarker MaxPassableElevation Blocked!!! '..Elevation )
                end
                FAIL = FAIL + 1
                ASCIIGFX = ASCIIGFX..'----'
            else
                ASCIIGFX = ASCIIGFX..'....'
            end
            -- check Land / Water passage
            SHigh = GetSurfaceHeight( MarkerPos[1] + X, MarkerPos[3] + Y )
            THigh = GetTerrainHeight( MarkerPos[1] + X, MarkerPos[3] + Y )
            if MarkerLayer ~= 'DefaultAmphibious' then
                if THigh < SHigh then
                    if MarkerLayer ~= 'DefaultWater' then
                        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                            WARN('*CheckValidMarkerPosition Land / Water passage!!!')
                        end
                        MarkerLayer = 'DefaultAmphibious'
                    end
                else
                    if MarkerLayer == 'DefaultWater' then
                        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                            WARN('*CheckValidMarkerPosition Land / Water passage!!!')
                        end
                        MarkerLayer = 'DefaultAmphibious'
                    end
                end
            end
        end
        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
            LOG(ASCIIGFX)
        end
        if FAIL >= MaxFails then
            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                WARN('*CheckValidMarkerPosition Y Axis ('..FAIL..') Failed')
            end
            return 'Blocked'
        end
    end
    if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
        LOG('*CheckValidMarkerPosition Y Axis ('..FAIL..')')
    end
    return MarkerLayer
end

function ConnectMarker(X,Y)
    local MarkerIndex = 'Marker'..X..'-'..Y
    -- Check if this marker is valid
    if not CREATEDMARKERS[MarkerIndex] or CREATEDMARKERS[MarkerIndex].graph == 'Blocked' then
        return
    end
    -- First check a path to East Marker
    local MaxFails = 9
    local UHigh, DHigh, LHigh, RHigh = 0,0,0,0
    local LUHigh, RUHigh, LDHigh, RDHigh = 0,0,0,0
    local LUHigh, RUHigh, LDHigh, RDHigh = 0,0,0,0
    local ElevationUD, ElevationLR, ElevationLU, ElevationRU = 0,0,0
    local MarkerPos = CREATEDMARKERS[MarkerIndex].position
    local ASCIIGFX = ''
    -----------------------------------------
    -- Search for a connection to E (East) --
    -----------------------------------------
    FAIL = 0
    local LastElevation
    local EastMarkerIndex = 'Marker'..(X+1)..'-'..Y
    if CREATEDMARKERS[EastMarkerIndex] and CREATEDMARKERS[EastMarkerIndex].graph ~= 'Blocked' then
        for Y = -3, 3, ScanResolution do
            ASCIIGFX = ''
            for X = MarkerPos[1], CREATEDMARKERS[EastMarkerIndex].position[1], ScanResolution do
                if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceEast then
                    DrawLine( {MarkerPos[1], MarkerPos[2], MarkerPos[3] + Y}, { X, MarkerPos[2], MarkerPos[3] + Y}, 'ffFFE0E0' )
                    WaitTicks(1)
                end
                local Block = false
                -- Check a square with FootprintSize if it has less then MaxSlope/MaxAngle ((circle 16:20  1:20*16 = 0.8))
                High = GetSurfaceHeight( X, MarkerPos[3] + Y )
                UHigh = High - GetSurfaceHeight( X, MarkerPos[3] + Y-FootprintSize )
                DHigh = High - GetSurfaceHeight( X, MarkerPos[3] + Y-FootprintSize )
                LHigh = High - GetSurfaceHeight( X-FootprintSize, MarkerPos[3] + Y )
                RHigh = High - GetSurfaceHeight( X+FootprintSize, MarkerPos[3] + Y )
                LUHigh = High - GetSurfaceHeight( X-FootprintSize*0.8, MarkerPos[3] + Y-FootprintSize*0.8 )
                RUHigh = High - GetSurfaceHeight( X+FootprintSize*0.8, MarkerPos[3] + Y-FootprintSize*0.8 )
                LDHigh = High - GetSurfaceHeight( X-FootprintSize*0.8, MarkerPos[3] + Y+FootprintSize*0.8 )
                RDHigh = High - GetSurfaceHeight( X+FootprintSize*0.8, MarkerPos[3] + Y+FootprintSize*0.8 )
                if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceEast then
                    LOG('*ConnectMarker slope  : '..string.format("slope:  %.2f  %.2f  %.2f  %.2f   angle:  %.2f  %.2f  %.2f  %.2f ... %.2f  %.2f  %.2f  %.2f", math.abs(UHigh - DHigh), math.abs(LHigh - RHigh), math.abs(LUHigh - RDHigh), math.abs(RUHigh - LDHigh), math.abs(UHigh), math.abs(DHigh), math.abs(LHigh), math.abs(RHigh), math.abs(LUHigh), math.abs(RUHigh), math.abs(LDHigh), math.abs(RDHigh) ) )
                end
                if math.abs(UHigh - DHigh) > MaxSlope or math.abs(LHigh - RHigh) > MaxSlope or math.abs(LUHigh - RDHigh) > MaxSlope or math.abs(RUHigh - LDHigh) > MaxSlope then
                    if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouth then
                        WARN('*ConnectMarker slope  : '..string.format("%.2f %.2f %.2f %.2f", math.abs(UHigh - DHigh), math.abs(LHigh - RHigh), math.abs(LUHigh - RDHigh), math.abs(RUHigh - LDHigh) ) )
                    end
                    Block = true
                end
                if math.abs(UHigh) > MaxAngle or math.abs(DHigh) > MaxAngle or math.abs(LHigh) > MaxAngle or math.abs(RHigh) > MaxAngle or math.abs(LUHigh) > MaxAngle or math.abs(RUHigh) > MaxAngle or math.abs(LDHigh) > MaxAngle or math.abs(RDHigh) > MaxAngle then
                    if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouth then
                        WARN('*ConnectMarker angle  : '..string.format("%.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f", math.abs(UHigh), math.abs(DHigh), math.abs(LHigh), math.abs(RHigh), math.abs(LUHigh), math.abs(RUHigh), math.abs(LDHigh), math.abs(RDHigh) ) )
                    end
                    Block = true
                end
                if Block == true then
                    FAIL = FAIL + 1
                    ASCIIGFX = ASCIIGFX..'----'
                    break
                else
                    ASCIIGFX = ASCIIGFX..'....'
                end
            end
            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                LOG(ASCIIGFX)
            end
        end
    else
        FAIL = MaxFails
    end
    if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
        WARN('*CheckValidMarkerPosition East ('..FAIL..') Fails')
    end
    -- Check if we have failed to find pathable Terrain
    if FAIL < MaxFails or CREATEDMARKERS[MarkerIndex]['graph'] == 'DefaultAir' then
        -- Add the EastMarker to our current Marker as adjacency
        if CREATEDMARKERS[EastMarkerIndex] then
            if not CREATEDMARKERS[MarkerIndex].adjacentTo then
                CREATEDMARKERS[MarkerIndex].adjacentTo = EastMarkerIndex
            else
                CREATEDMARKERS[MarkerIndex].adjacentTo = CREATEDMARKERS[MarkerIndex].adjacentTo..' '..EastMarkerIndex
            end
        end
        -- And add the current marker also to the EastMarker as adjacency
        if CREATEDMARKERS[EastMarkerIndex] then
            if not CREATEDMARKERS[EastMarkerIndex].adjacentTo then
                CREATEDMARKERS[EastMarkerIndex].adjacentTo = MarkerIndex
            else
                CREATEDMARKERS[EastMarkerIndex].adjacentTo = CREATEDMARKERS[EastMarkerIndex].adjacentTo..' '..MarkerIndex
            end
        end
        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
            LOG('*ConnectMarker Terrain Free -> Connecting ('..MarkerIndex..') with ('..EastMarkerIndex..')')
        end
    else
        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
            WARN('*ConnectMarker Terrain Blocked. Cant connect ('..MarkerIndex..') with ('..EastMarkerIndex..')')
        end
    end
    ------------------------------------------
    -- Search for a connection to S (South) --
    ------------------------------------------
    FAIL = 0
    local SouthMarkerIndex = 'Marker'..X..'-'..(Y+1)
    if CREATEDMARKERS[SouthMarkerIndex] and CREATEDMARKERS[SouthMarkerIndex].graph ~= 'Blocked' then
        for X = -3, 3, ScanResolution do
            ASCIIGFX = ''
            for Y = MarkerPos[3], CREATEDMARKERS[SouthMarkerIndex].position[3], ScanResolution do
                if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouth then
                    DrawLine( {MarkerPos[1] + X, MarkerPos[2], MarkerPos[3]}, { MarkerPos[1] + X, MarkerPos[2], Y}, 'ffFFE0E0' )
                    WaitTicks(1)
                end
                local Block = false
                -- Check a square with FootprintSize if it has less then MaxSlope/MaxAngle ((circle 16:20  1:20*16 = 0.8))
                High = GetSurfaceHeight( MarkerPos[1] + X, Y )
                UHigh = High - GetSurfaceHeight( MarkerPos[1] + X, Y-FootprintSize )
                DHigh = High - GetSurfaceHeight( MarkerPos[1] + X, Y-FootprintSize )
                LHigh = High - GetSurfaceHeight( MarkerPos[1] + X-FootprintSize, Y )
                RHigh = High - GetSurfaceHeight( MarkerPos[1] + X+FootprintSize, Y )
                LUHigh = High - GetSurfaceHeight( MarkerPos[1] + X-FootprintSize*0.8, Y-FootprintSize*0.8 )
                RUHigh = High - GetSurfaceHeight( MarkerPos[1] + X+FootprintSize*0.8, Y-FootprintSize*0.8 )
                LDHigh = High - GetSurfaceHeight( MarkerPos[1] + X-FootprintSize*0.8, Y+FootprintSize*0.8 )
                RDHigh = High - GetSurfaceHeight( MarkerPos[1] + X+FootprintSize*0.8, Y+FootprintSize*0.8 )
                if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouth then
                    LOG('*ConnectMarker slope  : '..string.format("slope:  %.2f  %.2f  %.2f  %.2f   angle:  %.2f  %.2f  %.2f  %.2f ... %.2f  %.2f  %.2f  %.2f", math.abs(UHigh - DHigh), math.abs(LHigh - RHigh), math.abs(LUHigh - RDHigh), math.abs(RUHigh - LDHigh), math.abs(UHigh), math.abs(DHigh), math.abs(LHigh), math.abs(RHigh), math.abs(LUHigh), math.abs(RUHigh), math.abs(LDHigh), math.abs(RDHigh) ) )
                end
                if math.abs(UHigh - DHigh) > MaxSlope or math.abs(LHigh - RHigh) > MaxSlope or math.abs(LUHigh - RDHigh) > MaxSlope or math.abs(RUHigh - LDHigh) > MaxSlope then
                    if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouth then
                        WARN('*ConnectMarker slope  : '..string.format("%.2f %.2f %.2f %.2f", math.abs(UHigh - DHigh), math.abs(LHigh - RHigh), math.abs(LUHigh - RDHigh), math.abs(RUHigh - LDHigh) ) )
                    end
                    Block = true
                end
                if math.abs(UHigh) > MaxAngle or math.abs(DHigh) > MaxAngle or math.abs(LHigh) > MaxAngle or math.abs(RHigh) > MaxAngle or math.abs(LUHigh) > MaxAngle or math.abs(RUHigh) > MaxAngle or math.abs(LDHigh) > MaxAngle or math.abs(RDHigh) > MaxAngle then
                    if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouth then
                        WARN('*ConnectMarker angle  : '..string.format("%.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f", math.abs(UHigh), math.abs(DHigh), math.abs(LHigh), math.abs(RHigh), math.abs(LUHigh), math.abs(RUHigh), math.abs(LDHigh), math.abs(RDHigh) ) )
                    end
                    Block = true
                end
                if Block == true then
                    FAIL = FAIL + 1
                    ASCIIGFX = ASCIIGFX..'----'
                    break
                else
                    ASCIIGFX = ASCIIGFX..'....'
                end
            end
            if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouth then
                LOG(ASCIIGFX)
            end
        end
    else
        FAIL = MaxFails
    end
    if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
        WARN('*ConnectMarker South ('..FAIL..') Fails')
    end
    -- Check if we have failed to find pathable Terrain
    if FAIL < MaxFails or CREATEDMARKERS[MarkerIndex]['graph'] == 'DefaultAir' then
        -- Add the SouthMarker to our current Marker as adjacency
        if CREATEDMARKERS[SouthMarkerIndex] then
            if not CREATEDMARKERS[MarkerIndex].adjacentTo then
                CREATEDMARKERS[MarkerIndex].adjacentTo = SouthMarkerIndex
            else
                CREATEDMARKERS[MarkerIndex].adjacentTo = CREATEDMARKERS[MarkerIndex].adjacentTo..' '..SouthMarkerIndex
            end
        end
        -- And add the current marker also to the SouthMarker as adjacency
        if CREATEDMARKERS[SouthMarkerIndex] then
            if not CREATEDMARKERS[SouthMarkerIndex].adjacentTo then
                CREATEDMARKERS[SouthMarkerIndex].adjacentTo = MarkerIndex
            else
                CREATEDMARKERS[SouthMarkerIndex].adjacentTo = CREATEDMARKERS[SouthMarkerIndex].adjacentTo..' '..MarkerIndex
            end
        end
        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
            LOG('*ConnectMarker Terrain Free -> Connecting ('..MarkerIndex..') with ('..SouthMarkerIndex..')')
        end
    else
        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
            WARN('*ConnectMarker Terrain Blocked. Cant connect ('..MarkerIndex..') with ('..SouthMarkerIndex..')')
        end
    end

    ------------------------------------------------
    -- Search for a connection to SE (South-East) --
    ------------------------------------------------
    FAIL = 0
    local SouthEastMarkerIndex = 'Marker'..(X+1)..'-'..(Y+1)
    if CREATEDMARKERS[SouthEastMarkerIndex] and CREATEDMARKERS[SouthEastMarkerIndex].graph ~= 'Blocked' then
        for X = -3, 3, ScanResolution do
            ASCIIGFX = ''
            for XY = 0, CREATEDMARKERS[SouthEastMarkerIndex].position[3] - MarkerPos[3] , ScanResolution do
                if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                    --DrawLine( {MarkerPos[1] + X, MarkerPos[2], MarkerPos[3] - X}, { MarkerPos[1] + X+XY, MarkerPos[2], MarkerPos[3] + XY - X}, 'ffFFE0E0' )
                    --WaitTicks(1)
                end
                local Block = false
                -- Check a square with FootprintSize if it has less then MaxPassableElevation ((circle 16:20  1:20*16 = 0.8))
                High = GetSurfaceHeight( MarkerPos[1] + X+XY, MarkerPos[3] + XY-X )
                UHigh = High - GetSurfaceHeight( MarkerPos[1] + X+XY, MarkerPos[3] + XY-X-FootprintSize )
                DHigh = High - GetSurfaceHeight( MarkerPos[1] + X+XY, MarkerPos[3] + XY-X-FootprintSize )
                LHigh = High - GetSurfaceHeight( MarkerPos[1] + X+XY-FootprintSize, MarkerPos[3] + XY-X )
                RHigh = High - GetSurfaceHeight( MarkerPos[1] + X+XY+FootprintSize, MarkerPos[3] + XY-X )
                LUHigh = High - GetSurfaceHeight( MarkerPos[1] + X+XY-FootprintSize*0.8, MarkerPos[3] + XY-X-FootprintSize*0.8 )
                RUHigh = High - GetSurfaceHeight( MarkerPos[1] + X+XY+FootprintSize*0.8, MarkerPos[3] + XY-X-FootprintSize*0.8 )
                LDHigh = High - GetSurfaceHeight( MarkerPos[1] + X+XY-FootprintSize*0.8, MarkerPos[3] + XY-X+FootprintSize*0.8 )
                RDHigh = High - GetSurfaceHeight( MarkerPos[1] + X+XY+FootprintSize*0.8, MarkerPos[3] + XY-X+FootprintSize*0.8 )
                if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouthEast then
                    LOG('*ConnectMarker slope  : '..string.format("slope:  %.2f  %.2f  %.2f  %.2f   angle:  %.2f  %.2f  %.2f  %.2f ... %.2f  %.2f  %.2f  %.2f", math.abs(UHigh - DHigh), math.abs(LHigh - RHigh), math.abs(LUHigh - RDHigh), math.abs(RUHigh - LDHigh), math.abs(UHigh), math.abs(DHigh), math.abs(LHigh), math.abs(RHigh), math.abs(LUHigh), math.abs(RUHigh), math.abs(LDHigh), math.abs(RDHigh) ) )
                end
                if math.abs(UHigh - DHigh) > MaxSlope or math.abs(LHigh - RHigh) > MaxSlope or math.abs(LUHigh - RDHigh) > MaxSlope or math.abs(RUHigh - LDHigh) > MaxSlope then
                    if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouthEast then
                        WARN('*ConnectMarker slope  : '..string.format("%.2f %.2f %.2f %.2f", math.abs(UHigh - DHigh), math.abs(LHigh - RHigh), math.abs(LUHigh - RDHigh), math.abs(RUHigh - LDHigh) ) )
                    end
                    Block = true
                end
                if math.abs(UHigh) > MaxAngle or math.abs(DHigh) > MaxAngle or math.abs(LHigh) > MaxAngle or math.abs(RHigh) > MaxAngle or math.abs(LUHigh) > MaxAngle or math.abs(RUHigh) > MaxAngle or math.abs(LDHigh) > MaxAngle or math.abs(RDHigh) > MaxAngle then
                    if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouthEast then
                        WARN('*ConnectMarker angle  : '..string.format("%.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f", math.abs(UHigh), math.abs(DHigh), math.abs(LHigh), math.abs(RHigh), math.abs(LUHigh), math.abs(RUHigh), math.abs(LDHigh), math.abs(RDHigh) ) )
                    end
                    Block = true
                end
                if Block == true then
                    FAIL = FAIL + 1
                    ASCIIGFX = ASCIIGFX..'----'
                    break
                else
                    ASCIIGFX = ASCIIGFX..'....'
                end
            end
            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                LOG(ASCIIGFX)
            end
        end
    else
        FAIL = MaxFails
    end
    if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
        WARN('*CheckValidMarkerPosition South-East ('..FAIL..') Fails')
    end
    -- Check if we have failed to find pathable Terrain
    if FAIL < MaxFails or CREATEDMARKERS[MarkerIndex]['graph'] == 'DefaultAir' then
        -- Add the SouthEastMarker to our current Marker as adjacency
        if CREATEDMARKERS[SouthEastMarkerIndex] then
            if not CREATEDMARKERS[MarkerIndex].adjacentTo then
                CREATEDMARKERS[MarkerIndex].adjacentTo = SouthEastMarkerIndex
            else
                CREATEDMARKERS[MarkerIndex].adjacentTo = CREATEDMARKERS[MarkerIndex].adjacentTo..' '..SouthEastMarkerIndex
            end
        end
        -- And add the current marker also to the SouthEastMarker as adjacency
        if CREATEDMARKERS[SouthEastMarkerIndex] then
            if not CREATEDMARKERS[SouthEastMarkerIndex].adjacentTo then
                CREATEDMARKERS[SouthEastMarkerIndex].adjacentTo = MarkerIndex
            else
                CREATEDMARKERS[SouthEastMarkerIndex].adjacentTo = CREATEDMARKERS[SouthEastMarkerIndex].adjacentTo..' '..MarkerIndex
            end
        end
        if DebugMarker == MarkerIndex then
            LOG('*ConnectMarker Terrain Free -> Connecting ('..MarkerIndex..') with ('..SouthEastMarkerIndex..')')
        end
    else
        if DebugMarker == MarkerIndex then
            WARN('*ConnectMarker Terrain Blocked. Cant connect ('..MarkerIndex..') with ('..SouthEastMarkerIndex..')')
        end
    end
    ------------------------------------------------
    -- Search for a connection to SW (South-West) --
    ------------------------------------------------
    FAIL = 0
    local SouthWestMarkerIndex = 'Marker'..(X-1)..'-'..(Y+1)
    if CREATEDMARKERS[SouthWestMarkerIndex] and CREATEDMARKERS[SouthWestMarkerIndex].graph ~= 'Blocked' then
        for X = -3, 3, ScanResolution do
            ASCIIGFX = ''
            for XY = 0, CREATEDMARKERS[SouthWestMarkerIndex].position[3] - MarkerPos[3] , ScanResolution do
                if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                    --DrawLine( {MarkerPos[1] + X, MarkerPos[2], MarkerPos[3] + X}, { MarkerPos[1] + X-XY, MarkerPos[2], MarkerPos[3] + XY + X}, 'ffFFE0E0' )
                    --WaitTicks(1)
                end
                local Block = false
                -- Check a square with FootprintSize if it has less then MaxPassableElevation ((circle 16:20  1:20*16 = 0.8))
                High = GetSurfaceHeight( MarkerPos[1] + X-XY, MarkerPos[3] + XY+X )
                UHigh = High - GetSurfaceHeight( MarkerPos[1] + X-XY, MarkerPos[3] + XY+X-FootprintSize )
                DHigh = High - GetSurfaceHeight( MarkerPos[1] + X-XY, MarkerPos[3] + XY+X-FootprintSize )
                LHigh = High - GetSurfaceHeight( MarkerPos[1] + X-XY-FootprintSize, MarkerPos[3] + XY+X )
                RHigh = High - GetSurfaceHeight( MarkerPos[1] + X-XY+FootprintSize, MarkerPos[3] + XY+X )
                LUHigh = High - GetSurfaceHeight( MarkerPos[1] + X-XY-FootprintSize*0.8, MarkerPos[3] + XY+X-FootprintSize*0.8 )
                RUHigh = High - GetSurfaceHeight( MarkerPos[1] + X-XY+FootprintSize*0.8, MarkerPos[3] + XY+X-FootprintSize*0.8 )
                LDHigh = High - GetSurfaceHeight( MarkerPos[1] + X-XY-FootprintSize*0.8, MarkerPos[3] + XY+X+FootprintSize*0.8 )
                RDHigh = High - GetSurfaceHeight( MarkerPos[1] + X-XY+FootprintSize*0.8, MarkerPos[3] + XY+X+FootprintSize*0.8 )
                if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouthWest then
                    LOG('*ConnectMarker slope  : '..string.format("slope:  %.2f  %.2f  %.2f  %.2f   angle:  %.2f  %.2f  %.2f  %.2f ... %.2f  %.2f  %.2f  %.2f", math.abs(UHigh - DHigh), math.abs(LHigh - RHigh), math.abs(LUHigh - RDHigh), math.abs(RUHigh - LDHigh), math.abs(UHigh), math.abs(DHigh), math.abs(LHigh), math.abs(RHigh), math.abs(LUHigh), math.abs(RUHigh), math.abs(LDHigh), math.abs(RDHigh) ) )
                end
                if math.abs(UHigh - DHigh) > MaxSlope or math.abs(LHigh - RHigh) > MaxSlope or math.abs(LUHigh - RDHigh) > MaxSlope or math.abs(RUHigh - LDHigh) > MaxSlope then
                    if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouthWest then
                        WARN('*ConnectMarker slope  : '..string.format("%.2f %.2f %.2f %.2f", math.abs(UHigh - DHigh), math.abs(LHigh - RHigh), math.abs(LUHigh - RDHigh), math.abs(RUHigh - LDHigh) ) )
                    end
                    Block = true
                end
                if math.abs(UHigh) > MaxAngle or math.abs(DHigh) > MaxAngle or math.abs(LHigh) > MaxAngle or math.abs(RHigh) > MaxAngle or math.abs(LUHigh) > MaxAngle or math.abs(RUHigh) > MaxAngle or math.abs(LDHigh) > MaxAngle or math.abs(RDHigh) > MaxAngle then
                    if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouthWest then
                        WARN('*ConnectMarker angle  : '..string.format("%.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f", math.abs(UHigh), math.abs(DHigh), math.abs(LHigh), math.abs(RHigh), math.abs(LUHigh), math.abs(RUHigh), math.abs(LDHigh), math.abs(RDHigh) ) )
                    end
                    Block = true
                end
                if Block == true then
                    if DebugMarker == MarkerIndex then
                        --WARN('*ConnectMarker MaxPassableElevation Blocked!!! '..Elevation )
                    end
                    FAIL = FAIL + 1
                    ASCIIGFX = ASCIIGFX..'----'
                    break
                else
                    ASCIIGFX = ASCIIGFX..'....'
                end
            end
            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                LOG(ASCIIGFX)
            end
        end
    else
        FAIL = MaxFails
    end
    if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
        WARN('*CheckValidMarkerPosition South-West ('..FAIL..') Fails')
    end
    -- Check if we have failed to find pathable Terrain
    if FAIL < MaxFails or CREATEDMARKERS[MarkerIndex]['graph'] == 'DefaultAir' then
        -- Add the SouthWestMarker to our current Marker as adjacency
        if CREATEDMARKERS[SouthWestMarkerIndex] then
            if not CREATEDMARKERS[MarkerIndex].adjacentTo then
                CREATEDMARKERS[MarkerIndex].adjacentTo = SouthWestMarkerIndex
            else
                CREATEDMARKERS[MarkerIndex].adjacentTo = CREATEDMARKERS[MarkerIndex].adjacentTo..' '..SouthWestMarkerIndex
            end
        end
        -- And add the current marker also to the SouthWestMarker as adjacency
        if CREATEDMARKERS[SouthWestMarkerIndex] then
            if not CREATEDMARKERS[SouthWestMarkerIndex].adjacentTo then
                CREATEDMARKERS[SouthWestMarkerIndex].adjacentTo = MarkerIndex
            else
                CREATEDMARKERS[SouthWestMarkerIndex].adjacentTo = CREATEDMARKERS[SouthWestMarkerIndex].adjacentTo..' '..MarkerIndex
            end
        end
        if DebugMarker == MarkerIndex then
            LOG('*ConnectMarker Terrain Free -> Connecting ('..MarkerIndex..') with ('..SouthWestMarkerIndex..')')
        end
    else
        if DebugMarker == MarkerIndex then
            WARN('*ConnectMarker Terrain Blocked. Cant connect ('..MarkerIndex..') with ('..SouthWestMarkerIndex..')')
        end
    end

    return
end

function PrintMASTERCHAIN()
    --LOG(repr(Scenario.MasterChain._MASTERCHAIN_.Markers))
    LOG('******************************************** START ***************************************************')
    LOG('************************ Copy the MASTERCHAIN table to your map_save.lua file ************************')
    LOG('* Please Copy&Paste the markers from the game.log file from HDD not from the [F9] debug log window!! *')
    LOG('******************************************************************************************************')
    LOG('  MasterChain = {')
    LOG('    [\'_MASTERCHAIN_\'] = {')
    LOG('      Markers = {')
        for k, v in Scenario.MasterChain._MASTERCHAIN_.Markers do
            local count = 0
            LOG('        [\''..k..'\'] = {')
            if v.type then
                LOG('          [\'type\'] = STRING( \''..v.type..'\' ),')
                count = count + 1
            end
            if v.position then
                LOG('          [\'position\'] = VECTOR3( '..v.position[1]..', '..v.position[2]..', '..v.position[3]..' ),')
                count = count + 1
            end
            if v.orientation then
                LOG('          [\'orientation\'] = VECTOR3( '..v.orientation[1]..', '..v.orientation[2]..', '..v.orientation[3]..' ),')
                count = count + 1
            end
            if v.size then
                LOG('          [\'size\'] = FLOAT( '..v.size..' ),')
                count = count + 1
            end
            if v.resource then
                LOG('          [\'resource\'] = BOOLEAN( '..tostring(v.resource)..' ),')
                count = count + 1
            end
            if v.hint then
                LOG('          [\'hint\'] = BOOLEAN( '..tostring(v.hint)..' ),')
                count = count + 1
            end
            if v.graph then
                LOG('          [\'graph\'] = STRING( \''..v.graph..'\' ),')
                count = count + 1
            end
            if v.adjacentTo then
                LOG('          [\'adjacentTo\'] = STRING( \''..v.adjacentTo..'\' ),')
                count = count + 1
            end
            if v.amount then
                LOG('          [\'amount\'] = FLOAT( '..v.amount..' ),')
                count = count + 1
            end
            if v.color then
                LOG('          [\'color\'] = STRING( \''..v.color..'\' ),')
                count = count + 1
            end
            if v.editorIcon then
                LOG('          [\'editorIcon\'] = STRING( \''..v.editorIcon..'\' ),')
                count = count + 1
            end
            if v.prop then
                LOG('          [\'prop\'] = STRING( \''..v.prop..'\' ),')
                count = count + 1
            end
            -- camera
            if v.zoom then
                LOG('          [\'zoom\'] = FLOAT( '..v.zoom..' ),')
                count = count + 1
            end
            if v.canSetCamera then
                LOG('          [\'canSetCamera\'] = BOOLEAN( '..tostring(v.canSetCamera)..' ),')
                count = count + 1
            end
            if v.canSyncCamera then
                LOG('          [\'canSyncCamera\'] = BOOLEAN( '..tostring(v.canSyncCamera)..' ),')
                count = count + 1
            end
            -- Weather
            if v.MapStyle then
                LOG('          [\'MapStyle\'] = STRING( \''..v.MapStyle..'\' ),')
                count = count + 1
            end
            if v.WeatherType01 then
                LOG('          [\'WeatherType01\'] = STRING( \''..v.WeatherType01..'\' ),')
                count = count + 1
            end
            if v.WeatherType01Chance then
                LOG('          [\'WeatherType01Chance\'] = FLOAT( '..v.WeatherType01Chance..' ),')
                count = count + 1
            end
            if v.WeatherType02 then
                LOG('          [\'WeatherType02\'] = STRING( \''..v.WeatherType02..'\' ),')
                count = count + 1
            end
            if v.WeatherType02Chance then
                LOG('          [\'WeatherType02Chance\'] = FLOAT( '..v.WeatherType02Chance..' ),')
                count = count + 1
            end
            if v.WeatherType03 then
                LOG('          [\'WeatherType03\'] = STRING( \''..v.WeatherType03..'\' ),')
                count = count + 1
            end
            if v.WeatherType03Chance then
                LOG('          [\'WeatherType03Chance\'] = FLOAT( '..v.WeatherType03Chance..' ),')
                count = count + 1
            end
            if v.WeatherType04 then
                LOG('          [\'WeatherType04\'] = STRING( \''..v.WeatherType04..'\' ),')
                count = count + 1
            end
            if v.WeatherType04Chance then
                LOG('          [\'WeatherType04Chance\'] = FLOAT( '..v.WeatherType04Chance..' ),')
                count = count + 1
            end
            if v.WeatherDriftDirection then
                LOG('          [\'WeatherDriftDirection\'] = VECTOR3( '..v.WeatherDriftDirection[1]..', '..v.WeatherDriftDirection[2]..', '..v.WeatherDriftDirection[3]..' ),')
                count = count + 1
            end
            -- cloud
            if v.ForceType then
                LOG('          [\'ForceType\'] = STRING( \''..v.ForceType..'\' ),')
                count = count + 1
            end
            if v.cloudHeight then
                LOG('          [\'cloudHeight\'] = FLOAT( '..v.cloudHeight..' ),')
                count = count + 1
            end
            if v.cloudEmitterScale then
                LOG('          [\'cloudEmitterScale\'] = FLOAT( '..v.cloudEmitterScale..' ),')
                count = count + 1
            end
            if v.cloudEmitterScaleRange then
                LOG('          [\'cloudEmitterScaleRange\'] = FLOAT( '..v.cloudEmitterScaleRange..' ),')
                count = count + 1
            end
            if v.cloudCountRange then
                LOG('          [\'cloudCountRange\'] = FLOAT( '..v.cloudCountRange..' ),')
                count = count + 1
            end
            if v.cloudSpread then
                LOG('          [\'cloudSpread\'] = FLOAT( '..v.cloudSpread..' ),')
                count = count + 1
            end
            if v.cloudHeightRange then
                LOG('          [\'cloudHeightRange\'] = FLOAT( '..v.cloudHeightRange..' ),')
                count = count + 1
            end
            if v.spawnChance then
                LOG('          [\'spawnChance\'] = FLOAT( '..v.spawnChance..' ),')
                count = count + 1
            end
            if v.cloudCount then
                LOG('          [\'cloudCount\'] = FLOAT( '..v.cloudCount..' ),')
                count = count + 1
            end
            -- Effect
            if v.EffectTemplate then
                LOG('          [\'EffectTemplate\'] = STRING( \''..v.EffectTemplate..'\' ),')
                count = count + 1
            end
            if v.offset then
                LOG('          [\'offset\'] = VECTOR3( '..v.offset[1]..', '..v.offset[2]..', '..v.offset[3]..' ),')
                count = count + 1
            end
            if v.scale then
                LOG('          [\'scale\'] = FLOAT( '..v.scale..' ),')
                count = count + 1
            end

            LOG('        },')
            -- Validate 
            local ArrayCount = 0
            for _, _ in v do
                ArrayCount = ArrayCount + 1
            end
            if count ~= ArrayCount then
                WARN('Missing value in marker '..k..' -> '..repr(v)) 
            end
        end
    LOG('      },')
    LOG('    },')
    LOG('  },')
    LOG('******************************************************************************************************')
    LOG('************************ Copy the MASTERCHAIN table to your map_save.lua file ************************')
    LOG('* Please Copy&Paste the markers from the game.log file from HDD not from the [F9] debug log window!! *')
    LOG('********************************************* END ****************************************************')

end

function CreateNavalExpansions()
    local StartMarker = {}
    local NavalMarker = {}
    -- Deleting all NavalExpansions markers from MASTERCHAIN
    for nodename, markerInfo in Scenario.MasterChain._MASTERCHAIN_.Markers or {} do
        if markerInfo['type'] == 'Naval Area' then
            Scenario.MasterChain._MASTERCHAIN_.Markers[nodename] = nil
        end
    end
    -- Get a list of all startareas
    for nodename, markerInfo in Scenario.MasterChain._MASTERCHAIN_.Markers or {} do
        if string.find(nodename, 'ARMY_') then
            StartMarker[nodename] = markerInfo['position']
        end
    end
    -- Search for naval areas
    for BASEnodename, BASEpostition in StartMarker or {} do
        for NavalAreaPerBase = 1, 2 do
            -- Search for nearest Water marker
            local low = false
            local bestMarker = false
            for Y = 0, MarkerCountY - 1 do
                for X = 0, MarkerCountX - 1 do
                    if Scenario.MasterChain._MASTERCHAIN_.Markers['Water'..X..'-'..Y] then
                        local Blocked
                        local adjancentsAmp = 0
                        markerInfo = Scenario.MasterChain._MASTERCHAIN_.Markers['Water'..X..'-'..Y]
                        local dist = VDist2(BASEpostition[1], BASEpostition[3], markerInfo['position'][1], markerInfo['position'][3])
                        -- Is this marker the closest ?
                        if not low or dist < low then
                            -- check if the marker is valid:
                            for YD = -2, 2 do
                                for XD = -2, 2 do
                                    if (YD == -2 or YD == 2) or (XD == -2 or XD == 2) then
                                        -- check if we have an amphibious but not water marker on this position (land)
                                        if not Scenario.MasterChain._MASTERCHAIN_.Markers['Water'..(X+XD)..'-'..(Y+YD)]
                                        and Scenario.MasterChain._MASTERCHAIN_.Markers['Amphibious'..(X+XD)..'-'..(Y+YD)] then
                                            -- check if we have a path from this marker to our naval area markers
                                            markerInfoAdja = Scenario.MasterChain._MASTERCHAIN_.Markers['Amphibious'..(X+XD)..'-'..(Y+YD)]
                                            local adjancents = STR_GetTokens(markerInfoAdja.adjacentTo or '', ' ')
                                            if adjancents[0] then
                                                for i, node in adjancents do
                                                    -- checking node, if it has a conection from land to water.
                                                    for YA = -1, 1 do
                                                        for XA = -1, 1 do
                                                            if node == 'Amphibious'..(X+XA)..'-'..(Y+YA) then
                                                                adjancentsAmp = adjancentsAmp + 1
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            local adjancents = STR_GetTokens(markerInfo.adjacentTo or '', ' ')
                            -- if we have a marker with less than 8 (0-7) adjancents or it has no passable connection to land then don't use it.
                            if not adjancents[7] or adjancentsAmp < 1 then
                                Blocked = true
                                continue
                            end
                            -- check if we have a naval marker close to this area
                            for index, NAVALpostition in NavalMarker do
                                local dist = VDist2( markerInfo['position'][1], markerInfo['position'][3], NAVALpostition[1], NAVALpostition[3])
                                -- is this marker farther away than 60 
                                if dist < 60 then
                                    Blocked = true
                                    break
                                end 
                            end
                            if not Blocked then
                                low = dist
                                bestMarker = markerInfo['position']
                            end
                        end
                    end
                end
            end
            if bestMarker then
                table.insert(NavalMarker, bestMarker)
            end
        end
    end
    -- creating real naval Marker
    for index, NAVALpostition in NavalMarker do
        -- add data for a real marker
        Scenario.MasterChain._MASTERCHAIN_.Markers['Naval Area '..index] = {}
        Scenario.MasterChain._MASTERCHAIN_.Markers['Naval Area '..index].color = MarkerDefaults["Water Path Node"]['color']
        Scenario.MasterChain._MASTERCHAIN_.Markers['Naval Area '..index].hint = true
        Scenario.MasterChain._MASTERCHAIN_.Markers['Naval Area '..index].orientation = { 0, 0, 0 }
        Scenario.MasterChain._MASTERCHAIN_.Markers['Naval Area '..index].prop = "/env/common/props/markers/M_Expansion_prop.bp"
        Scenario.MasterChain._MASTERCHAIN_.Markers['Naval Area '..index].type = "Naval Area"
        Scenario.MasterChain._MASTERCHAIN_.Markers['Naval Area '..index].position = NAVALpostition
    end
end

function ValidateModFiles()
    local ModName = "* AI-Uveso"
    local ModDirectory = 'AI-Uveso'
    local Files = 78
    local Bytes = 1317068
    LOG(''..ModName..': ['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] - Running from: '..debug.getinfo(1).source..'.')
    LOG(''..ModName..': ['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] - Checking directory /mods/ for '..ModDirectory..'...')
    local FilesInFolder = DiskFindFiles('/mods/', '*.*')
    local modfoundcount = 0
    for _, FilepathAndName in FilesInFolder do
        if string.find(FilepathAndName, 'mod_info.lua') then
            if string.gsub(FilepathAndName, ".*/(.*)/.*", "%1") == string.lower(ModDirectory) then
                modfoundcount = modfoundcount + 1
                LOG(''..ModName..': ['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] - Found directory: '..FilepathAndName..'.')
            end
        end
    end
    if modfoundcount == 1 then
        LOG(''..ModName..': ['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] - Check OK. Found '..modfoundcount..' '..ModDirectory..' directory.')
    else
        LOG(''..ModName..': ['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] - Check FAILED! Found '..modfoundcount..' '..ModDirectory..' directories.')
    end
    LOG(''..ModName..': ['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] - Checking files and filesize for '..ModDirectory..'...')
    local FilesInFolder = DiskFindFiles('/mods/'..ModDirectory..'/', '*.*')
    local filecount = 0
    local bytecount = 0
    for _, FilepathAndName in FilesInFolder do
        if not string.find(FilepathAndName, '.git') then
            filecount = filecount + 1
            local fileinfo = DiskGetFileInfo(FilepathAndName)
            bytecount = bytecount + fileinfo.SizeBytes
        end
    end
    local FAIL = false
    if filecount < Files then
        LOG(''..ModName..': ['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] - Check FAILED! Directory: '..ModDirectory..' - Missing '..(Files - filecount)..' files! ('..filecount..'/'..Files..')')
        FAIL = true
    elseif filecount > Files then
        LOG(''..ModName..': ['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] - Check FAILED! Directory: '..ModDirectory..' - Found '..(filecount - Files)..' odd files! ('..filecount..'/'..Files..')')
        FAIL = true
    end
    if bytecount < Bytes then
        LOG(''..ModName..': ['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] - Check FAILED! Directory: '..ModDirectory..' - Missing '..(Bytes - bytecount)..' bytes! ('..bytecount..'/'..Bytes..')')
        FAIL = true
    elseif bytecount > Bytes then
        LOG(''..ModName..': ['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] - Check FAILED! Directory: '..ModDirectory..' - Found '..(bytecount - Bytes)..' odd bytes! ('..bytecount..'/'..Bytes..')')
        FAIL = true
    end
    if not FAIL then
        LOG(''..ModName..': ['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] - Check OK! files: '..filecount..', bytecount: '..bytecount..'.')
    end
end

module("Hats", package.seeall )

include("legacytranslations.lua")

function LoadFromJSON()
    LogPrint( "Loading hats from data...", nil, "Hats" )

    if not file.Exists( "gmt_hat_dump.txt", "DATA" ) then
        LogPrint( "gmt_hat_dump.txt not found in data! aborting...", nil, "Hats" )
        return
    end

    local contents = file.Read( "gmt_hat_dump.txt", "DATA" )
    local tbl = util.JSONToTable( contents )

    if not tbl or table.IsEmpty( tbl ) then
        LogPrint( "failed to parse json! aborting...", nil, "Hats" )
        return
    end

    local count = 0

    for playermodel, hats in pairs( tbl ) do

        Data[ playermodel ] = {}
        
        for hat, data in pairs( hats ) do
            
            for i, val in ipairs( data ) do
                data[i] = tonumber( val )
            end

            Data[ playermodel ][ hat ] = data

            count = count + 1
            
        end

    end

    LogPrint( count .. " hat offsets added to data.", nil, "Hats" )
end

function LoadFromSQL()

    Database.Query( "SELECT * FROM `gm_hats`;", function( res, status, err )
    
        if status != QUERY_SUCCESS then
            return
        end

        for _, v in ipairs( res ) do
            
            local playermodel = string.lower( v.plymodel )
            local hat = string.lower( v.hat )
            
            if not Data[ playermodel ] then
                Data[ playermodel ] = {}
            end

            Data[ playermodel ][ hat ] = {
                v.vx, v.vy, v.vz,
                v.ap, v.ay, v.ar,
                v.scale,
            }

        end

        LogPrint( Format( "Loaded %s hat offsets from SQL.", string.FormatNumber( table.Count( res ) ) ), nil, "Hats" )

    end )

end

function SaveAll()
    LogPrint( "Preparing to save all offsets...", nil, "Hats" )

    local db = Database.GetObject().Object
    if not db then return end

    local q_clear = db:query( "TRUNCATE TABLE gm_hats;" )

    function q_clear:onError(err)
        LogPrint( "An error has occured while clearing hats: " .. tostring( err ), color_red, "Hats" )
    end

    function q_clear:onSuccess()
        local transaction = db:createTransaction()

        for playermodel, hats in pairs( Data ) do
            for hat, data in pairs( hats ) do
                local hatid = GetByName( hat )
                if not hatid then continue end

                local q = db:prepare("INSERT INTO gm_hats (id, plymodel, hat, vx, vy, vz, ap, ay, ar, scale) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);")
        
                q:setNumber( 1, hatid )
                q:setString( 2, string.lower( playermodel ) )
                q:setString( 3, string.lower( hat ) )
        
                q:setString( 4, tostring( data[1] ) )
                q:setString( 5, tostring( data[2] ) )
                q:setString( 6, tostring( data[3] ) )
        
                q:setString( 7, tostring( data[4] ) )
                q:setString( 8, tostring( data[5] ) )
                q:setString( 9, tostring( data[6] ) )
        
                q:setString( 10, tostring( data[7] ) )
            
                transaction:addQuery( q )
            end
        end
        
        function transaction:onError(err)
            LogPrint( "An error occured while inserting hats: " .. tostring( err ), color_red, "Hats" )
        end

        function transaction:onSuccess()
            LogPrint( "Successfully made transaction, offsets inserted!", color_green, "Hats" )
        end

        transaction:start()
    end

    q_clear:start()
end

hook.Add( "DatabaseConnected", "LoadHatOffsets", LoadFromSQL )
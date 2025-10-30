AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

include( "shared.lua" )

ENT.MaxDist = 512

function ENT:ClearGame()
    self.InitGame = false

    self:SetPly1( NULL, true )
    self:SetPly2( NULL, true )

    self.PlyTurn = 0

    self.Blocks = {}

    for i=0, (self:GetNumBlocks()*self:GetNumBlocks()) do
        self.Blocks[ i ] = { Occupied = false, Owner = 0 }
    end

    self.SelectedBlock = 0

    self:SendToClients()
end

function ENT:Initialize()
    self:SetModel( self.Model )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion(false)
	end

    self:ReloadOBBBounds()

    // Init Board
    self.LastPress = {}
    self.LastThink = 0
    self:ClearGame()
end

function ENT:InGame()
    return self.InitGame
end

function ENT:CheckDistance( ply )
	return ply:GetPos():WithinDistance( self:GetPos(), self.TblSize * 3.75 )
end

function ENT:SetPly1( ply, nosend )
    if ( IsValid( self.Ply1 ) ) then
        if ( ply != self.Ply1 ) then
            self.Ply1._Checkers = nil
        end
    end

    self.Ply1 = ply or NULL
    if ( IsValid( ply ) ) then
        ply._Checkers = self
    end
    
    if ( not nosend ) then
        self:SendToClients()
    end
end

function ENT:SetPly2( ply, nosend )
    if ( IsValid( self.Ply2 ) ) then
        if ( ply != self.Ply2 ) then
            self.Ply2._Checkers = nil
        end
    end

	self.Ply2 = ply or NULL
    if ( IsValid( ply ) ) then
        ply._Checkers = self
    end

    if ( not nosend ) then
        self:SendToClients()
    end
end

function ENT:ActivePlayer()
    if ( !self:InGame() ) then return NULL end

    return self.PlyTurn == 1 && self.Ply1 or self.Ply2
end

function ENT:GetPlyBlock( ply )
    if ( !IsValid( ply ) ) then
        return 0
    end

    local x, y = self:GetEyeBlock( ply )
    local block = self:XYToNum( x, y ) or 0

    return block
end

function ENT:GetBlock( num )
    return self.Blocks[ num ] or nil
end

function ENT:IsWhite( n )
    local block = self:GetBlock( n )
    return (block.Owner == 1 or block.Owner == 3) or false
end

function ENT:IsBlack( n )
    return not self:IsWhite( n )
end

function ENT:IsKing( n )
    local block = self:GetBlock( n )
    return (block.Owner == 3 or block.Owner == 4) or false
end

function ENT:CheckBlock( n1, n2 )
    local block = self:GetBlock( n1 )
    local block2 = self:GetBlock( n2 )

    local king = self:IsKing( n1 )
    local white = self:IsWhite( n1 )

    local x, y = self:NumToXY( n1 )
    local x2, y2 = self:NumToXY( n2 )

    if ( not king ) then
        if ( white ) then
            if ( x2 < x ) then
                return false, nil
            end
        else
            if ( x2 > x ) then
                return false, nil
            end
        end
    end

    if (((x + 1) == x2) or ((x - 1) == x2)) && (((y + 1) == y2) or ((y - 1) == y2)) then // one
        if ( not block2.Occupied ) then
            if ( king ) then
                return true, nil
            end

            if ( white ) then
                if ( x2 > x ) then
                    return true, nil
                end
            else
                if ( x2 < x ) then
                    return true, nil
                end
            end
        end
    elseif (((x + 2) == x2) or ((x - 2) == x2)) && (((y + 2) == y2) or ((y - 2) == y2)) then // two
        local oX, oY = x > x2 and 1 or -1, y > y2 and 1 or -1 // wtf?

        local rem_n = self:XYToNum( x2+oX, y2+oY )
        local rem_block = self:GetBlock( self:XYToNum( x2+oX, y2+oY ) )

        if ( !block.Occupied or !rem_block.Occupied or block.Owner == rem_block.Owner ) then
            return false
        end

        return true, rem_n
    end

    return false, nil
end

function ENT:SetBlock( n, tbl )
    self.Blocks[ n ] = tbl

    self:CheckBoard()
end

function ENT:ClearBlock( n )
    self:SetBlock( n, { Occupied = false, Owner = 0 } )

    self:CheckBoard()
end

function ENT:MovePiece( n1, n2 )
    local block = self:GetBlock( n1 )

    local x, y = self:NumToXY( n2 )

    local white = self:IsWhite( n1 )

    if ( white && x == 7 ) then
        block.Owner = 3
    elseif ( !white && x == 0 ) then
        block.Owner = 4
    end

    self:SetBlock( n2, block )
    self:ClearBlock( n1 )

    self.SelectedBlock = 0

    self:NextTurn()
end

function ENT:NextTurn()
    self.PlyTurn = self.PlyTurn == 1 and 2 or 1
end

function ENT:Use( ply )
    if ( !IsValid(ply) or !ply:IsPlayer() ) then return end
	if ( !self:CheckDistance( ply ) ) then return end

	local eyepos = self:GetEyeBlock( ply )

	local PlyIndex = ply:EntIndex()
	if CurTime() < (self.LastPress[ PlyIndex ] or 0) then
		return
	end

	self.LastPress[ PlyIndex ] = CurTime() + 0.5

    if ( not self:InGame() ) then
		if ( ( eyepos == 3 || eyepos == 4 ) && ( self:Get2DPos( ply ) >= 0.44 && self:Get2DPos( ply ) <= 0.56 ) ) then
			net.Start( "checkersH" )
			net.Send( ply )
			return
		end

        if ( self.Ply1 == ply ) then
			self:SetPly1( nil )
			return
		elseif ( self.Ply2 == ply ) then
			self:SetPly2( nil )
			return
		end


		if ( !IsValid( self.Ply1 ) && !ply._Checkers ) then
			self:SetPly1( ply )
		elseif ( !IsValid( self.Ply2 ) && !ply._Checkers ) then
			self:SetPly2( ply )
		end

		if ( IsValid( self.Ply1 ) && IsValid( self.Ply2 ) && self:CheckDistance( self.Ply1 ) && self:CheckDistance( self.Ply2 ) ) then
			self:BeginGame()
		end
    else
        local ply = self:ActivePlayer()
        local wanted = self:GetPlyBlock( ply )

        if ( self.SelectedBlock == wanted ) then
            self.SelectedBlock = nil
        else
            local block = self:GetBlock( wanted )
            if ( !block ) then return end

            local Owner = self:IsWhite( wanted ) && 1 or 2

            if ( block.Occupied ) then
                if ( Owner == self.PlyTurn ) then
                    self.SelectedBlock = wanted
                end
            else
                if ( self.SelectedBlock ) then
                    local can, rem = self:CheckBlock( self.SelectedBlock, wanted )

                    if ( can ) then
                        self:MovePiece( self.SelectedBlock, wanted )

                        if ( rem ) then
                            self:ClearBlock( rem )
                        end
                    end
                end
            end
        end

        self:SendToClients()
    end
end

function ENT:BeginGame()
    self.InitGame = true
	self.PlyTurn = 1

    for i=0, (self:GetNumBlocks()*self:GetNumBlocks()) do
        even = i % 2 == 0

        if ( (i <= 8 && !even) or (i > 8 && i <= 16 && even) or (i > 16 && i <= 24 && !even) ) then // fuck this
            self.Blocks[ i ] = { Occupied = true, Owner = 1 }
        elseif ( (i > 40 && i <= 48 && even) or (i > 48 && i <= 56 && !even) or (i > 56 && even) ) then // fuck this 2
            self.Blocks[ i ] = { Occupied = true, Owner = 2 }
        end
    end

    self:SendToClients()
end

function ENT:CheckBoard()
    local white_count = 0
    local black_count = 0

    for k, v in ipairs( self.Blocks ) do
        local white = self:IsWhite( k )

        if ( white ) then
            white_count = white_count + 1
        elseif ( not white ) then
            black_count = black_count + 1
        end
    end

    if ( white_count <= 0 ) then
        self:EndGame( 2 ) // black wins
    elseif ( black_count <= 0 ) then
        self:EndGame( 1 ) // white wins
    end
end

function ENT:EndGame( winner )
    local ply = winner == 1 and self.Ply1 or self.Ply2

    if ( IsValid( ply ) ) then
        local efx = EffectData()
	    efx:SetOrigin( ply:GetPos() )
	    efx:SetStart( Vector(1, 1, 1) )
	    util.Effect("confetti", efx)

        ply:EmitSound( "gmodtower/misc/win.wav" )

        ply:GiveMoney( 50 )
    end

    self:ClearGame()
end

function ENT:PlyValid( ply )
    if ( !ply or !IsValid( ply ) or !ply:IsPlayer() ) then
        return false
    end

    if ( ply:GetPos():Distance( self:GetPos() ) > self.MaxDist ) then
        return false
    end

    return true
end

function ENT:Think()
    if ( not self:PlyValid( self.Ply1 ) ) then
        if ( self:InGame() ) then
            self:ClearGame()
        else
            self:SetPly1( NULL )
        end
    end

    if ( not self:PlyValid( self.Ply2 ) ) then
        if ( self:InGame() ) then
            self:ClearGame()
        else
            self:SetPly2( NULL )
        end
    end
end

function ENT:OnRemove()
    self:SetPly1( NULL )
    self:SetPly2( NULL )
end

function ENT:SendToClients()
    net.Start( "boarddata" )
        net.WriteEntity( self )
        net.WriteUInt( 0, 1 )
        net.WriteUInt( self.SelectedBlock, 7 )

        for _, v in ipairs( self.Blocks ) do
            net.WriteBool( v.Occupied ) // block valid??

            if ( v.Occupied ) then
                net.WriteUInt( v.Owner, 3 ) // block owner (1,3 = white | 2,4 = black)
            end
        end

        net.WriteBool( self:InGame() ) // init game

        net.WriteEntity( self.Ply1 ) // ply1
        net.WriteEntity( self.Ply2 ) // ply2

        net.WriteUInt( self.PlyTurn, 2 )
    net.SendPVS( self:GetPos() )
end

util.AddNetworkString( "boarddata" )
util.AddNetworkString( "checkersH" )
local PLUGIN = PLUGIN
PLUGIN.name = 'UI_Granade'
PLUGIN.description = 'UI Rework'
PLUGIN.author = 'UltraDev'

if CLIENT then

    local circleColor = Color(0, 255, 0, 100)
    local lineColor = Color(0, 255, 0, 150)

    local function IsGrenade(weapon)
        return IsValid(weapon) and weapon:GetClass():find("grenade") ~= nil
    end

    local function GetGrenadeTrajectory()
        local ply = LocalPlayer()
        local weapon = ply:GetActiveWeapon()

        if not IsGrenade(weapon) then return end

        local shootPos = ply:GetShootPos()
        local eyeAngles = ply:EyeAngles()
        local handOffset = eyeAngles:Forward() * 20 + eyeAngles:Right() * 8 + eyeAngles:Up() * -4
        local launchPos = shootPos + handOffset
        local aimVec = ply:GetAimVector()

        local trajectory = {}
        local stepSize = 5
        local gravity = Vector(0, 0, -600)
        local velocity = aimVec * 1000
        local currentPos = launchPos
        local previousPos = currentPos

        for i = 1, 500 do
            local nextPos = currentPos + velocity * (stepSize / 1000)
            local trace = util.TraceLine({
                start = currentPos,
                endpos = nextPos,
                filter = ply
            })

            if trace.Hit then
                table.insert(trajectory, {start = previousPos, hit = trace.HitPos})

                local bounceNormal = trace.HitNormal:GetNormal()
                local bounceVelocity = velocity - (2 * velocity:Dot(bounceNormal) * bounceNormal) * 0.8
                local bouncePos = trace.HitPos + bounceNormal * 5
                previousPos = trace.HitPos

                for j = 1, 50 do
                    nextPos = previousPos + bounceVelocity * (stepSize / 1000)
                    trace = util.TraceLine({
                        start = previousPos,
                        endpos = nextPos,
                        filter = ply
                    })

                    if trace.Hit then
                        table.insert(trajectory, {start = previousPos, hit = trace.HitPos})
                        break
                    end

                    table.insert(trajectory, {start = previousPos, hit = nextPos})
                    previousPos = nextPos
                    bounceVelocity = bounceVelocity + gravity * (stepSize / 1000)
                end

                return trajectory, trace.HitPos, trace.HitNormal
            end

            table.insert(trajectory, {start = previousPos, hit = nextPos})
            previousPos = currentPos
            currentPos = nextPos
            velocity = velocity + gravity * (stepSize / 1000)
        end

        return trajectory
    end

    hook.Add("PostDrawTranslucentRenderables", "DrawGrenadeTrajectory", function()
        if not LocalPlayer():KeyDown(IN_ATTACK) then return end

        local trajectory, impactPos, normal = GetGrenadeTrajectory()

        if trajectory then
            for _, line in ipairs(trajectory) do
                render.SetColorMaterial()
                render.DrawBeam(line.start, line.hit, 3, 0, 0, lineColor)
            end
        end

        if impactPos and normal then
            local circleRadius = 10
            local segments = 100
            local circlePoints = {}
            for i = 0, segments do
                local angle = (i / segments) * (2 * math.pi)
                local x = circleRadius * math.cos(angle)
                local y = circleRadius * math.sin(angle)
                table.insert(circlePoints, {x = x, y = y})
            end

            surface.SetDrawColor(circleColor)
            surface.SetMaterial(Material("models/shiny"))
            cam.Start3D2D(impactPos, Angle(0, 0, 0), 1)
                draw.NoTexture()
                surface.DrawPoly(circlePoints)
            cam.End3D2D()
        end
    end)
end

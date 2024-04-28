function love.load() 
    love.window.setTitle("Pinball")
    love.window.setMode(400, 600)
    WIDTH = love.graphics.getWidth()
    HEIGHT = love.graphics.getHeight()

    colors = {
        white = {1, 1, 1, 1},
        black = {0, 0, 0, 1},
        red = {1, 0, 0, 1},
        green = {0, 1, 0, 1},
        blue = {0, 0, 1, 1},
        yellow = {1, 1, 0, 1},
        magenta = {1, 0, 1, 1},
        cyan = {0, 1, 1, 1},
        grey = {0.5, 0.5, 0.5, 1},
        orange = {1, 0.647, 0, 1},
        purple = {0.5, 0, 0.5, 1},
        brown = {0.647, 0.165, 0.165, 1}
    }

    wf = require "lib/windfield"
    world = wf.newWorld(0, 600, false)
    world:setQueryDebugDrawing(false)
    world:addCollisionClass('Ball')
    world:addCollisionClass('Flipper')
    world:addCollisionClass("GroundBall")
    world:addCollisionClass("Obs1")
    world:addCollisionClass("Obs2")
    world:addCollisionClass("Obs3")

    local pivotX, pivotY = 30, 506
    leftPipe = world:newRectangleCollider(pivotX, pivotY, 150, 20, {collision_class = "Flipper"})
    leftPipe:setType("kinematic")
    leftPipe:setAngle(-math.rad(-135)) -- Set the initial angle in radians
    angleLeft = -135 -- Store the angle in degrees for easier calculations
    leftBoundaries = world:newRectangleCollider(26, 425, 20, 37)
    leftBoundaries:setType("kinematic")
    leftBoundaries:setAngle(math.rad(135))

    local pivotX, pivotY = 200, 506
    rightPipe = world:newRectangleCollider(pivotX, pivotY, 150, 20, {collision_class = "Flipper"})
    rightPipe:setType("kinematic")
    rightPipe:setAngle(-math.rad(45)) -- Set the initial angle in radians
    angleRight = -45 -- Store the angle in degrees for easier calculations
    rightBoundaries = world:newRectangleCollider(340, 425, 20, 37)
    rightBoundaries:setType("kinematic")
    rightBoundaries:setAngle(math.rad(45))

    balls = {}

    wall = world:newRectangleCollider(348, 180, 30, HEIGHT)
    wall:setType("kinematic")
    
    local groundBall = world:newRectangleCollider(350, 590, 80, 10, {collision_class = "GroundBall"})
    groundBall:setType("kinematic")
    
    -- wall
    local topWall = world:newRectangleCollider(40, 0, WIDTH, 10)
    topWall:setType("kinematic")
    local topWallMiring = world:newRectangleCollider(295, 12, 150, 10)
    topWallMiring:setType("kinematic")
    topWallMiring:setAngle(45)
    local rightWall = world:newRectangleCollider(WIDTH, 0, 10, HEIGHT)
    rightWall:setType("kinematic")
    local leftWall = world:newRectangleCollider(0, 0, 40, HEIGHT)
    leftWall:setType("kinematic")

    bola = world:newCircleCollider(388, 482, 10, {collision_class = "Ball"})
    bola:setRestitution(0.5)

    -- obstacle environment
    local topObs = world:newCircleCollider(186, 100, 30, {collision_class = "Obs1"})
    topObs:setType("kinematic")
    local leftObs = world:newCircleCollider(106, 200, 30, {collision_class = "Obs2"})
    leftObs:setType("kinematic")
    local rightObs = world:newCircleCollider(260, 265, 30, {collision_class = "Obs3"})
    rightObs:setType("kinematic")

    isGround = false
    hitObs1 = false
    hitObs2 = false
    hitObs3 = false
end

function love.update(dt)
    if love.keyboard.isDown("right") then
        -- Only apply the impulse if the angle is less than a certain value
        hitObs1 = false
        hitObs2 = false
        hitObs3 = false
        if angleLeft > -225 then
            -- Rotate the flipper up
            -- leftPipe:applyAngularImpulse(-10000)
            angleLeft = angleLeft - (800 * dt) -- Increment the angleLeft, adjust speed as necessary
            if bola:enter("Flipper") then
                bola:applyLinearImpulse(0, -700)
            end
            -- for i = #balls, 1, -1 do
            --     local b = balls[i]
            --     if b:enter("Flipper") then
            --         b:applyLinearImpulse(0, -700)
            --     end
            -- end
        end
    else
        -- Rotate the flipper down
        if angleLeft < -135 then
            -- leftPipe:applyAngularImpulse(10000)
            angleLeft = angleLeft + (800 * dt) -- Decrement the angleLeft
        end
    end
   
    -- Ensure the flipper angleLeft stays within bounds
    angleLeft = math.max(-225, math.min(angleLeft, -135))
    leftPipe:setAngle(math.rad(angleLeft))

    if love.keyboard.isDown("left") then
        -- Only apply the impulse if the angle is less than a certain value
        hitObs1 = false
        hitObs2 = false
        hitObs3 = false
        if angleRight < 45 then
            -- Rotate the flipper up
            -- rightPipe:applyAngularImpulse(-10000)
            angleRight = angleRight + (800 * dt) -- Increment the angleRight, adjust speed as necessary
            if bola:enter("Flipper") then
                bola:applyLinearImpulse(0, -700)
            end
            -- for i = #balls, 1, -1 do
            --     local b = balls[i]
            --     if b:enter("Flipper") then
            --         b:applyLinearImpulse(0, -700)
            --     end
            -- end
        end
    else
        -- Rotate the flipper down
        if angleRight > -45 then
            -- rightPipe:applyAngularImpulse(10000)
            angleRight = angleRight - (800 * dt) -- Decrement the angleRight
        end
    end

    -- Ensure the flipper angleRight stays within bounds
    angleRight = math.max(-45, math.min(angleRight, 45))
    rightPipe:setAngle(math.rad(angleRight))

    if bola:enter("Obs1") then
        hitObs1 = true
    elseif bola:enter("Obs2") then
        hitObs2 = true
    elseif bola:enter("Obs3") then
        hitObs3 = true
    end
    
    -- initiate bola jump
    if bola:enter("GroundBall") then
        isGround = true
        hitObs1 = false
        hitObs2 = false
        hitObs3 = false
    end

    if love.keyboard.isDown("space") and isGround then
        bola:applyLinearImpulse(0, -900)
        isGround = false
    end

    -- check if bola jatuh ke bawah
    local _, by = bola:getPosition()
    if by > HEIGHT + 200 then
        bola:setPosition(388, 482)
    end

    world:update(dt)
end

function love.draw()
    world:draw()
    -- draw obstacle color
    -- local topObs = world:newCircleCollider(186, 100, 30, {collision_class = "Obs1"})
    -- topObs:setType("kinematic")
    -- local leftObs = world:newCircleCollider(106, 200, 30, {collision_class = "Obs2"})
    -- leftObs:setType("kinematic")
    -- local rightObs = world:newCircleCollider(260, 265, 30, {collision_class = "Obs3"})
    -- rightObs:setType("kinematic")
    if hitObs1 then
        love.graphics.setColor(colors.yellow)
        love.graphics.circle("fill", 186, 100, 30)
        love.graphics.setColor(colors.yellow)
    end
    if hitObs2 then
        love.graphics.setColor(colors.green)
        love.graphics.circle("fill", 106, 200, 30)
        love.graphics.setColor(colors.green)
    end
    if hitObs3 then
        love.graphics.setColor(colors.purple)
        love.graphics.circle("fill", 260, 265, 30)
        love.graphics.setColor(colors.purple)
    end


    love.graphics.setColor(colors.cyan)
    love.graphics.rectangle("fill", 0,0,40,HEIGHT)
    love.graphics.setColor(colors.cyan)
    love.graphics.setColor(colors.cyan)
    love.graphics.rectangle("fill", 348, 180,30,HEIGHT)
    love.graphics.setColor(colors.cyan)

    -- -- draw mouse position untuk utility
    love.graphics.print("mouse x = " .. love.mouse.getX(), 10, 10)  
    love.graphics.print("mouse y = " .. love.mouse.getY(), 10, 40)

end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
       love.event.quit()
    end 
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 2 then
        local ball = world:newCircleCollider(x, y, 10, {collision_class = "Ball"})
        ball:setRestitution(0.5)
        table.insert(balls, ball)
    end
end
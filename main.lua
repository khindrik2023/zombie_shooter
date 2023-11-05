function love.load()
    math.randomseed(os.time())
    screenHeight = love.graphics.getHeight()
    screenWidth = love.graphics.getWidth()

    sprites = {}
    sprites.background = love.graphics.newImage("/sprites/background.png")
    sprites.bullet = love.graphics.newImage("/sprites/bullet.png")
    sprites.player = love.graphics.newImage("/sprites/player.png")
    sprites.zombie = love.graphics.newImage("/sprites/zombie.png")
    sprites.smoke = love.graphics.newImage("/sprites/smoke.png")


    player = {}
    player.x = screenWidth / 2
    player.y = screenHeight / 2
    player.speed = 180
    player.Injured = false

    zombies = {}
    bullets = {}

    gameState = 1
    maxTime = 2
    timer = maxTime
    injured_timer = 2
    score = 0
    myFont = love.graphics.newFont(30)

end

-- UPDATE ---------------------------------------------------
function love.update(dt)
    
    -- Player movement --
    if gameState == 2 then
        if love.keyboard.isDown('d') then
            if player.x < screenWidth - 30 then
                player.x = player.x + player.speed * dt
            end
        end
        if love.keyboard.isDown('a') then
            if player.x > 30 then
                player.x = player.x - player.speed * dt
            end
        end
        if love.keyboard.isDown('w') then
            if player.y > 30 then
                player.y = player.y - player.speed * dt
            end
        end
        if love.keyboard.isDown('s') then
            if player.y < screenHeight - 30 then
                player.y = player.y + player.speed * dt
            end
        end
    end

    -- Zombie movement --
    for i,z in ipairs(zombies) do
        z.x = z.x + math.cos( zombiePlayerAngle(z) ) * z.speed * dt
        z.y = z.y + math.sin( zombiePlayerAngle(z) ) * z.speed * dt

        -- ZOMBIE/ PLAYER COLLISION --
        if distanceBetween(z.x, z.y, player.x, player.y) < 30 and player.Injured == false then
            player.Injured = true

        elseif distanceBetween(z.x, z.y, player.x, player.y) < 30 and player.Injured == true and injured_timer <= 0 then
            for i,z in ipairs(zombies) do
                zombies[i] = nil
                gameState = 1
                player.x = screenWidth/2
                player.y = screenHeight/2
                player.Injured = false
            end
        end
    end

    if player.Injured == true then
        injured_timer = injured_timer - dt
    end

    -- Bullet movement --
    for i,b in ipairs(bullets) do 
        b.x = b.x + math.cos(b.direction) * b.speed * dt
        b.y = b.y + math.sin(b.direction) * b.speed * dt
    end

    for i=#bullets, 1, -1 do
        local b = bullets[i]
        if b.x < -30 or b.y < -30 or b.x > love.graphics.getWidth() + 30 or b.y > love.graphics.getHeight() + 30 then
            table.remove(bullets, i)
        end
    end

    -- Check for bullet/zombie collisions --
    for i,z in ipairs(zombies) do
        for i,b in ipairs(bullets) do
            if distanceBetween(b.x, b.y, z.x, z.y) < 20 then
                z.dead = true
                b.dead = true
                score = score + 1
            end
        end
    end

    -- for "true" bullet/zombie collisions, remove zombie and bullet --
    for i=#bullets, 1, -1 do
        local b = bullets[i]
        if b.dead == true then
            table.remove(bullets, i)
        end
    end

    for i=#zombies, 1, -1 do
        local z = zombies[i]
        if z.dead == true then
            table.remove(zombies, i)
        end
    end

    -- TIMER for zombie spawing --
    if gameState == 2 then
        timer = timer - dt
        if timer <= 0 then
            spawnZombie()
            maxTime = maxTime * .95
            timer = maxTime
        end
    end
    


end

-- DRAW --------------------------------------------------
function love.draw()
    love.graphics.draw(sprites.background, 0, 0)

    if gameState == 1 then
        love.graphics.setFont(myFont)
        love.graphics.printf("Click anywhere to begin", 0, 50, screenWidth, "center")
    end

    love.graphics.printf("Score: ".. score, 0, 500, screenWidth, "center")
    
    if player.Injured == true then
        love.graphics.setColor(1, 0, 0)
    end

    love.graphics.draw(sprites.player, player.x, player.y, playerMouseAngle(), nil, nil, sprites.player:getWidth()/2, sprites.player:getHeight()/2)

    love.graphics.setColor(1, 1, 1)

    for i,z in ipairs(zombies) do
        love.graphics.draw(sprites.zombie, z.x, z.y, zombiePlayerAngle(z), nil, nil, sprites.zombie:getWidth()/2, sprites.zombie:getHeight()/2)
    end

    for i,b in ipairs(bullets) do
        love.graphics.draw(sprites.bullet, b.x, b.y, b.direction, .5, .5, sprites.bullet:getWidth()/2, sprites.bullet:getHeight()/2)
    end

end

-- ZOMBIE FUNCTIONS ----------------------------------------
function spawnZombie()
    local zombie = {}
    zombie.x = 0
    zombie.y = 0
    zombie.speed = 100
    zombie.dead = false

    local side = math.random(1, 4)
    if side == 1 then
        zombie.x = -30
        zombie.y = math.random(0, love.graphics.getHeight())
    
    elseif side == 2 then
        zombie.x = math.random(0, love.graphics.getWidth())
        zombie.y = -30
    
    elseif side == 3 then
        zombie.x = love.graphics.getWidth() + 30
        zombie.y = math.random(0, love.graphics.getHeight())
    
    elseif side == 4 then
        zombie.x = math.random(0, love.graphics.getWidth())
        zombie.y = love.graphics.getHeight() + 30
    end

    table.insert(zombies, zombie)
end

function love.keypressed(key)
    if key == 'space' then
        spawnZombie()
    end
end

-- BULLET FUNCTIONS ----------------------------------------
function spawnBullet()
    local bullet = {}
    bullet.x = player.x
    bullet.y = player.y
    bullet.speed = 500
    bullet.direction = playerMouseAngle()
    bullet.dead = false
    table.insert(bullets, bullet)
end

function love.mousepressed(x, y, button)
    if button == 1 and gameState == 2 then
        spawnBullet()
    elseif button == 1 and gameState == 1 then
        gameState = 2
        maxTime = 2
        timer = maxTime
        score = 0
    end
end
-- ROTATION FUNCTIONS --------------------------------------
function playerMouseAngle()
    return math.atan2((love.mouse.getY() - player.y), (love.mouse.getX() - player.x))
end

function zombiePlayerAngle(z)
    return math.atan2(player.y - z.y, player.x - z.x)
end

-- DISTANCE CALCULATION -----------------------------------
function distanceBetween(x1, y1, x2, y2)
    return math.sqrt((x1 - x2)^2 + (y1 - y2)^2)
end

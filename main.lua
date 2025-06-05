-- File: main.lua

function love.load()
    -- Set up the game window
    love.window.setTitle("Mr. Tiburon Attack - Underwater Feeding Frenzy!")
    
    -- Create high-quality fonts for HD text
    fonts = {}
    fonts.title = love.graphics.newFont(72) -- Large HD font for title
    fonts.subtitle = love.graphics.newFont(48) -- Medium font for subtitle
    fonts.button = love.graphics.newFont(24) -- Button font
    fonts.ui = love.graphics.newFont(16) -- UI font
    fonts.small = love.graphics.newFont(14) -- Small text font
    
    -- Game state system
    game_state = "menu" -- "menu" or "playing"
    
    -- Menu variables
    menu = {}
    menu.title_scale = 1
    menu.title_pulse_timer = 0
    menu.play_button = {
        x = 300,
        y = 350,
        width = 200,
        height = 60,
        hover = false
    }
    menu.menu_shark = {
        x = -100,
        y = 200,
        speed = 30,
        facing = 1
    }
    
    -- Load the shark (player)
    shark = {}
    shark.x = 400
    shark.y = 300
    shark.width = 100 -- Target size
    shark.height = 64 -- Target size
    shark.speed = 200
    shark.image = nil -- Will load shark.png if available
    shark.scale_x = 1
    shark.scale_y = 1
    shark.facing = 1  -- 1 for right, -1 for left
    
    -- Try to load shark sprite
    if love.filesystem.getInfo("sprites/shark.png") then
        shark.image = love.graphics.newImage("sprites/shark.png")
        -- Calculate scale to fit our target size
        shark.scale_x = shark.width / shark.image:getWidth()
        shark.scale_y = shark.height / shark.image:getHeight()
    end
    
    -- Fish system
    fish = {}
    fish_spawn_timer = 0
    fish_spawn_rate = 2.0 -- seconds between spawns


    
    -- Fish types
    fish_types = {
        {
            name = "tropical_fish",
            points = 10,
            speed = 50,
            color = {1, 0.5, 0.2}, -- Orange
            image = nil,
            width = 40,  -- Target size for fish
            height = 34
        },
        {
            name = "goldfish", 
            points = 15,
            speed = 30,
            color = {1, 0.8, 0}, -- Gold
            image = nil,
            width = 32,  -- Goldfish slightly bigger
            height = 38
        }
    }
    
    -- Try to load fish sprites and calculate their scales
    if love.filesystem.getInfo("sprites/tropical_fish.png") then
        fish_types[1].image = love.graphics.newImage("sprites/tropical_fish.png")
        fish_types[1].scale_x = fish_types[1].width / fish_types[1].image:getWidth()
        fish_types[1].scale_y = fish_types[1].height / fish_types[1].image:getHeight()
    end
    if love.filesystem.getInfo("sprites/goldfish.png") then
        fish_types[2].image = love.graphics.newImage("sprites/goldfish.png")
        fish_types[2].scale_x = fish_types[2].width / fish_types[2].image:getWidth()
        fish_types[2].scale_y = fish_types[2].height / fish_types[2].image:getHeight()
    end
    
    -- Game state
    score = 0
    game_time = 0
    
    -- Underwater background color (deep blue)
    background_color = {0.1, 0.3, 0.6}
    
    -- Bubble effects (for both menu and game)
    bubbles = {}
    bubble_timer = 0
    
    -- Initialize some menu bubbles
    for i = 1, 15 do
        create_bubble()
    end
end

function love.update(dt)
    -- Update bubbles (always active)
    bubble_timer = bubble_timer + dt
    if bubble_timer > 0.3 then
        create_bubble()
        bubble_timer = 0
    end
    
    -- Update bubbles
    for i = #bubbles, 1, -1 do
        local bubble = bubbles[i]
        bubble.y = bubble.y - bubble.speed * dt
        bubble.age = bubble.age + dt
        
        if bubble.y < -10 or bubble.age > 15 then
            table.remove(bubbles, i)
        end
    end
    
    if game_state == "menu" then
        update_menu(dt)
    elseif game_state == "playing" then
        update_game(dt)
    end
end

function update_menu(dt)
    -- Animate title pulsing
    menu.title_pulse_timer = menu.title_pulse_timer + dt
    menu.title_scale = 1 + math.sin(menu.title_pulse_timer * 2) * 0.1
    
    -- Animate menu shark swimming across screen
    menu.menu_shark.x = menu.menu_shark.x + menu.menu_shark.speed * dt
    
    -- Reset shark position when it goes off screen
    if menu.menu_shark.x > love.graphics.getWidth() + 100 then
        menu.menu_shark.x = -150
        menu.menu_shark.y = love.math.random(150, 400)
    end
    
    -- Check mouse hover over play button
    local mouse_x, mouse_y = love.mouse.getPosition()
    menu.play_button.hover = mouse_x >= menu.play_button.x and 
                           mouse_x <= menu.play_button.x + menu.play_button.width and
                           mouse_y >= menu.play_button.y and 
                           mouse_y <= menu.play_button.y + menu.play_button.height
end

function update_game(dt)
    game_time = game_time + dt
    
    -- Handle shark movement and update facing direction
    local moving = false
    
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        shark.x = shark.x + shark.speed * dt
        shark.facing = 1  -- Face right
        moving = true
    end
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        shark.x = shark.x - shark.speed * dt
        shark.facing = -1  -- Face left
        moving = true
    end
    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        shark.y = shark.y + shark.speed * dt
        moving = true
    end
    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        shark.y = shark.y - shark.speed * dt
        moving = true
    end
    
    -- Keep shark on screen
    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()
    
    if shark.x < 0 then shark.x = 0 end
    if shark.y < 0 then shark.y = 0 end
    if shark.x + shark.width > window_width then 
        shark.x = window_width - shark.width 
    end
    if shark.y + shark.height > window_height then 
        shark.y = window_height - shark.height 
    end
    
    -- Spawn fish
    fish_spawn_timer = fish_spawn_timer + dt
    if fish_spawn_timer >= fish_spawn_rate then
        spawn_fish()
        fish_spawn_timer = 0
    end
    
    -- Update fish
    for i = #fish, 1, -1 do
        local f = fish[i]
        
        -- Move fish (they swim around randomly)
        f.x = f.x + f.vel_x * dt
        f.y = f.y + f.vel_y * dt
        
        -- Bounce fish off screen edges
        if f.x <= 0 or f.x + f.width >= window_width then
            f.vel_x = -f.vel_x
        end
        if f.y <= 0 or f.y + f.height >= window_height then
            f.vel_y = -f.vel_y
        end
        
        -- Check collision with shark (eating!)
        if check_collision(shark, f) then
            score = score + f.points
            table.remove(fish, i)
        end
        
        -- Remove fish that are too old (prevent infinite buildup)
        f.age = f.age + dt
        if f.age > 30 then -- Remove after 30 seconds
            table.remove(fish, i)
        end
    end
end

function love.draw()
    -- Set underwater background
    love.graphics.setBackgroundColor(background_color)
    
    -- Draw bubbles (always)
    love.graphics.setColor(0.7, 0.9, 1, 0.4) -- Light blue, transparent
    for _, bubble in ipairs(bubbles) do
        love.graphics.circle("fill", bubble.x, bubble.y, bubble.size)
    end
    
    if game_state == "menu" then
        draw_menu()
    elseif game_state == "playing" then
        draw_game()
    end
end

function draw_menu()
    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()
    
    -- Draw animated menu shark
    draw_shark_sprite(menu.menu_shark.x, menu.menu_shark.y, 1, 0.8)
    
    -- Draw title with BLOOD DRIPPING effect!
    local title = "MR TIBURON"
    local subtitle = "ATTACK!"
    
    -- Use HD fonts instead of scaling
    love.graphics.setFont(fonts.title)
    local title_width = fonts.title:getWidth(title)
    local title_x = window_width/2 - title_width/2
    local title_y = 80 + math.sin(menu.title_pulse_timer * 2) * 5 -- Pulsing movement
    
    -- BLOOD DRIPPING SHADOW EFFECT - Multiple dark red shadows for depth
    love.graphics.setColor(0.3, 0, 0, 0.8) -- Dark blood shadow
    love.graphics.print(title, title_x + 4, title_y + 6)
    love.graphics.setColor(0.2, 0, 0, 0.6) -- Even darker shadow
    love.graphics.print(title, title_x + 6, title_y + 8)
    
    -- MAIN BLOOD RED TITLE with simple pulsing (NO ORIGIN PARAMETERS!)
    love.graphics.setColor(0.8, 0.1, 0.1) -- Deep blood red
    local pulse_scale = 1 + math.sin(menu.title_pulse_timer * 2) * 0.05 -- Subtle pulse
    
    -- Calculate adjusted position for centered scaling
    local scaled_width = title_width * pulse_scale
    local scaled_height = fonts.title:getHeight() * pulse_scale
    local adjusted_x = title_x - (scaled_width - title_width) / 2
    local adjusted_y = title_y - (scaled_height - fonts.title:getHeight()) / 2
    
    love.graphics.print(title, adjusted_x, adjusted_y, 0, pulse_scale, pulse_scale)
    
    -- BLOOD DRIP EFFECTS - Create dripping lines
    love.graphics.setColor(0.6, 0, 0, 0.8) -- Blood drip color
    local drip_time = menu.title_pulse_timer * 3
    
    -- Multiple blood drips from different letters
    for i = 1, 5 do
        local drip_x = title_x + (title_width / 6) * i + math.sin(drip_time + i) * 3
        local drip_start_y = title_y + fonts.title:getHeight()
        local drip_length = 15 + math.sin(drip_time + i * 0.5) * 8
        
        -- Draw dripping blood line
        love.graphics.setLineWidth(2 + math.sin(drip_time + i) * 1)
        love.graphics.line(drip_x, drip_start_y, drip_x, drip_start_y + drip_length)
        
        -- Blood droplet at the end
        love.graphics.circle("fill", drip_x, drip_start_y + drip_length, 2)
    end
    
    -- SUBTITLE with blood effect
    love.graphics.setFont(fonts.subtitle)
    local subtitle_width = fonts.subtitle:getWidth(subtitle)
    local subtitle_x = window_width/2 - subtitle_width/2
    local subtitle_y = 170
    
    -- Subtitle blood shadow
    love.graphics.setColor(0.2, 0, 0, 0.6)
    love.graphics.print(subtitle, subtitle_x + 3, subtitle_y + 3)
    
    -- Main subtitle in blood red
    love.graphics.setColor(0.9, 0.2, 0.2) -- Slightly brighter blood red
    love.graphics.print(subtitle, subtitle_x, subtitle_y)
    
    -- More blood drips from ATTACK!
    love.graphics.setColor(0.5, 0, 0, 0.7)
    for i = 1, 3 do
        local drip_x = subtitle_x + (subtitle_width / 4) * i + math.sin(drip_time * 1.5 + i) * 2
        local drip_start_y = subtitle_y + fonts.subtitle:getHeight()
        local drip_length = 10 + math.sin(drip_time * 1.5 + i * 0.7) * 5
        
        love.graphics.setLineWidth(1.5)
        love.graphics.line(drip_x, drip_start_y, drip_x, drip_start_y + drip_length)
        love.graphics.circle("fill", drip_x, drip_start_y + drip_length, 1.5)
    end
    
    -- Draw play button with hover effect
    if menu.play_button.hover then
        love.graphics.setColor(0.2, 0.8, 1, 0.8) -- Bright blue when hovered
    else
        love.graphics.setColor(0.1, 0.5, 0.8, 0.6) -- Darker blue normally
    end
    
    love.graphics.rectangle("fill", menu.play_button.x, menu.play_button.y, 
                           menu.play_button.width, menu.play_button.height, 10, 10)
    
    -- Play button border
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", menu.play_button.x, menu.play_button.y, 
                           menu.play_button.width, menu.play_button.height, 10, 10)
    
    -- Play button text with HD font
    love.graphics.setFont(fonts.button)
    love.graphics.setColor(1, 1, 1)
    local button_text = "PLAY"
    local button_text_width = fonts.button:getWidth(button_text)
    local button_text_height = fonts.button:getHeight()
    
    -- Button text shadow
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.print(button_text, 
                       menu.play_button.x + menu.play_button.width/2 - button_text_width/2 + 1,
                       menu.play_button.y + menu.play_button.height/2 - button_text_height/2 + 1)
    
    -- Main button text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(button_text, 
                       menu.play_button.x + menu.play_button.width/2 - button_text_width/2,
                       menu.play_button.y + menu.play_button.height/2 - button_text_height/2)
    
    -- Instructions with proper font
    love.graphics.setFont(fonts.small)
    love.graphics.setColor(0.8, 0.9, 1, 0.8)
    love.graphics.printf("Hunt tropical fish and goldfish in the deep ocean!", 0, 450, window_width, "center")
    love.graphics.printf("Use WASD or Arrow Keys to swim around", 0, 470, window_width, "center")
    love.graphics.printf("Click PLAY to start your underwater adventure!", 0, 490, window_width, "center")
end

function draw_game()
    -- COMPLETELY CLEAR ANY PREVIOUS FONT/COLOR SETTINGS
    love.graphics.setFont(fonts.ui)
    love.graphics.setColor(1, 1, 1, 1) -- Fully opaque white
    
    -- Draw fish
    for _, f in ipairs(fish) do
        if f.image then
            love.graphics.setColor(1, 1, 1) -- White tint for image
            love.graphics.draw(f.image, f.x, f.y, 0, f.scale_x, f.scale_y)
        else
            love.graphics.setColor(f.color)
            love.graphics.rectangle("fill", f.x, f.y, f.width, f.height)
        end
    end
    
    -- Draw shark with proper flipping
    draw_shark_sprite(shark.x, shark.y, shark.facing, 1)
    
    -- ENSURE WE'RE USING THE RIGHT FONT AND COLOR FOR UI
    love.graphics.setFont(fonts.ui)
    love.graphics.setColor(1, 1, 1, 1) -- Pure white, fully opaque
    
    -- Game stats ONLY (NO TITLE AT ALL!)
    love.graphics.print("Score: " .. score, 10, 10)
    love.graphics.print("Fish Eaten: " .. math.floor(score/10), 10, 30)
    love.graphics.print("Time: " .. math.floor(game_time) .. "s", 10, 50)
    
    -- Instructions with smaller font
    love.graphics.setFont(fonts.small)
    love.graphics.setColor(1, 1, 1, 1) -- Ensure white color
    love.graphics.print("Use WASD or Arrow Keys to hunt fish!", 10, love.graphics.getHeight() - 60)
    love.graphics.print("ESC to return to menu", 10, love.graphics.getHeight() - 40)
    love.graphics.print("R to restart", 10, love.graphics.getHeight() - 20)
    
    -- RESET TO DEFAULT FONT TO PREVENT BLEEDING
    love.graphics.setFont(fonts.ui)
end

function draw_shark_sprite(x, y, facing, alpha)
    love.graphics.setColor(1, 1, 1, alpha) -- White tint with alpha
    
    if shark.image then
        if facing == -1 then
            -- When facing left, we need to draw from the right edge of the sprite
            love.graphics.draw(shark.image, x + shark.width, y, 0, -shark.scale_x, shark.scale_y)
        else
            -- Normal right-facing draw
            love.graphics.draw(shark.image, x, y, 0, shark.scale_x, shark.scale_y)
        end
    else
        -- Draw a simple gray shark shape that also flips
        love.graphics.setColor(0.5, 0.5, 0.5, alpha) -- Gray with alpha
        love.graphics.rectangle("fill", x, y, shark.width, shark.height)
        
        -- Add a triangle for shark nose that points in the right direction
        if facing == 1 then
            -- Right-facing nose
            love.graphics.polygon("fill", 
                x + shark.width, y + shark.height/2,
                x + shark.width + 15, y + shark.height/2 - 8,
                x + shark.width + 15, y + shark.height/2 + 8
            )
        else
            -- Left-facing nose
            love.graphics.polygon("fill", 
                x, y + shark.height/2,
                x - 15, y + shark.height/2 - 8,
                x - 15, y + shark.height/2 + 8
            )
        end
    end
end

function spawn_fish()
    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()
    
    -- Choose random fish type
    local fish_type = fish_types[love.math.random(1, #fish_types)]
    
    local new_fish = {
        x = love.math.random(0, window_width - fish_type.width),
        y = love.math.random(0, window_height - fish_type.height),
        width = fish_type.width,
        height = fish_type.height,
        vel_x = love.math.random(-fish_type.speed, fish_type.speed),
        vel_y = love.math.random(-fish_type.speed, fish_type.speed),
        points = fish_type.points,
        color = fish_type.color,
        image = fish_type.image,
        scale_x = fish_type.scale_x or 1,
        scale_y = fish_type.scale_y or 1,
        age = 0
    }
    
    table.insert(fish, new_fish)
end

function check_collision(rect1, rect2)
    return rect1.x < rect2.x + rect2.width and
           rect2.x < rect1.x + rect1.width and
           rect1.y < rect2.y + rect2.height and
           rect2.y < rect1.y + rect1.height
end

function create_bubble()
    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()
    
    local bubble = {
        x = love.math.random(0, window_width),
        y = window_height + 10,
        size = love.math.random(3, 12),
        speed = love.math.random(15, 45),
        age = 0
    }
    
    table.insert(bubbles, bubble)
end

function love.keypressed(key)
    if key == "escape" then
        if game_state == "playing" then
            game_state = "menu"
        else
            love.event.quit()
        end
    end
    
    -- Restart game with R (only in game)
    if key == "r" and game_state == "playing" then
        restart_game()
    end
    
    -- F5 restart
    if key == "f5" then
        love.event.quit("restart")
    end
end

function love.mousepressed(x, y, button)
    if button == 1 and game_state == "menu" then -- Left click
        if menu.play_button.hover then
            start_game()
        end
    end
end

function start_game()
    game_state = "playing"
    restart_game()
end

function restart_game()
    fish = {}
    score = 0
    game_time = 0
    shark.x = 400
    shark.y = 300
    shark.facing = 1
end 
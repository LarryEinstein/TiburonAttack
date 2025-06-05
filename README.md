# Shark Attack - Underwater Feeding Frenzy!

An exciting underwater shark game built with LÖVE 2D (Love2D) and Lua! Control a hungry shark and hunt tropical fish and goldfish in the deep blue sea.

## What You Need

1. **Download and Install LÖVE 2D**:
   - Go to https://love2d.org/
   - Download the latest version for Windows
   - Install it

## How to Run

1. **Method 1**: Drag your project folder onto the Love2D executable
2. **Method 2**: Navigate to your project folder in Command Prompt and run:
   ```cmd
   "C:\Program Files\LOVE\love.exe" .
   ```
   (Adjust the path if LÖVE is installed elsewhere)

3. **Method 3**: If LÖVE is in your PATH, simply run:
   ```cmd
   love .
   ```

## Controls

- **WASD** or **Arrow Keys**: Swim around as the shark
- **ESC**: Quit the game
- **R**: Restart the game

## Game Features

- 🦈 **Play as a Shark**: Control a hungry shark swimming through the ocean
- 🐠 **Hunt Fish**: Catch tropical fish (10 points) and goldfish (15 points)
- 🫧 **Underwater Atmosphere**: Bubbles floating up for immersion
- 📊 **Score System**: Track your score and fish eaten
- ⏱️ **Timer**: See how long you've been hunting
- 🎯 **Collision Detection**: Precise fish-catching mechanics

## Current Features

- ✅ Shark movement and controls
- ✅ Fish spawning system (2 types: tropical fish & goldfish)
- ✅ Collision detection (shark eating fish)
- ✅ Score tracking
- ✅ Bubble effects for atmosphere
- ✅ Fish AI (they swim around and bounce off walls)
- ✅ Game timer
- ✅ Sprite support ready

## Adding Your Sprites

Create a `sprites` folder in your project and add these files:

### Required Sprite Files:
1. **`shark.png`** - Your shark sprite (the player)
2. **`tropical_fish.png`** - Orange/colorful tropical fish
3. **`goldfish.png`** - Golden colored fish (worth more points)

### File Structure:
```
Pokemon/                    (your project folder)
├── main.lua
├── conf.lua
├── README.md
└── sprites/
    ├── shark.png          ← Put your shark sprite here
    ├── tropical_fish.png  ← Put your tropical fish sprite here
    └── goldfish.png       ← Put your goldfish sprite here
```

The game will automatically detect and load your sprites! If no sprites are found, it will use simple colored shapes instead.

## Game Mechanics

- **Fish spawn every 2 seconds** at random locations
- **Tropical fish** swim at medium speed and give 10 points
- **Goldfish** swim slower but give 15 points  
- **Fish bounce off walls** and swim around randomly
- **Fish despawn after 30 seconds** to prevent screen clutter
- **Bubbles rise from bottom** for underwater atmosphere

## Future Enhancement Ideas

- Different shark types with unique abilities
- Power-ups (speed boost, bigger shark, etc.)
- More fish varieties with different behaviors
- Obstacles to avoid (jellyfish, sea mines)
- Health system
- Level progression
- Sound effects and underwater music
- High score system

Dive in and start hunting! 🦈🐠 
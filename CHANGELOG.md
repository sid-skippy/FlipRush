# Changelog

All notable changes to FlipRush will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.7] - 2025-02-15

### Changed
- Updated version number to 1.0.7
- Removed background music system for better performance
- Removed ball trail effect for cleaner visuals
- Optimized code by removing unused functions

### Fixed
- Fixed coin sound to play only on actual coin collection (not every 5 points)
- Fixed slow-mo power-up sound effect (now plays correctly)
- Fixed sound conflicts between different power-ups

### Removed
- Background music toggle from settings
- Haptics toggle from settings (always-on haptics)
- Ball trail particle effect
- Unused `loadHighScore()` function
- Unused `isNewHighScore` variable
- Unused `minObstacleGap` variable
- Unused `lastObstacleX` variable

### Performance
- Reduced code from 2,968 to 2,953 lines
- Improved frame rate consistency
- Reduced memory usage

## [1.0.0] - 2025-02-01

### Added
- Initial release of FlipRush
- Core gravity-flip gameplay mechanics
- Tap to flip gravity controls
- Obstacle spawning and collision detection
- Power-up system:
  - Shield: Protects from one collision
  - Slow-Mo: Slows down game speed
  - Shrink: Makes ball smaller
  - Double Points: 2x score multiplier
- Coin collection and economy system
- In-game shop for purchasing power-ups
- Ball skin customization system
- Sound effects for:
  - Gravity flip
  - Explosions
  - Coin collection
  - Power-up pickup
- Particle effects:
  - Explosion particles on death
  - Tap ripples
  - Celebration particles on high score
- Background star parallax effect
- High score tracking (in-memory)
- Settings screen with:
  - Sound effects toggle
- Start screen with:
  - Play button
  - Instructions
  - Settings access
  - Skin selection
- Smooth animations and transitions
- Haptic feedback on key events
- Professional splash screen
- Credits and about information

### Technical
- Built with Flutter 3.0+
- Uses Google Fonts (Orbitron, Space Grotesk)
- AudioPlayers for sound effects
- 60 FPS gameplay
- Optimized performance
- Material Design UI

## Upcoming Features

See [STAND_OUT_FEATURES.md](docs/STAND_OUT_FEATURES.md) for planned features:
- Combo system
- Near-miss bonus
- Daily challenges
- Achievement system
- Color themes
- Ghost mode
- Share score functionality

---

## Version Naming Convention

- **Major.Minor.Patch** (e.g., 1.0.7)
- **Major**: Breaking changes or major feature additions
- **Minor**: New features, backwards compatible
- **Patch**: Bug fixes and small improvements

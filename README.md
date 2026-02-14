# 🎮 FlipRush

<div align="center">

![FlipRush Banner](assets/banner.png)

**A fast-paced gravity flip arcade game built with Flutter**

[![Flutter Version](https://img.shields.io/badge/Flutter-3.0%2B-02569B?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android-green.svg)](https://www.android.com/)

[Features](#features) • [Download](#download) • [Screenshots](#screenshots) • [Building](#building) • [Contributing](#contributing)

</div>

---

## 🌟 Features

- 🎯 **One-Tap Controls** - Simple yet challenging gravity-flip mechanics
- ⚡ **Smooth 60 FPS Gameplay** - Optimized performance for all devices
- 🛡️ **Power-Up System** - Shield, Slow-Mo, Shrink, and Double Points
- 🪙 **Coin Economy** - Collect coins to purchase power-ups mid-game
- 🎨 **Customizable Ball Skins** - Unlock unique gradient designs
- 🔊 **Dynamic Sound Effects** - Immersive audio feedback
- 📊 **High Score Tracking** - Beat your personal best
- ⚙️ **Settings** - Adjust sound effects and customize experience
- 🌈 **Visual Effects** - Particle explosions, tap ripples, and smooth animations
- 📱 **Lightweight** - Small APK size (~8MB optimized)

---

## 📸 Screenshots

<div align="center">

| Gameplay | Power-Ups | Game Over |
|----------|-----------|-----------|
| ![Gameplay](screenshots/gameplay.png) | ![Power-ups](screenshots/powerups.png) | ![Game Over](screenshots/gameover.png) |

| Start Screen | Settings | Skins |
|--------------|----------|-------|
| ![Start](screenshots/start.png) | ![Settings](screenshots/settings.png) | ![Skins](screenshots/skins.png) |

</div>

---

## 🎮 How to Play

1. **Tap anywhere** on the screen to flip gravity
2. **Dodge obstacles** by controlling the ball's vertical position
3. **Collect coins** to purchase power-ups
4. **Use power-ups** strategically to survive longer
5. **Beat your high score** and challenge yourself!

### Power-Ups

| Icon | Name | Effect | Cost |
|------|------|--------|------|
| 🛡️ | **Shield** | Protects from one collision | 10 coins |
| ⏱️ | **Slow-Mo** | Slows down time for 8 seconds | 15 coins |
| 🔽 | **Shrink** | Makes ball smaller for 8 seconds | 12 coins |
| ⭐ | **Double Points** | 2x score multiplier for 8 seconds | 20 coins |

---

## 🚀 Download

### Android
- **Latest Release**: [Download APK](https://github.com/yourusername/fliprush/releases/latest)
- **Minimum Android Version**: Android 5.0 (API 21)

*Coming soon to Google Play Store*

---

## 🛠️ Building from Source

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.0+)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/)

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/fliprush.git
   cd fliprush
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building Release APK

```bash
# Build release APK
flutter build apk --release

# Build split APKs (recommended for smaller file size)
flutter build apk --split-per-abi --release

# Output location: build/app/outputs/flutter-apk/
```

### Building for iOS (Future)

```bash
flutter build ios --release
```

---

## 📁 Project Structure

```
fliprush/
├── lib/
│   └── main.dart              # Main application code
├── assets/
│   ├── sounds/               # Sound effects
│   │   ├── flip.mp3
│   │   ├── explosion.mp3
│   │   ├── coin.mp3
│   │   ├── powerup.mp3
│   │   └── slowmo.mp3
│   └── icon.png              # App icon
├── android/                  # Android-specific files
├── docs/                     # Documentation
│   ├── OPTIMIZATION_REPORT.md
│   ├── STAND_OUT_FEATURES.md
│   └── IMPLEMENTATION_GUIDE.md
├── pubspec.yaml             # Dependencies
└── README.md               # This file
```

---

## 🔧 Configuration

### Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.2.1      # Custom typography
  audioplayers: ^6.0.0      # Sound effects

dev_dependencies:
  flutter_launcher_icons: ^0.13.1  # App icon generation
```

### Customization

- **Ball Skins**: Edit `ballSkins` list in `main.dart`
- **Obstacle Colors**: Modify `obstacleColors` list
- **Power-Up Prices**: Adjust `powerUpPrices` map
- **Game Speed**: Change `obstacleSpeed` and `velocity` values

---

## 🎨 Assets

### Required Assets

1. **Sound Effects** (place in `assets/sounds/`)
   - `flip.mp3` - Gravity flip sound
   - `explosion.mp3` - Death sound
   - `coin.mp3` - Coin collection
   - `powerup.mp3` - Power-up pickup
   - `slowmo.mp3` - Slow-mo activation

2. **App Icon**
   - `assets/icon.png` - 1024x1024px PNG

### Asset Optimization Tips

- Use OGG format for audio (smaller size)
- Compress images with TinyPNG
- Keep audio files under 100KB each

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** your changes (`git commit -m 'Add some AmazingFeature'`)
4. **Push** to the branch (`git push origin feature/AmazingFeature`)
5. **Open** a Pull Request

### Feature Ideas

- [ ] Leaderboard integration
- [ ] Combo system
- [ ] Near-miss bonus rewards
- [ ] Daily challenges
- [ ] Achievement system
- [ ] Color themes
- [ ] Ghost mode (replay best run)
- [ ] Share score functionality

See [STAND_OUT_FEATURES.md](docs/STAND_OUT_FEATURES.md) for detailed feature proposals.

---

## 🐛 Known Issues

- None currently reported

Found a bug? [Open an issue](https://github.com/yourusername/fliprush/issues/new)

---

## 📝 Changelog

### Version 1.0.7 (Latest)
- ✅ Removed background music system
- ✅ Removed ball trail effect
- ✅ Fixed coin sound (now plays on collection)
- ✅ Fixed slow-mo sound effect
- ✅ Code optimization (removed unused functions)
- ✅ Performance improvements

### Version 1.0.0
- 🎉 Initial release
- ⚡ Core gravity-flip mechanics
- 🛡️ Power-up system
- 🪙 Coin economy
- 🎨 Ball skins

See [CHANGELOG.md](CHANGELOG.md) for complete version history.

---

## 📊 Performance

- **APK Size**: ~8MB (optimized) / ~20MB (unoptimized)
- **RAM Usage**: ~60MB average
- **Frame Rate**: Solid 60 FPS on most devices
- **Battery**: Optimized for low battery consumption

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 Siddhartha Gupta

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 👤 Author

**Siddhartha Gupta**
- Student ID: 24BCE5063
- Institution: VIT Chennai
- Club: Android Club

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Google Fonts for typography
- AudioPlayers package maintainers
- Android Club at VIT Chennai

---

## 📞 Support

- 📧 **Email**: your.email@example.com
- 🐛 **Issues**: [GitHub Issues](https://github.com/yourusername/fliprush/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/yourusername/fliprush/discussions)

---

## ⭐ Star History

If you find this project useful, please consider giving it a star! ⭐

[![Star History Chart](https://api.star-history.com/svg?repos=yourusername/fliprush&type=Date)](https://star-history.com/#yourusername/fliprush&Date)

---

<div align="center">

**Made with ❤️ and Flutter**

[Back to Top](#-fliprush)

</div>

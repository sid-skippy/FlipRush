# Contributing to FlipRush

Thank you for your interest in contributing to FlipRush! 🎮

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Code Style Guidelines](#code-style-guidelines)
- [Commit Message Guidelines](#commit-message-guidelines)
- [Pull Request Process](#pull-request-process)

---

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on the best outcome for the project
- Show empathy towards other contributors

---

## Getting Started

1. **Fork** the repository
2. **Clone** your fork:
   ```bash
   git clone https://github.com/yourusername/fliprush.git
   cd fliprush
   ```
3. **Add upstream** remote:
   ```bash
   git remote add upstream https://github.com/originalauthor/fliprush.git
   ```
4. **Install dependencies**:
   ```bash
   flutter pub get
   ```
5. **Run the app**:
   ```bash
   flutter run
   ```

---

## How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in [Issues](https://github.com/yourusername/fliprush/issues)
2. If not, create a new issue with:
   - Clear title describing the bug
   - Steps to reproduce
   - Expected behavior
   - Actual behavior
   - Device/OS information
   - Screenshots if applicable

**Example:**
```markdown
**Bug**: Coin sound plays randomly

**Steps to Reproduce:**
1. Start game
2. Play for 30 seconds
3. Coin sound plays without collecting coin

**Expected**: Sound only on coin collection
**Actual**: Sound plays every 5 points

**Device**: Samsung Galaxy S21, Android 12
```

### Suggesting Features

1. Check [existing issues](https://github.com/yourusername/fliprush/issues) and [STAND_OUT_FEATURES.md](docs/STAND_OUT_FEATURES.md)
2. Create a new issue with:
   - Clear feature description
   - Use case / motivation
   - Possible implementation approach
   - Mockups or examples (if applicable)

**Example:**
```markdown
**Feature**: Combo System

**Description**: Add a combo counter that rewards consecutive dodges

**Motivation**: Increases engagement and creates flow state

**Implementation**:
- Track time between obstacle dodges
- Display floating combo text
- Apply score multiplier

See: STAND_OUT_FEATURES.md #1
```

### Improving Documentation

- Fix typos or unclear explanations
- Add examples or screenshots
- Translate to other languages
- Update outdated information

---

## Development Setup

### Prerequisites

- Flutter SDK 3.0+
- Dart SDK
- Android Studio / VS Code
- Git

### Project Structure

```
fliprush/
├── lib/
│   └── main.dart          # All game code (single file)
├── assets/
│   ├── sounds/            # Audio files
│   └── icon.png           # App icon
├── docs/                  # Documentation
├── android/               # Android config
└── pubspec.yaml          # Dependencies
```

### Running Tests

```bash
# Run unit tests
flutter test

# Run integration tests (future)
flutter drive --target=test_driver/app.dart
```

### Building

```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release --split-per-abi
```

---

## Code Style Guidelines

### Dart Style

Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style):

```dart
// Good
class GameScreen extends StatefulWidget {
  final BallSkin ballSkin;
  
  const GameScreen({Key? key, required this.ballSkin}) : super(key: key);
}

// Avoid
class gamescreen extends StatefulWidget {
  BallSkin ballSkin;
  gamescreen(this.ballSkin);
}
```

### File Organization

```dart
// 1. Imports
import 'dart:math';
import 'package:flutter/material.dart';

// 2. Constants
const double ballSize = 30.0;

// 3. Main classes
class GameScreen extends StatefulWidget { }

// 4. Helper classes
class Obstacle { }
class PowerUp { }

// 5. Enums
enum PowerUpType { shield, slowMo }
```

### Naming Conventions

- Classes: `PascalCase` (e.g., `GameScreen`, `PowerUpType`)
- Variables: `camelCase` (e.g., `ballSize`, `isGameOver`)
- Constants: `camelCase` (e.g., `obstacleSpeed`)
- Private members: `_leadingUnderscore` (e.g., `_initState`)

### Comments

```dart
// Good - Explain WHY, not WHAT
// Check near-miss to reward risky play
if (distance < 0.15 && distance > 0.08) {
  rewardPlayer();
}

// Avoid - States the obvious
// Check if distance is less than 0.15
if (distance < 0.15) {
  rewardPlayer();
}
```

### Performance

- Use `const` constructors where possible
- Avoid rebuilding widgets unnecessarily
- Use `RepaintBoundary` for complex animations
- Profile before optimizing

---

## Commit Message Guidelines

Follow [Conventional Commits](https://www.conventionalcommits.org/):

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding tests
- `chore`: Maintenance tasks

### Examples

```bash
# Good
feat(gameplay): add combo system with floating text
fix(audio): coin sound now plays only on collection
docs(readme): add installation instructions
perf(rendering): use RepaintBoundary for particle effects

# Avoid
update stuff
fixed bug
changes
```

### Writing Good Commits

```bash
# Good - Clear and specific
git commit -m "fix(audio): prevent sound overlap in power-up activation"

# Good - Breaking change
git commit -m "feat(gameplay)!: change combo multiplier from 5% to 10%

BREAKING CHANGE: Existing high scores may need adjustment"

# Avoid - Vague
git commit -m "fix bug"
git commit -m "updates"
```

---

## Pull Request Process

### Before Submitting

1. ✅ Ensure code follows style guidelines
2. ✅ Test your changes thoroughly
3. ✅ Update documentation if needed
4. ✅ Add yourself to CONTRIBUTORS.md
5. ✅ Write clear commit messages

### Creating a PR

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/combo-system
   ```

2. **Make your changes** and commit:
   ```bash
   git add .
   git commit -m "feat(gameplay): add combo system"
   ```

3. **Push to your fork**:
   ```bash
   git push origin feature/combo-system
   ```

4. **Create Pull Request** on GitHub with:
   - Clear title describing the change
   - Description of what was changed and why
   - Screenshots/GIFs for UI changes
   - Related issue number (if applicable)

### PR Template

```markdown
## Description
Add combo system that rewards consecutive obstacle dodges.

## Type of Change
- [x] New feature
- [ ] Bug fix
- [ ] Documentation update
- [ ] Performance improvement

## Testing
- [x] Tested on Android device (Samsung S21)
- [x] No performance degradation
- [x] Combo text displays correctly
- [x] Multiplier applies to score

## Screenshots
[Add screenshots showing combo system in action]

## Checklist
- [x] Code follows style guidelines
- [x] Self-review completed
- [x] Documentation updated
- [x] No new warnings

## Related Issue
Closes #15
```

### Review Process

1. Maintainer reviews your PR
2. Address any requested changes
3. Once approved, PR will be merged
4. Your contribution appears in CHANGELOG.md

---

## Feature Priority

Want to contribute but not sure what to work on? Here's our priority list:

### High Priority
1. Combo system implementation
2. Near-miss bonus system
3. Bug fixes

### Medium Priority
4. Daily challenges
5. Achievement system
6. Share score feature

### Low Priority
7. Color themes
8. Ghost mode
9. Additional power-ups

See [STAND_OUT_FEATURES.md](docs/STAND_OUT_FEATURES.md) for detailed specifications.

---

## Questions?

- 💬 Open a [Discussion](https://github.com/yourusername/fliprush/discussions)
- 📧 Email: your.email@example.com
- 🐛 Report bugs in [Issues](https://github.com/yourusername/fliprush/issues)

---

## Recognition

Contributors will be:
- Added to CONTRIBUTORS.md
- Mentioned in release notes
- Credited in the About screen (for significant contributions)

Thank you for making FlipRush better! 🚀

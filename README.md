# Breathing Orb

A minimalist breathing guide iOS app that helps users practice box breathing through a beautifully animated orb. Built with SwiftUI, this app provides a calming visual experience for meditation and stress relief.

![Breathing Orb Demo](demo.gif)

## Features

- **Visual Breathing Guide**: Smoothly expanding and contracting orb that guides your breathing
- **Box Breathing Pattern**: 4-4-4-4 rhythm (inhale, hold, exhale, hold)
- **Beautiful UI**:
  - Purple to blue gradient orb
  - Dark mode design
  - Clean, minimalist interface
- **Real-time Feedback**:
  - Clear phase indicators (Inhale, Hold Breath, Exhale, Rest)
  - Session timer
  - Haptic feedback on phase changes
- **Smooth Animations**: Fluid transitions between breathing phases

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

1. Clone the repository:
```bash
git clone https://github.com/skpokala/iOS-breathing-orb.git
```

2. Open the project in Xcode:
```bash
cd iOS-breathing-orb
open iOS-breathing-orb.xcodeproj
```

3. Select your target device/simulator and run the app (⌘ + R)

## Usage

1. Launch the app
2. Tap the "Start" button to begin a breathing session
3. Follow the orb's animation:
   - Expand as it grows (Inhale)
   - Hold when it's large (Hold Breath)
   - Contract as it shrinks (Exhale)
   - Rest when it's small (Rest)
4. Tap "Stop" to end the session

## Technical Details

- Built with SwiftUI and Combine
- Uses Core Haptics for tactile feedback
- Implements MVVM architecture
- Features smooth animations with easeInOut timing
- Supports both iPhone and iPad

## Customization

The breathing pattern timings can be adjusted in `BreathingConstants`:

```swift
struct BreathingConstants {
    static let inhaleTime: Double = 4.0
    static let holdTime: Double = 4.0
    static let exhaleTime: Double = 4.0
    // ...
}
```

## Contributing

Feel free to submit issues, fork the repository, and create pull requests for any improvements.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Inspired by box breathing techniques used by Navy SEALs
- Built with SwiftUI's powerful animation system
- Designed for clarity and ease of use

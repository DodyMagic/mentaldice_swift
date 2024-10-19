# MentalDice-Swift

## Installation

### SPM (Swift Package Manager) setup

1. From your Xcode project, tap on `File > Add Package Dependencies...`

1. Paste this URL into the search text field: `https://github.com/DodyMagic/mentaldice_swift.git`

1. Add package

### Pod setup

1. Add `source 'https://github.com/DodyMagic/mentaldice_swift.git'` on top of your Podfile

1. Add `pod 'MentalDice-Swift'` into your Podfile targets

1. Run `pod install`

## Usage

1. Add the `NSBluetoothAlwaysUsageDescription` key to your `Info.plist` if it is not already there.

1. Add `import MentalDice` to the file which is meant to receive the dice's values.

1. Set yourself as delegate: `MentalDice.shared.delegate = self`

1. Connect to the Mental Dice: `MentalDice.shared.connect()`

1. Listen to the delegate protocol:
```
extension YourClass: MentalDiceDelegate {
    func didUpdate(dice: [Die]) {
        // ...
    }

    func didDetect(color: Die.Color) {
        // ...
    }

    func didConnect() {
        // ...
    }

    func didDisconnect() {
        // ...
    }
}
```

Optional: Remove the potential extra `MentalDice.` prefixes from the generated protocol functions (`func didUpdate(dice: [Die])` instead of `func didUpdate(dice: [MentalDice.Die])` for example).

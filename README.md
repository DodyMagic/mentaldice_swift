# MentalDice-Swift

## Installation

### Pod setup

1. Add `source 'https://github.com/DodyMagic/mentaldice_swift.git'` on top of your Podfile

1. Add `pod 'MentalDice-Swift'` into your Podfile targets

1. Run `pod install`

## Usage

1. Init a list of dice variable from Mental Dice framework: `var dice = MentalDice.shared.dice`

1. Set yourself as delegate: `MentalDice.shared.delegate = self`

1. Connect to the Mental Dice: `MentalDice.shared.connect()`

1. Listen to the delegate protocol:
```
extension YourClass: MentalDiceDelegate {
    func didUpdate(dice: [Die]) {
        self.dice = dice
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

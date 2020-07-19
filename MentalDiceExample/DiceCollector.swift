//
//  DiceCollector.swift
//  MentalDiceExample
//
//  Created by Guillaume Bellut on 19/07/2020.
//  Copyright © 2020 Tulleb's Corp. All rights reserved.
//

import UIKit
import MentalDiceFramework

class DiceCollector: ObservableObject {
    @Published var dice = MentalDice.shared.dice

    init() {
        let mentalDice = MentalDice.shared
        mentalDice.delegate = self
    }
}

extension DiceCollector: MentalDiceDelegate {
    func didUpdate(dice value: [Die]) {
        dice = value
    }
}

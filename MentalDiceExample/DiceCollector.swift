//
//  DiceCollector.swift
//  MentalDiceExample
//
//  Created by Guillaume Bellut on 19/07/2020.
//  Copyright © 2020 Tulleb's Corp. All rights reserved.
//

import UIKit
import MentalDice

@MainActor
class DiceCollector: ObservableObject {
    @Published var connected = false
    @Published var dice = MentalDice.shared.dice
    @Published var detectedColor: Die.Color? {
        didSet {
            if detectedColor != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.detectedColor = nil
                }
            }
        }
    }

    init() {
        let mentalDice = MentalDice.shared
        mentalDice.delegate = self
    }

    func connect() {
        MentalDice.shared.connect()
    }

    func disconnect() {
        MentalDice.shared.disconnect()
    }
}

extension DiceCollector: @preconcurrency MentalDiceDelegate {
    func didConnect() {
        connected = true
    }

    func didDisconnect() {
        connected = false
    }

    func didUpdate(dice: [Die]) {
        self.dice = dice
    }

    func didDetect(color: Die.Color) {
        detectedColor = color
    }
}

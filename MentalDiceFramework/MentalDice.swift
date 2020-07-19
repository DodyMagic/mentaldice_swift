//
//  MentalDice.swift
//  MentalDiceFramework
//
//  Created by Guillaume Bellut on 19/07/2020.
//  Copyright © 2020 Tulleb's Corp. All rights reserved.
//

import Foundation

public class MentalDice: NSObject {

    public static let shared = MentalDice()

    private let reachability = DiceReachability.shared

    private override init() {
        print("Shared Mental Dice instance created")
    }

    public func connect() {
        reachability.connect()
    }

}

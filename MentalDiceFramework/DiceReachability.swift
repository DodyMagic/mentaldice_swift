//
//  DiceReachability.swift
//  MentalDiceFramework
//
//  Created by Guillaume Bellut on 19/07/2020.
//  Copyright © 2020 Tulleb's Corp. All rights reserved.
//

import Foundation

class DiceReachability: NSObject {

    static let shared = DiceReachability()

    private override init() {
        print("Shared Dice Reachability instance created")
    }

    func connect() {
        print("Connecting...")
    }

}

//
//  MentalDice.swift
//  MentalDiceFramework
//
//  Created by Guillaume Bellut on 19/07/2020.
//  Copyright © 2020 Tulleb's Corp. All rights reserved.
//

import Foundation

public protocol MentalDiceDelegate: class {
    func didUpdate(dice value: [Die])
}

public class MentalDice: NSObject {

    public static let shared = MentalDice()

    public weak var delegate: MentalDiceDelegate?
    public var dice = [Die(color: .white),
                       Die(color: .black),
                       Die(color: .red)]

    private let reachability = DiceReachability.shared


    private override init() {
        super.init()
        reachability.delegate = self
    }

    public func connect() {
        reachability.connect()
    }

}

extension MentalDice: DiceReachabilityDelegate {

    func didReceiveMessage(_ message: CharacteristicMessage) {
        switch message.type {
        case .read(.dices):
            for index in dice.indices {
                dice[index].update(from: message.body)
            }
            delegate?.didUpdate(dice: dice)

        default:
            break
        }
    }

}

//
//  Die.swift
//  MentalDiceFramework
//
//  Created by Guillaume Bellut on 19/07/2020.
//  Copyright © 2020 Tulleb's Corp. All rights reserved.
//

import Foundation

public struct Die: Identifiable {

    public enum Color: String, CaseIterable {
        case white = "White"
        case black = "Black"
        case red = "Red"
    }

    public enum Value: Int {
        case idle = 0
        case one = 1
        case two = 2
        case three = 3
        case four = 4
        case five = 5
        case six = 6
    }

    public let id: Color
    public var value: Value

    public var color: Color {
        return id
    }

    init(color: Color, value: Value = .idle) {
        self.id = color
        self.value = value
    }

    mutating func update(from string: String) {
        let dieValues = string.split(separator: ",").compactMap { Int($0) }

        guard dieValues.count == 3,
            let dieIndex = Color.allCases.firstIndex(of: color),
            let dieValue = Die.Value(rawValue: dieValues[dieIndex]) else {
                return
        }

        value = dieValue
    }

}

//
//  CharacteristicMessageType.swift
//  MentalDiceFramework
//
//  Created by Guillaume Bellut on 19/07/2020.
//  Copyright © 2020 Tulleb's Corp. All rights reserved.
//

import Foundation

struct CharacteristicMessage {

    enum MessageType {
        case read(Read)
        case write(Write)

        enum Read: CaseIterable {
            case dices
            case dice
            case magnet
            case battery
            case version

            var prefix: String {
                switch self {
                case .dices:
                    return "Dices="
                case .dice:
                    return "A-"
                case .magnet:
                    return "B-"
                case .battery:
                    return "Batt="
                case .version:
                    return "V="
                }
            }

            var suffix: String {
                switch self {
                case .dice,
                     .magnet:
                    return "\n"
                default:
                    return "\r\nOK\r\n"
                }
            }
        }

        enum Write: CaseIterable {
            var prefix: String {
                return ""
            }

            var suffix: String {
                return "\r\nOK\r\n"
            }
        }

        var prefix: String {
            switch self {
            case let .read(type):
                return type.prefix
            case let .write(type):
                return type.prefix
            }
        }

        var suffix: String {
            switch self {
            case let .read(type):
                return type.suffix
            case let .write(type):
                return type.suffix
            }
        }
    }

    let type: MessageType
    private let value: String

    init(type: MessageType, value: String) {
        self.type = type
        self.value = value
    }

    var body: String {
        let stringWithoutPrefix = String(value.dropFirst(type.prefix.count))
        let body = String(stringWithoutPrefix.dropLast(type.suffix.count))
        return body
    }

}


extension String {

    var messageType: CharacteristicMessage.MessageType? {
        for readMessageType in CharacteristicMessage.MessageType.Read.allCases {
            if hasPrefix(readMessageType.prefix) {
                return CharacteristicMessage.MessageType.read(readMessageType)
            }
        }

        for writeMessageType in CharacteristicMessage.MessageType.Write.allCases {
            if hasPrefix(writeMessageType.prefix) {
                return CharacteristicMessage.MessageType.write(writeMessageType)
            }
        }

        return nil
    }

}

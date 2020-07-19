//
//  BluetoothData.swift
//  MentalDiceFramework
//
//  Created by Guillaume Bellut on 19/07/2020.
//  Copyright © 2020 Tulleb's Corp. All rights reserved.
//

import Foundation
import CoreBluetooth

struct PeripheralData {
    let name: String
    let uuid: CBUUID
    let services: [ServiceData]
}

struct ServiceData {
    let uuid: CBUUID
    let characteristics: [CharacteristicData]
}

struct CharacteristicData {
    let uuid: CBUUID
}

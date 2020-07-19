//
//  BluetoothModel.swift
//  MentalDiceFramework
//
//  Created by Guillaume Bellut on 19/07/2020.
//  Copyright © 2020 Tulleb's Corp. All rights reserved.
//

import Foundation
import CoreBluetooth

struct Peripheral {
    let name: String
    let uuid: CBUUID
    let services: [Service]
}

struct Service {
    let uuid: CBUUID
    let characteristics: [Characteristic]
}

struct Characteristic {
    let uuid: CBUUID
}

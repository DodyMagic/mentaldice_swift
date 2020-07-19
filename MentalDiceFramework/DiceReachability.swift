//
//  DiceReachability.swift
//  MentalDiceFramework
//
//  Created by Guillaume Bellut on 19/07/2020.
//  Copyright © 2020 Tulleb's Corp. All rights reserved.
//

import Foundation
import CoreBluetooth

class DiceReachability: NSObject {

    static let shared = DiceReachability()

    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    let marcAntoinePeripheral: Peripheral = {
        let stateCharacteristic = Characteristic(uuid: CBUUID(string: "6e400003-b5a3-f393-e0a9-e50e24dcca9e"))
        let writeCharacteristic = Characteristic(uuid: CBUUID(string: "6e400002-b5a3-f393-e0a9-e50e24dcca9e"))
        let stateService = Service(uuid: CBUUID(string: "6e400001-b5a3-f393-e0a9-e50e24dcca9e"),
                                   characteristics: [stateCharacteristic, writeCharacteristic])
        return Peripheral(name: "MarcAntoine",
                          uuid: CBUUID(string: "8EC90001-F315-4F60-9FB8-838830DAEA50"),
                          services: [stateService])
    }()

    private override init() {
        print("Shared Dice Reachability instance created")
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func connect() {
        print("Connecting...")
    }

}

extension DiceReachability: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            print("Bluetooth is not powered on")
        } else {
            print("Central scanning for peripherals...");
            centralManager.scanForPeripherals(withServices: [],
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let name = peripheral.name,
            name == marcAntoinePeripheral.name else {
                print("Found another peripheral than Marc Antoine")
                return
        }

        print("Central did discover Marc Antoine")

        centralManager.stopScan()

        self.peripheral = peripheral
        self.peripheral!.delegate = self

        centralManager.connect(self.peripheral!, options: nil)
        print("Central connecting to Marc Antoine...")
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard peripheral == self.peripheral else {
            print("Wrong peripheral connection found")
            return
        }

        print("Connected to Marc Antoine")
        let serviceUUIDs = marcAntoinePeripheral.services.map { $0.uuid }
        peripheral.discoverServices(serviceUUIDs)
        print("Looking for Marc Antoine services...")
    }

}

extension DiceReachability: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            print("Discovered services unknown from Marc Antoine services")
            return
        }

        let stateUUIDs = marcAntoinePeripheral.services.map { $0.uuid }
        for service in services where stateUUIDs.contains(service.uuid) {
            print("Marc Antoine state service found")
            let stateCharacteristicUUIDs = marcAntoinePeripheral.services.first!.characteristics.map { $0.uuid }
            peripheral.discoverCharacteristics(stateCharacteristicUUIDs, for: service)
            print("Scanning for state service characteristics...")
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            print("Found service without characteristics")
            return
        }

        let stateCharacteristicUUIDs = marcAntoinePeripheral.services.first!.characteristics.map { $0.uuid }
        for characteristic in characteristics where stateCharacteristicUUIDs.contains(characteristic.uuid) {
            print("Found matching characteristic from state service")
        }
    }

}

//
//  DiceReachability.swift
//  MentalDiceFramework
//
//  Created by Guillaume Bellut on 19/07/2020.
//  Copyright © 2020 Tulleb's Corp. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol DiceReachabilityDelegate: class {
    func didReceiveMessage(_ message: CharacteristicMessage)
}

class DiceReachability: NSObject {

    static let shared = DiceReachability()

    weak var delegate: DiceReachabilityDelegate?

    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    private var stateCharacteristic: CBCharacteristic?
    private var writeCharacteristic: CBCharacteristic?

    static private let stateCharacteristicData = CharacteristicData(uuid: CBUUID(string: "6e400003-b5a3-f393-e0a9-e50e24dcca9e"))
    static private let writeCharacteristicData = CharacteristicData(uuid: CBUUID(string: "6e400002-b5a3-f393-e0a9-e50e24dcca9e"))
    static private let marcAntoinePeripheralData: PeripheralData = {
        let stateService = ServiceData(uuid: CBUUID(string: "6e400001-b5a3-f393-e0a9-e50e24dcca9e"),
                                       characteristics: [stateCharacteristicData, writeCharacteristicData])
        return PeripheralData(name: "MarcAntoine",
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

    private func startScanning() {
        centralManager.scanForPeripherals(withServices: [],
                                          options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }

}

extension DiceReachability: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            print("Bluetooth is not powered on")
        } else {
            print("Central scanning for peripherals...");
            startScanning()
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let name = peripheral.name,
            name == DiceReachability.marcAntoinePeripheralData.name else {
                print("Found another peripheral than Marc Antoine")
                return
        }

        print("Central did discover Marc Antoine")

        centralManager.stopScan()

        connectedPeripheral = peripheral
        connectedPeripheral!.delegate = self

        centralManager.connect(connectedPeripheral!, options: nil)
        print("Central connecting to Marc Antoine...")
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard peripheral == connectedPeripheral else {
            print("Wrong peripheral connection found")
            return
        }

        print("Connected to Marc Antoine")
        let serviceUUIDs = DiceReachability.marcAntoinePeripheralData.services.map { $0.uuid }
        peripheral.discoverServices(serviceUUIDs)
        print("Looking for Marc Antoine services...")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral == connectedPeripheral {
            connectedPeripheral = nil
            stateCharacteristic = nil
            writeCharacteristic = nil
        }

        startScanning()
    }

}

extension DiceReachability: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            print("Discovered services unknown from Marc Antoine services")
            return
        }

        let stateUUIDs = DiceReachability.marcAntoinePeripheralData.services.map { $0.uuid }
        for service in services where stateUUIDs.contains(service.uuid) {
            print("Marc Antoine state service found")
            let stateCharacteristicUUIDs = DiceReachability.marcAntoinePeripheralData.services.first!.characteristics.map { $0.uuid }
            peripheral.discoverCharacteristics(stateCharacteristicUUIDs, for: service)
            print("Scanning for state service characteristics...")
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            print("Found service without characteristics")
            return
        }

        for characteristic in characteristics {
            if characteristic.uuid == DiceReachability.stateCharacteristicData.uuid {
                stateCharacteristic = characteristic
                print("Found state characteristic")
                peripheral.readValue(for: characteristic)
                peripheral.setNotifyValue(true, for: characteristic)
                continue
            }

            if characteristic.uuid == DiceReachability.writeCharacteristicData.uuid {
                writeCharacteristic = characteristic
                print("Found write characteristic")
                peripheral.readValue(for: characteristic)
                continue
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard [stateCharacteristic, writeCharacteristic].contains(characteristic) else {
            return
        }

        guard let value = characteristic.value,
            let stringValue = String(data: value, encoding: .utf8),
            let messageType = stringValue.messageType else {
                return
        }

        delegate?.didReceiveMessage(CharacteristicMessage(type: messageType,
                                                          value: stringValue))
    }
}

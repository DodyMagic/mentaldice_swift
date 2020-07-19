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
    func didConnect()
    func didDisconnect()
    func didReceiveMessage(_ message: CharacteristicMessage)
}

class DiceReachability: NSObject {

    static let shared = DiceReachability()

    weak var delegate: DiceReachabilityDelegate?
    var shouldScan = false {
        didSet {
            if shouldScan {
                guard let state = currentCentralState,
                    state == .poweredOn else {
                        stopScanning()
                        return
                }

                startScanning()
            } else {
                stopScanning()
                disconnect()
            }
        }
    }

    private var centralManager: CBCentralManager!
    private var currentCentralState: CBManagerState?
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
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    private func startScanning() {
        centralManager.scanForPeripherals(withServices: [],
                                          options: nil)
    }

    private func stopScanning() {
        centralManager.stopScan()
    }

    private func disconnect() {
        guard let peripheral = connectedPeripheral else {
            return
        }

        if let characteristic = stateCharacteristic {
            peripheral.setNotifyValue(false, for: characteristic)
            stateCharacteristic = nil
        }

        if let characteristic = writeCharacteristic {
            peripheral.setNotifyValue(false, for: characteristic)
            writeCharacteristic = nil
        }

        centralManager.cancelPeripheralConnection(peripheral)
        connectedPeripheral = nil

        delegate?.didDisconnect()
    }
}

extension DiceReachability: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        currentCentralState = central.state
        if central.state != .poweredOn {
            disconnect()
        } else if shouldScan {
            startScanning()
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let name = peripheral.name,
            name == DiceReachability.marcAntoinePeripheralData.name else {
                return
        }

        stopScanning()

        connectedPeripheral = peripheral
        connectedPeripheral!.delegate = self

        centralManager.connect(connectedPeripheral!, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard peripheral == connectedPeripheral else {
            return
        }

        let serviceUUIDs = DiceReachability.marcAntoinePeripheralData.services.map { $0.uuid }
        peripheral.discoverServices(serviceUUIDs)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        disconnect()

        if shouldScan {
            startScanning()
        }
    }

}

extension DiceReachability: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }

        let stateUUIDs = DiceReachability.marcAntoinePeripheralData.services.map { $0.uuid }
        for service in services where stateUUIDs.contains(service.uuid) {
            let stateCharacteristicUUIDs = DiceReachability.marcAntoinePeripheralData.services.first!.characteristics.map { $0.uuid }
            peripheral.discoverCharacteristics(stateCharacteristicUUIDs, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }

        for characteristic in characteristics {
            if characteristic.uuid == DiceReachability.stateCharacteristicData.uuid {
                stateCharacteristic = characteristic
                peripheral.readValue(for: characteristic)
                peripheral.setNotifyValue(true, for: characteristic)
                continue
            }

            if characteristic.uuid == DiceReachability.writeCharacteristicData.uuid {
                writeCharacteristic = characteristic
                peripheral.readValue(for: characteristic)
                continue
            }
        }

        if stateCharacteristic != nil && writeCharacteristic != nil {
            delegate?.didConnect()
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

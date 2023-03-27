//
//  BLEProtocol.swift
//  SmartVisionLink
//
//  Created by Nick Schrock on 12/7/18.
//  Copyright © 2018 Phase 1 Engineering. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BLEProtocol: class
{
    
    /************************************
     *
     * BLE Event handlers
     *
     *************************************/
    func onBleConnecting(to device: BLEDevice)
    func onBleConnected(to device: BLEDevice)
    func onBleServicesDiscovered(of device: BLEDevice, _ services: [CBService])
    func onBleCharacteristicsDiscovered(of device: BLEDevice, _ characterstics: [CBCharacteristic])
    func onBleDescriptorDiscovered(describing characteristic: CBCharacteristic, of device: BLEDevice, _ descriptor: CBDescriptor)
    func onBleDisconnected(from device: BLEDevice)
    func onBleDataAvailable(from device: BLEDevice, _ data: Data)
    func onBleDeviceFound(_ device: BLEDevice)
    func onBleScanStarted()
    func onBleScanComplete(_ deviceList: [BLEDevice])
    func onBleScanCanceled(_ deviceList: [BLEDevice])
    func onBleConnectionFailed(_ device: BLEDevice, _ error: Error?)
    func onBleConnectionLost(_ device: BLEDevice, _ error: Error?)
    func onBleNotEnabled()
    func onBleResetting()
    func onBleUnauthorized()
    func onBleNotSupported()
    func onBleWriteComplete(_ device: BLEDevice)
    func onBleWriteFailed(_ device: BLEDevice, error: Error?)
}

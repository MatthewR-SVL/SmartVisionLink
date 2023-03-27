//
//  BLEController.swift
//  Vega
//
//  Created by Nick Schrock on 12/7/18.
//  Copyright © 2018 Phase 1 Engineering. All rights reserved.
//

import UIKit
import Foundation
import CoreBluetooth

class BLEViewController: UIViewController, BLEProtocol
{
    
    
    let ble = BLEModel.sharedBleModelInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ble.delegate = self
    }
    
    func onBleWriteComplete(_ device: BLEDevice) {
        
    }
    
    func onBleWriteFailed(_ device: BLEDevice, error: Error?) {
        
    }
    
    func onBleConnected(to device: BLEDevice) {
        
    }
    
    func onBleConnecting(to device: BLEDevice)
    {
        
    }
    
    func onBleServicesDiscovered(of device: BLEDevice, _ services: [CBService]) {
        
    }
    
    func onBleCharacteristicsDiscovered(of device: BLEDevice, _ characterstics: [CBCharacteristic]) {
        
    }
    
    func onBleDescriptorDiscovered(describing characteristic: CBCharacteristic, of device: BLEDevice, _ descriptor: CBDescriptor) {
        
    }
    
    func onBleDeviceFound(_ device: BLEDevice) {
        
    }
    
    func onBleConnectionFailed(_ device: BLEDevice, _ error: Error?) {
        
    }
    
    func onBleConnectionLost(_ device: BLEDevice, _ error: Error?) {
        
    }
    
    
    func onBleDisconnected(from device: BLEDevice)
    {
        
    }
    
    func onBleDataAvailable(from device: BLEDevice, _ data: Data)
    {
        
    }
    
    func onBleScanStarted()
    {
        
    }
    
    func onBleScanComplete(_ deviceList: [BLEDevice])
    {
        
    }
    
    func onBleScanCanceled(_ deviceList: [BLEDevice])
    {
        
    }
    
    
    func onBleNotEnabled()
    {
        
    }
    
    func onBleResetting()
    {
        
    }
    
    func onBleUnauthorized()
    {
        
    }
    
    func onBleNotSupported()
    {
        
    }
}

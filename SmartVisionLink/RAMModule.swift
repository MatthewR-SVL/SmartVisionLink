//
//  RAMModule.swift
//  SmartVisionLink
//
//  Created by Nick Schrock on 12/20/18.
//  Copyright © 2018 Phase 1 Engineering. All rights reserved.
//

import Foundation

class RAMModule: BLEDevice
{
    var macAddress: String = ""
    var commsState = SVL_STATE_IDLE
    
    init(_ device: BLEDevice)
    {
        super.init(device.cbPeripheral, device.advertisementData, device.rssi)
        
        print("Creating RAM Module RX Char: \(String(device.rxCharacteristic.debugDescription))")
        
        txCharacteristic = device.txCharacteristic
        rxCharacteristic = device.rxCharacteristic
        
        //Look for MAC address in advertising data... if it's not there use the peripheral description
        guard let mfgData = advertisementData["kCBAdvDataManufacturerData"] as? Data else{
            macAddress = device.cbPeripheral.identifier.description
            return
        }
        for i in stride(from: mfgData.count - 2, to: 1, by: -2){
            macAddress = macAddress + String(format: "%02X", mfgData[i+1]) + ":" + String(format: "%02X",mfgData[i])
            if(i != 2){
                macAddress += ":"
            }
        }
    }
    
}

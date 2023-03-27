//
//  BLEDevice.swift
//  SmartVisionLink
//
//  Created by Nick Schrock on 12/11/18.
//  Copyright © 2018 Phase 1 Engineering. All rights reserved.
//

import Foundation
import CoreBluetooth

let BLE_WRITE_TIME = 50 as Int

let BLE_DEVICE_STATE_IDLE = 0
let BLE_DEVICE_STATE_WRITING = 1

var bleDeviceState = BLE_DEVICE_STATE_IDLE

class BLEDevice
{
    
    let MAX_CHARACTERS = 20
    
    //BLE charachteristic globals
    var txCharacteristic : CBCharacteristic?
    var rxCharacteristic : CBCharacteristic?
    
    public var advertisementData: [String : Any]
    public var cbPeripheral: CBPeripheral
    public var rssi: NSNumber
    
    init(_ peripheral: CBPeripheral,_ advertisementData: [String : Any], _ rssi: NSNumber){
        self.advertisementData = advertisementData
        self.cbPeripheral = peripheral
        self.rssi = rssi
    }
    
    func onWriteComplete()
    {
        //bleDeviceState = BLE_DEVICE_STATE_IDLE
    }
    
    func onWriteFailed()
    {
        //bleDeviceState = BLE_DEVICE_STATE_IDLE
    }
    
    func sendData(_ data: Data) -> Bool
    {
        if(bleDeviceState == BLE_DEVICE_STATE_IDLE)
        {
            if(self.rxCharacteristic == nil){return false}
            bleDeviceState = BLE_DEVICE_STATE_WRITING
            //Uncomment to debug outgoing data
            /*print("BLE Data Out:\(String(data.debugDescription)) RX Char: \(String(rxCharacteristic.debugDescription))")
            print("*************************")
            for d in data{
              print("Data Out: \(String(d))")
            }*/
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(BLE_WRITE_TIME), execute:
            {
                bleDeviceState = BLE_DEVICE_STATE_IDLE
            })
            self.cbPeripheral.writeValue(data, for: self.rxCharacteristic!, type: CBCharacteristicWriteType.withResponse)
            return true
        }
        else{
            return false
        }
    }
    
    func sendData(_ data: [Data])
    {
        if(bleDeviceState == BLE_DEVICE_STATE_IDLE)
        {
            bleDeviceState = BLE_DEVICE_STATE_WRITING
            for d in data{
                while(sendData(d)){}
            }
        }
    }
    
}

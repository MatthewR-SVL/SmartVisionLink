//
//  BLEModel.swift
//  SmartVisionLink
//
//  Created by Nick Schrock on 12/7/18.
//  Copyright © 2018 Phase 1 Engineering. All rights reserved.
//

import Foundation
import CoreBluetooth

//UUID Definitions
let BLE_SERVICE_UUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
let BLE_RX_CHARACTERISTIC_UUID = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")// (Property = Read/Notify)
let BLE_TX_CHARACTERISTIC_UUID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")//(Property = Write without response)

let SCAN_STATE_IDLE = 0
let SCAN_STATE_SCANNING = 1

let BLE_SCAN_SECONDS = 3.0 as Double

class BLEModel : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, BLEProtocol {
    
    static let sharedBleModelInstance = BLEModel()
    
    //Array to hold a list of available BLE devices
    //This list gets cleared every time a new scan is started
    var bleDevices: [BLEDevice] = []
    
    //Reference to the connected device
    //This will be null if no devices are connected
    var connectedDevice: BLEDevice?
    
    //Data Fields
    var centralManager : CBCentralManager!
    var RSSIs = [NSNumber]()
    var data = NSMutableData()
    var writeData: [Int8] = []
    var characteristicValue = [CBUUID: NSData]()
    var characteristics = [String : CBCharacteristic]()
    var scanTimer = Timer()
    
    
    var scanState = SCAN_STATE_IDLE
    
    weak var delegate: BLEProtocol?
    
    init(_ delegate: BLEProtocol) {
        super.init()
        self.delegate = delegate
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    override init(){
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    /***********************************
     *
     *  BLE Protocol Implementation
     *
     ***********************************/
    
    //Event Handlers to be implemented in controller
    func onBleConnected(to device: BLEDevice) {
        delegate!.onBleConnected(to: device)
    }
    func onBleServicesDiscovered(of device: BLEDevice, _ services: [CBService]) {
        delegate!.onBleServicesDiscovered(of: device, services)
    }
    func onBleCharacteristicsDiscovered(of device: BLEDevice, _ characteristics: [CBCharacteristic]) {
        delegate!.onBleCharacteristicsDiscovered(of: device, characteristics)
    }
    func onBleDescriptorDiscovered(describing characteristic: CBCharacteristic, of device: BLEDevice, _ descriptor: CBDescriptor){
        delegate!.onBleDescriptorDiscovered(describing: characteristic, of: device, descriptor)
    }
    func onBleConnecting(to device: BLEDevice) {
        delegate!.onBleConnecting(to: device)
    }
    func onBleDisconnected(from device: BLEDevice) {
        connectedDevice = nil
        delegate!.onBleDisconnected(from: device)
    }
    func onBleScanCanceled(_ deviceList: [BLEDevice]) {
        delegate!.onBleScanCanceled(deviceList)
    }
    func onBleDataAvailable(from device: BLEDevice, _ data: Data) {
        delegate!.onBleDataAvailable(from: device, data)
    }
    func onBleScanComplete(_ deviceList: [BLEDevice]) {
        delegate!.onBleScanComplete(deviceList)
    }
    func onBleDeviceFound(_ device: BLEDevice){
        delegate!.onBleDeviceFound(device)
    }
    func onBleConnectionFailed(_ device: BLEDevice, _ error: Error?){
        connectedDevice = nil
        delegate!.onBleConnectionFailed(device, error)
    }
    func onBleConnectionLost(_ device: BLEDevice, _ error: Error?){
        connectedDevice = nil
        delegate!.onBleConnectionLost(device, error)
    }
    func onBleScanStarted() {
        delegate?.onBleScanStarted()
    }
    func onBleNotEnabled()
    {
        delegate?.onBleNotEnabled()
    }
    func onBleResetting() {
        delegate?.onBleResetting()
    }
    func onBleUnauthorized() {
        delegate?.onBleUnauthorized()
    }
    func onBleNotSupported() {
        delegate?.onBleNotSupported()
    }
    func onBleWriteComplete(_ device: BLEDevice) {
        connectedDevice?.onWriteComplete()
        delegate?.onBleWriteComplete(device)
    }
    func onBleWriteFailed(_ device: BLEDevice, error: Error?) {
        connectedDevice?.onWriteFailed()
        delegate?.onBleWriteFailed(device, error: error)
    }
    
    //Scan For BLE Devices
    /*
     Function is called to commence a search for BLE devices that are advertising
     */
    func scan(for timeout: Double)
    {
        print("BLE: Scanning for BLE Devices")
        
        //Clear peripherals array
        bleDevices = []
        
        //Clear the scan timer
        self.scanTimer.invalidate()
        
        //Call central manager scan function for BLE not allowing duplicates
        centralManager?.scanForPeripherals(withServices: [BLE_SERVICE_UUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
        scanState = SCAN_STATE_SCANNING
        //Start the scan timer with cancelBleScan as the callback
        Timer.scheduledTimer(timeInterval: timeout, target: self, selector: #selector(self.bleScanComplete), userInfo: nil, repeats: false)
        self.onBleScanStarted()
    }
    
    @objc func bleScanComplete(){
        print("BLE: Scan Complete")
        
        self.centralManager?.stopScan()
        if scanState == SCAN_STATE_SCANNING{
            scanState = SCAN_STATE_IDLE
            onBleScanComplete(bleDevices)
        }
    }
    
    
    
    //Cancel BLE Scan
    /*
     Call this when you want to stop the BLE scan
     */
    func cancelScan()
    {
        print("BLE: Stopping BLE scan")
        self.centralManager?.stopScan()
        scanState = SCAN_STATE_IDLE
        self.onBleScanCanceled(bleDevices)
    }
    
    
    //Disconnect From BLE Device
    /*
     Call this when you're done with the BLE connection
     This cancels subscriptions if there are any, or simply disconnects if not.
     didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved
     */
    func disconnect(from device: BLEDevice)
    {
        print("BLE: Disconnecting from BLE device")
        //We have a connection... terminate it
        centralManager?.cancelPeripheralConnection(device.cbPeripheral)
    }
    
    /*
     func bleDisconnect()
     {
     if(bleDevice != nil){
     print("BLE: Disconnecting from BLE device")
     //We have a connection... terminate it
     centralManager?.cancelPeripheralConnection(bleDevice!.cbPeripheral)
     }
     }
     
     
     func bleDisconnectAll() {
     centralManager.cancelPeripheralConnection(bleDevice!.cbPeripheral)
     }
     */

    func connect(to device: BLEDevice) {
        print("BLE: Attempting to Connect")
        onBleConnecting(to: device)
        centralManager?.connect(device.cbPeripheral, options: nil)
    }
    
    /*
     func bleSend(_ data: Data){
     bleDevice!.cbPeripheral.writeValue(data, for: txCharacteristic!, type: CBCharacteristicWriteType.withResponse)
     }
     */
    func send(data d: Data, to device: BLEDevice)
    {
        device.cbPeripheral.writeValue(d, for: device.txCharacteristic!, type: CBCharacteristicWriteType.withResponse)
    }
    
    func getDevice(fromPeripheral peripheral:CBPeripheral) -> BLEDevice?
    {
        var bleDevice: BLEDevice?
        for device in bleDevices{
            //Find the device that contains this peripheral
            if device.cbPeripheral.isEqual(peripheral)
            {
                bleDevice = device
            }
        }
        return bleDevice
    }
    
    
    //Restore Central Manager
    /*
     Call this to restore the central manager delegate is something went wrong
     */
    func restoreCentralManager()
    {
        print("BLE: Restoring Central Manager")
        centralManager?.delegate = self
    }
    
    //Central Manager Callbacks
    
    /*
     Invoked when the central manager discovers a device
     */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let bleDevice = BLEDevice(peripheral, advertisementData, RSSI)
        bleDevice.cbPeripheral.delegate = self
        bleDevices.append(bleDevice)
        
        print("BLE: Device Found: \(String(describing: peripheral))")
        //Notify Controller
        onBleDeviceFound(bleDevice)
    }
    
    
    /*
     Invoked when a connection is succesfully created with a peripheral.. IE when a call to connect is successful
     */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("BLE: Connection Established")
        
        //Stop scanning for devices
        centralManager?.stopScan()
        
        //Clear any data that might have been left over
        data.length = 0
        
        //Set the discovery callback
        peripheral.delegate = self
        peripheral.discoverServices([BLE_SERVICE_UUID]) //Only look for services that match the transmit UUID
        
        
        //Broadcast connection event
        connectedDevice = getDevice(fromPeripheral: peripheral)
        
        if connectedDevice != nil{
            self.onBleConnected(to: connectedDevice!)
        }
        else{
            print("BLE Error: No Connected Device 5")
        }
        
    }
    
    /*
     Invoked when the central manager fails to create a connection with a peripheral
     */
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("BLE: Connection Failed")
        if error != nil{
            print("BLE Error: \(error!.localizedDescription)")
            //Broadcast connection event
            if connectedDevice != nil{
                self.onBleConnectionFailed(connectedDevice!, error)
            }
            print("BLE Error: No Connected Device 6")
        }
    }
    
    /*
     Invoked on a disconnection event
     */
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        
        if connectedDevice != nil{
            if error != nil{
                print("BLE Error... disconnected \(error!.localizedDescription)")
                
                self.onBleConnectionLost(connectedDevice!, error)
                
            }
            else{
                print("BLE Disconnected")
                onBleDisconnected(from: connectedDevice!)
            }
        }
        else{
            print("BLE Error: No Connected Device 4")
        }
        
        
    }
    
    //CB Peripheral Callbacks
    
    /*
     Invoked when the peripherals available services are discoverd.
     Invoked when app calls discoverServices() method
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if(error != nil){
            print("Error Discovering Services: \(error!.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else{
            print("BLE: Service not available")
            return
        }
        
        for service in services{
            peripheral.discoverCharacteristics(nil, for: service)
        }
        
        print("Discovered Services: \(services)")
        
        if(connectedDevice != nil){
            onBleServicesDiscovered(of: connectedDevice!, services)
        }
        
    }
    
    /*
     Invoked when the charachteristics of a specified service are discoverd
     Called when discoverCharacteristics(_:for:) method is called. If the characteristics of the specified service match
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if(error != nil){
            print("Error Discovering Characteristics: \(error!.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else{
            print("BLE: Characteristics not Available")
            return
        }
        
        if(connectedDevice == nil){
            print("BLE Error: No Connected Device 3")
            return
        }
        
        print("BLE: Found \(characteristics.count) characteristics")
        
        var i = 0
        for characteristic in characteristics{
            print("BLE: Characteristic \(String(i))")
            if characteristic.uuid.isEqual(BLE_RX_CHARACTERISTIC_UUID){
                connectedDevice!.rxCharacteristic = characteristic
                
                
                print("BLE: Found RX Characteristic: \(connectedDevice!.rxCharacteristic!.debugDescription)")
                //peripheral.discoverDescriptors(for: connectedDevice!.rxCharacteristic!)
            }
            if(characteristic.uuid.isEqual(BLE_TX_CHARACTERISTIC_UUID)){
                connectedDevice!.txCharacteristic = characteristic
                //Subscribe to this particular characteristic
                connectedDevice!.cbPeripheral.setNotifyValue(true, for: connectedDevice!.txCharacteristic!)
                //CBPeripheralDelegate's didUpdateNotificationStateForCharacterstic method will be called
                connectedDevice!.cbPeripheral.readValue(for: connectedDevice!.txCharacteristic!)
                print("BLE: Found TX Characteristic: \(connectedDevice!.txCharacteristic!.debugDescription)")
                //peripheral.discoverDescriptors(for: connectedDevice!.txCharacteristic!)
            }
            
            i = i+1
        }
        
        if(connectedDevice != nil){
            onBleCharacteristicsDiscovered(of: connectedDevice!, characteristics)
        }
        else{
            print("BLE Error: Connected device is nil")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("BLE: Notification state updated for characteristic \(characteristic.debugDescription))")
    }
    
    /*
     After a characteristic is found, read the characteristics value by calling "readValueCharacteristic"
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if(connectedDevice == nil){
            print("BLE Error: No Connected Device 1")
            return
        }
        
        if characteristic == connectedDevice!.txCharacteristic
        {
            //Uncomment to debug data coming in
            /*print("BLE: Data Available: TX Char: \(String(describing: characteristic))")
             for d in characteristic.value!{
             print("Data In: \(String(d))")
             }*/
            if(characteristic.value != nil){
                onBleDataAvailable(from: connectedDevice!, characteristic.value!)
            }
            
        }
    }
    
    /*
     Invoked when a descriptor is found
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil{
            print("BLE Error: \(error.debugDescription)")
            return
        }
        if connectedDevice == nil{
            print("BLE Error: No Connected Device 2")
            return
        }
        var i = 0
        if((characteristic.descriptors) != nil){
            for x in characteristic.descriptors!{
                let descriptor = x as CBDescriptor
                print("Discovered Descriptor for Characteristic: \(String(describing: descriptor.description))")
                //print("RX Value \(String(describing: connectedDevice!.rxCharacteristic?.descriptors?[i].description))")
                //print("TX Value \(String(describing: connectedDevice!.txCharacteristic?.descriptors?[i].description)))")
                i = i+1
                if(connectedDevice != nil){
                    onBleDescriptorDiscovered(describing: characteristic, of: connectedDevice!, descriptor)
                }
            }
        }
        
        
        
        
    }
    
    /*
     Invoked on message send
     */
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else{
            print("BLE: WriteCharacteristicError: \(String(describing: error?.localizedDescription))")
            onBleWriteFailed(connectedDevice!, error: error)
            return
        }
        onBleWriteComplete(connectedDevice!)
    }
    
    
    /*
     Invoked on a value write event
     */
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        guard error == nil else{
            print("BLE WriteDescriptorError: \(String(describing: error?.localizedDescription))")
            return
        }
    }
    
    
    /*
     Invoked when central manager's state is updated
     */
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if #available(iOS 10.0, *) {
            switch central.state{
            case CBManagerState.poweredOff:
                onBleNotEnabled()
                break;
            case CBManagerState.poweredOn:
                break;
            case CBManagerState.resetting:
                onBleResetting()
                break;
            case CBManagerState.unauthorized:
                onBleUnauthorized()
                break;
            case CBManagerState.unknown:
                break;
            case CBManagerState.unsupported:
                onBleNotSupported()
                break;
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
}

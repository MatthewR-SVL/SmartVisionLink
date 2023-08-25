//
//  SmartVisionLinkModel.swift
//  SmartVisionLink
//
//  Created by Nick Schrock on 12/20/18.
//  Copyright © 2018 Phase 1 Engineering. All rights reserved.
//

import Foundation

let SVL_MSG_START_COM = 1 as UInt8
let SVL_MSG_END_COM = 2 as UInt8
let SVL_MSG_FLASH = 3 as UInt8
let SVL_MSG_CONFIGURATION = 4 as UInt8
let SVL_MSG_GET_DIAGNOSTICS = 5 as UInt8
let SVL_MSG_GET_SN = 6 as UInt8
let SVL_MSG_START_BOOTLOAD = 7 as UInt8
let SVL_MSG_BOOTLOAD_DATA = 8 as UInt8
let SVL_MSG_SELECT = 9 as UInt8
let SVL_MSG_DESELECT = 10 as UInt8
let SVL_MSG_SAVE = 11 as UInt8
let SVL_MSG_HEARTBEAT = 12 as UInt8
let SVL_MSG_GET_BATCH_DIAGNOSTICS = 13 as UInt8
let SVL_MSG_BATCH_CONFIG = 14 as UInt8

let SVL_MSG_ACK = 100 as UInt8
let SVL_MSG_SERNUM = 101 as UInt8
let SVL_MSG_DIAGNOSTICS = 102 as UInt8
let SVL_MSG_BATCH_DIAGNOSTICS = 103 as UInt8
let SVL_MSG_BOOTLOAD_IN = 104 as UInt8

let SVL_STATE_IDLE = 0 as UInt8
let SVL_STATE_WAITING_FOR_ACK = 1 as UInt8
let SVL_STATE_NOT_RESPONDING = 2 as UInt8
let SVL_STATE_WAITING_FOR_DIAGNOSTICS = 3 as UInt8

let SVL_MAX_LIGHTS = 6
let SVL_MAX_NAME_CHARS = 15

let SVL_BROADCAST_SN = SmartVisionSerialNumber(0xFFFFFFFF)

let DISCOVERY_PERIOD = 5 as Int
let HEARTRATE = 1.0 as Double

class SmartVisionLinkModel: SmartVisionProtocol
{
    static let sharedSmartVisionLinkModelInstance = SmartVisionLinkModel()
    
    public var dataPacket: DataPacket
    public var selectedLight: SmartVisionLight?
    public var ram: RAMModule?
    public var lights: [SmartVisionLight] = []
    var delegate: SmartVisionProtocol?
    weak var heartbeat: Timer?
    
    public var ramModules: [RAMModule] = []
    
    init()
    {
        ramModules = []
        dataPacket = DataPacket()
    }
    
    func sendMessage(_ message: SmartVisionMessage)
    {
        if(ram == nil){return}
        if ram!.commsState != SVL_STATE_WAITING_FOR_ACK
        {
            if message.header.ackId != 0
            {
                ram!.commsState = SVL_STATE_WAITING_FOR_ACK
                //We are expecting an ack for this message
                let dataPacket = DataPacket(message.toData())
                print("Sending Data ACK \(message.toData().description)")
                if !(ram!.sendData(dataPacket.packet))
                {
                    //We expect an ack so make sure this message gets sent
                    print("ACK message not sent!!!")
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(BLE_WRITE_TIME), execute:
                        {
                            print("Resending")
                            _ = self.ram!.sendData(dataPacket.packet)
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(BLE_WRITE_TIME*3), execute:
                                {
                                    let svl = SmartVisionLinkModel.sharedSmartVisionLinkModelInstance
                                    //If we still haven't got data..
                                    if(svl.selectedLight!.commsState == SVL_STATE_WAITING_FOR_ACK){
                                        print("No Response from light!")
                                        svl.ram!.commsState = SVL_STATE_IDLE
                                        svl.onLightNotResponding()
                                    }
                            })
                    })
                    
                }
            }
            else
            {
                //No ack required... just send the data and ignore the result
                //print("Sending Data \(message.toData().description)")
                _ = ram!.sendData(DataPacket(message.toData()).packet)
            }
        }
        else{
            if(message.header.ackId != 0){
                //Send the new data awaiting an ack
                print("Sending Data ACK \(message.toData().description)")
                _ = ram!.sendData(DataPacket(message.toData()).packet)
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(BLE_WRITE_TIME*3), execute:
                    {
                        let svl = SmartVisionLinkModel.sharedSmartVisionLinkModelInstance
                        //If we still haven't got data...
                        if(svl.ram!.commsState == SVL_STATE_WAITING_FOR_ACK){
                            print("No Response from light!")
                            svl.ram!.commsState = SVL_STATE_IDLE
                            svl.onLightNotResponding()
                        }
                })
            }
        }
        
    }
    
    func handleData(_ data: Data)
    {
        for byte in data
        {
            if(self.dataPacket.decode(byte: byte) == 1 && dataPacket.packet.count > 1)
            {
                if(dataPacket.testChecksum()){
                    let message = SmartVisionMessage(dataPacket.packet)
                    print("SVL Message In: \(String(message.header.id))"+" "+message.getMessageSize().description+" bytes")
                    switch(message.header.id)
                    {
                    case SVL_MSG_ACK:
                        handleAck(message)
                        break
                    case SVL_MSG_SERNUM:
                        handleSernumMessage(message)
                        break
                    case SVL_MSG_DIAGNOSTICS:
                        if(selectedLight == nil){return}
                        selectedLight!.onDiagnosticsMessage(message)
                        selectedLight!.commsState = SVL_STATE_IDLE
                        break
                    case SVL_MSG_BATCH_DIAGNOSTICS:
                        if(selectedLight == nil){return}
                        selectedLight!.onBatchDiagnosticsMessage(message)
                        selectedLight!.commsState = SVL_STATE_IDLE
                    default:
                        break
                    }
                }
                else{
                    print("SVL: Checksum Failed")
                }
                self.dataPacket.clear()
            }
        }
    }
    
    func onRamModuleFound(_ ramModule: BLEDevice) {
        ramModules.append(RAMModule(ramModule))
        delegate?.onRamModuleFound(ramModule)
    }
    
    func onLightFound(_ light: SmartVisionLight) {
        delegate?.onLightFound(light)
    }
    
    func onDiagnosticsReceived() {
        
        delegate?.onDiagnosticsReceived()
    }
    
    func onLightNotResponding()
    {
        delegate?.onLightNotResponding()
    }
    
    func handleAck(_ message: SmartVisionMessage)
    {
        if(ram == nil){return}
        ram!.commsState = SVL_STATE_IDLE
    }
    
    func toUInt16(_ msb: UInt8, _ lsb: UInt8) -> UInt16
    {
        return (( (UInt16)(msb) << 8) | ((UInt16)(lsb)))
    }
    
    func handleSernumMessage(_ message: SmartVisionMessage)
    {
        //let light = SmartVisionLight(message.header.source, SmartVisionLight.SvlModel_t(rawValue: Int(message.data[0]))!, message.data[2], message.data[1], SmartVisionLight.SvlSetpoint_t(rawValue: Int(message.data[3]))!)
        var name = ""
        
        if(message.data.count < 14 + SVL_MAX_NAME_CHARS){
            print("Not enough chars in sernum message")
            return
        }
        
        for i in 0...SVL_MAX_NAME_CHARS{
            let c = Character(UnicodeScalar(message.data[17+i]))
            print("thisChar is:")
            print(c)
            name.append(c)
            if(c == "\0"){
                print(name)
                break
            }
        }
        
        let inputCfg = SvlInputConfiguration(
            SvlInputConfiguration.SvlInputCfg_t(rawValue: Int(message.data[6])) ?? SvlInputConfiguration.SvlInputCfg_t.INPUT_ANALOG,
            SvlInputConfiguration.SvlInputCfg_t(rawValue: Int(message.data[7])) ?? SvlInputConfiguration.SvlInputCfg_t.INPUT_ANALOG,
            SvlInputConfiguration.SvlInputCfg_t(rawValue: Int(message.data[8])) ?? SvlInputConfiguration.SvlInputCfg_t.INPUT_ANALOG
        )
        /*
         (_ sn: SmartVisionSerialNumber,  _ fwMinor: UInt8, _ fwMajor: UInt8, _ spType: SvlSetpoint_t, _ nZones: UInt8, _ nCal: UInt8, _ name: String,  _ maxOverdrivePulseWidthUs: UInt16, _ maxOverdriveDutyCycle:UInt16, _ maxCurrentPercentage: UInt16, _ inputConfiguration: SvlInputConfiguration, _ model: SvlModel_t)
         */
        let light = SmartVisionLight(
            message.header.source, //sn
            message.data[1],      //fwmin
            message.data[2],    //fwmaj
            SmartVisionLight.SvlSetpoint_t(rawValue: Int(message.data[3])) ?? SmartVisionLight.SvlSetpoint_t.PWM_DIRECT, //sp_t
            message.data[4],    //nZones
            message.data[5],    //nCal
            name,               //name
            toUInt16(message.data[9], message.data[10]),   //maxPulseWidth
            toUInt16(0,message.data[11]),                   //maxDC
            toUInt16(0,message.data[12]),                   //maxCurrent
            inputCfg,                                       //Input CFG
            SmartVisionLight.SvlModel_t(rawValue: Int(message.data[0])) ?? SmartVisionLight.SvlModel_t.LXE300 //model
        )
        addLight(light)
        
//        for byte in message.data
//        {
//            print("SN Byte: "+String(byte))
//        }
    }
    
    func compareLightsBySerialNumber(light1: SmartVisionLight, light2: SmartVisionLight) -> Bool
    {
        if(light1.serialNumber.intVal < light2.serialNumber.intVal){
            return true
        }
        else{
            return false
        }
    }
    
    func addLight(_ newLight: SmartVisionLight)
    {
        var addLight = true
        
        for light in lights{
            if light.serialNumber.intVal == newLight.serialNumber.intVal{
                addLight = false
            }
        }
        lights.sort(by: compareLightsBySerialNumber)
        
        if addLight{
            lights.append(newLight)
            onLightFound(newLight)
        }
    }
    
    func selectLight(_ light: SmartVisionLight)
    {
        selectedLight = light
        let message = SmartVisionMessage(SVL_MSG_SELECT, SVL_BROADCAST_SN, false)
        var data = Data()
        data.append(light.serialNumber.lsb_1)
        data.append(light.serialNumber.lsb_2)
        data.append(light.serialNumber.lsb_3)
        data.append(light.serialNumber.msb)
        message.setData(data)
        sendMessage(message)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(BLE_WRITE_TIME), execute:
        {
            
        })
    }
    
    func sendDiscoveryMessage(_ timeout:UInt16)
    {
        var serNumList: [SmartVisionSerialNumber]
        serNumList = []
        let message = SmartVisionMessage(SVL_MSG_GET_SN, SVL_BROADCAST_SN, false)
        for _ in 0 ..< SVL_MAX_LIGHTS{
            serNumList.append(SmartVisionSerialNumber(0xFFFFFFFF))
        }
        var i=0
        for light in lights{
            if i < SVL_MAX_LIGHTS{
                serNumList[i] = light.serialNumber
            }
            i = i+1
        }

        var data = Data()
        data.append(0)
        for sn in serNumList{
            data.append(sn.lsb_1)
            data.append(sn.lsb_2)
            data.append(sn.lsb_3)
            data.append(sn.msb)
        }
    
        data.append(UInt8(timeout & 255))
        data.append(UInt8(timeout.byteSwapped & 255))
        
        message.setData(data)

        sendMessage(message)
    }
    
    func startHeartbeat()
    {
        heartbeat?.invalidate()
        heartbeat = Timer.scheduledTimer(withTimeInterval: HEARTRATE, repeats: true) { [weak self] _ in
            self?.sendHeartbeatMessage()
        }
    }
    
    func stopHeartbeat()
    {
        heartbeat?.invalidate()
    }
    
    
    func sendStartComMessage()
    {
        let message = SmartVisionMessage(SVL_MSG_START_COM, SVL_BROADCAST_SN, false)
        sendMessage(message)
        
    }
    
    func sendEndComMessage()
    {
        let message = SmartVisionMessage(SVL_MSG_END_COM, SVL_BROADCAST_SN, false)
        sendMessage(message)
    }
    
    func sendHeartbeatMessage()
    {
        let message = SmartVisionMessage(SVL_MSG_HEARTBEAT, SVL_BROADCAST_SN, false)
        sendMessage(message)
    }
    
    func saveConfiguration(_ unsave: Bool)
    {
        if(selectedLight == nil){return}
        sendMessage(selectedLight!.saveMessage(unsave))
    }
    
    func flashLight(_ nFlashes: UInt8, _ flashPeriod: UInt16)
    {
        if(selectedLight == nil){return}
        sendMessage(selectedLight!.flashMessage(nFlashes, flashPeriod, selectedLight!.maxOverdrivePulseWidthUs))
    }
    
    func getCurrentMillis() -> Int64
    {
        return Int64(NSDate().timeIntervalSince1970 * 1000)
    }
    
    func getBatchDiagnostics()
    {
        
    }
    
    func getDiagnostics()
    {
        var i = 0 as UInt8
        
        if(selectedLight == nil){return}
        
        DispatchQueue.global(qos: .background).async
        {
            let svl = SmartVisionLinkModel.sharedSmartVisionLinkModelInstance
            for zone in self.selectedLight!.zones{
                for mode in zone.modes{
                    let t = svl.getCurrentMillis()
                    while (svl.selectedLight!.commsState == SVL_STATE_WAITING_FOR_DIAGNOSTICS) {
                        if( svl.getCurrentMillis() - t) > BLE_WRITE_TIME * 2{
                            /*DispatchQueue.main.asyncAfter(deadline: .now(), execute:
                            {
                                if svl.selectedLight!.commsState == SVL_STATE_WAITING_FOR_DIAGNOSTICS{
                                    svl.selectedLight!.commsState = SVL_STATE_NOT_RESPONDING
                                    svl.onLightNotResponding()
                                }
                            })*/
                            break
                        }
                    }
                    svl.selectedLight!.commsState = SVL_STATE_WAITING_FOR_DIAGNOSTICS
                    svl.sendMessage(self.selectedLight!.getDiagnosticsMessage(i, mode.type))
                    
                }
                i = i+1
            }
            if(svl.selectedLight!.commsState != SVL_STATE_NOT_RESPONDING){
                svl.onDiagnosticsReceived()
            }
            svl.selectedLight!.commsState = SVL_STATE_IDLE
        }
    }
    
}

//
//  SmartVisionLight.swift
//  SmartVisionLink
//
//  Created by Nick Schrock on 12/20/18.
//  Copyright © 2018 Phase 1 Engineering. All rights reserved.
//

import Foundation



class SmartVisionLight: SmartVisionLightProtocol
{
    
    enum SvlLightState_t: Int
    {
        case SVL_LIGHT_OFF = 0
        case SVL_LIGHT_ON = 1
    }
    
    enum SvlModel_t: Int
    {
        case LXE300 = 0
        case SXP80 = 1
        case XR256_FIBER = 2
        case A1000 = 3
    }
    
    enum SvlSetpoint_t: Int
    {
        case IFB_LOG_SCALING = 0
        case IFB_LINEAR_SCALING = 1
        case PWM_DIRECT = 2
    }
    
    let SVL_MAX_NUM_CAL = 2 as UInt8
    let SVL_MAX_NUM_ZONES = 4 as UInt8
    
    
    var commsState: UInt8
    var lightState: SvlLightState_t
    var zones: [SmartVisionZone]
    var serialNumber: SmartVisionSerialNumber
    var fwMajor: UInt8
    var fwMinor: UInt8
    var numZones: UInt8
    var numCal: UInt8
    var selected: Bool
    var setpointMode: SvlSetpoint_t
    var model: SvlModel_t
    var name:String
    var maxOverdrivePulseWidthUs: UInt16
    var maxCurrentPercentage: UInt16
    var maxOverdriveDutyCycle: UInt16
    var inputConfiguration:SvlInputConfiguration
    
    init(_ sn: SmartVisionSerialNumber,  _ fwMinor: UInt8, _ fwMajor: UInt8, _ spType: SvlSetpoint_t, _ nZones: UInt8, _ nCal: UInt8, _ name: String,  _ maxOverdrivePulseWidthUs: UInt16, _ maxOverdriveDutyCycle:UInt16, _ maxCurrentPercentage: UInt16, _ inputConfiguration: SvlInputConfiguration, _ model: SvlModel_t)
    {
        self.serialNumber = sn
        self.fwMajor = fwMajor
        self.fwMinor = fwMinor
        self.setpointMode = spType
        self.selected = false
        self.commsState = SVL_STATE_IDLE
        self.lightState = .SVL_LIGHT_OFF
        self.numZones = nZones
        self.numCal = nCal
        self.name = name
        self.maxCurrentPercentage = maxCurrentPercentage
        self.maxOverdrivePulseWidthUs = maxOverdrivePulseWidthUs
        self.inputConfiguration = inputConfiguration
        self.maxOverdriveDutyCycle = maxOverdriveDutyCycle
        self.model = model
        print("Creating Light = "+name+"\nNum Zones = "+String(numZones)+" Num Cal = "+String(numCal)+" MaxPW = "+String(self.maxOverdrivePulseWidthUs))
        zones = []
        for i in 0..<numZones
        {
            self.zones.append(SmartVisionZone(i))
        }
    
    }
    
//    init(_ sn: SmartVisionSerialNumber, _ model: SvlModel_t, _ fwMajor: UInt8, _ fwMinor: UInt8, _ spType: SvlSetpoint_t)
//    {
//        self.serialNumber = sn
//        self.fwMajor = fwMajor
//        self.fwMinor = fwMinor
//        self.setpointMode = spType
//        self.selected = false
//        self.model = model
//        self.commsState = SVL_STATE_IDLE
//        self.lightState = .SVL_LIGHT_OFF
//
//        switch model{
//        case .LXE300:
//            numZones = 3
//            numCal = 2
//            break
//        case .SXP80:
//            fallthrough
//        case .XR256_FIBER:
//            fallthrough
//        default:
//            numZones = 1
//            numCal = 2
//            break
//        }
//
//        zones = []
//        for _ in 0..<numZones
//        {
//            self.zones.append(SmartVisionZone())
//        }
//    }
    
    func toUInt16(_ msb: UInt8, _ lsb: UInt8) -> UInt16
    {
        return (( (UInt16)(msb) << 8) | ((UInt16)(lsb)))
    }
    
    func onDiagnosticsMessage(_ message: SmartVisionMessage)
    {
        for byte in message.toData()
        {
            print("DIAG: \(String(byte))")
        }
        
        if(message.header.source.intVal == self.serialNumber.intVal)
        {
            //Todo: Verify that data array is big enough
            if(message.getMessageSize() != LIGHT_DIAGNOSTIC_MSG_LENGTH){
                return
            }
            
            var i = 0
            let zoneId = Int(message.data[i])
            print("Zone ID: "+zoneId.description)
            i = i+1
            let cal = toUInt16(message.data[i+1], message.data[i]) / 10
            print("Cal: "+cal.description)
            i = i+2
            var calMode = SmartVisionZone.SvlMode_t(rawValue: Int(message.data[i]))
            print("Mode: "+calMode.debugDescription)
            if(calMode == nil){calMode = .CONTINUOUS}
            i = i+1
            var calState = SmartVisionZone.SvlZoneState_t(rawValue: Int(message.data[i]))
            print("State: "+calState.debugDescription)
            if(calState == nil){calState = .DISABLED}
            zones[zoneId].setState(calMode!, calState!)
            zones[zoneId].setPercentage(calMode!, UInt16(cal))
            i = i+1
            var lightMode = SmartVisionZone.SvlMode_t(rawValue: Int(message.data[i]))
            print("Light Mode: "+lightMode.debugDescription)
            if(lightMode == nil){lightMode = .CONTINUOUS}
            setMode(to: lightMode!)
            i = i+1
            lightState = SvlLightState_t(rawValue: Int(message.data[i]))!
        }
    }
    
    func onBatchDiagnosticsMessage(_ message: SmartVisionMessage)
    {
        if(message.header.source.intVal == self.serialNumber.intVal)
        {
            for byte in message.toData()
            {
                print("BATCH DIAG: \(String(byte))")
            }
            print("Num Zones = "+String(numZones)+" Num Cal = "+String(numCal))
            var i = 0
            for _ in 0..<(numZones*numCal){
                let zoneId = Int(message.data[i])
               
                i = i+1
                let msgVal = toUInt16(message.data[i+1], message.data[i])
                print("Msg Val: "+String(msgVal))
                let cal = Int(round(Double(msgVal) / 10.0))
                
                i = i+2
                var calMode = SmartVisionZone.SvlMode_t(rawValue: Int(message.data[i]))
                
                if(calMode == nil){calMode = .CONTINUOUS}
                i = i+1
                var calState = SmartVisionZone.SvlZoneState_t(rawValue: Int(message.data[i]))
                
                print("Zone ID: "+zoneId.description+" Cal: "+cal.description+" State: "+calState.debugDescription+" Mode: "+calMode.debugDescription)
                
                if(calState == nil){calState = .DISABLED}
                zones[zoneId].setState(calMode!, calState!)
                zones[zoneId].setPercentage(calMode!, UInt16(cal))
                i = i+1
            }
            var lightMode = SmartVisionZone.SvlMode_t(rawValue: Int(message.data[i]))
            print("Light Mode: "+lightMode.debugDescription)
            if(lightMode == nil){lightMode = .CONTINUOUS}
            setMode(to: lightMode!)
            i = i+1
            var lightStateRawVal = message.data[i]
            print("Light State: "+lightStateRawVal.description)
            if(lightStateRawVal != 0 && lightStateRawVal != 1){lightStateRawVal = 0}
            lightState = SvlLightState_t(rawValue: Int(lightStateRawVal))!
        }
    }
    
    func saveMessage(_ unsave: Bool) -> SmartVisionMessage {
        var message: SmartVisionMessage
        var data = Data()
        data.append(0)
        if unsave{
            message = SmartVisionMessage(SVL_MSG_SAVE, serialNumber, false)
            data.append(1)
        }
        else{
            message = SmartVisionMessage(SVL_MSG_SAVE, serialNumber, true)
            data.append(0)
        }
        message.setData(data)
        return message
    }
    
    
    func flashMessage(_ nFlashes: UInt8, _ flashPeriod: UInt16, _ onTime: UInt16) -> SmartVisionMessage {
        let message = SmartVisionMessage(SVL_MSG_FLASH, serialNumber, false)
        var data = Data()
        data.append(0)
        data.append(nFlashes)
        data.append(UInt8(flashPeriod & 255))
        data.append(UInt8(flashPeriod.byteSwapped & 255))
        data.append(UInt8(onTime & 255))
        data.append(UInt8(onTime.byteSwapped & 255))
        message.setData(data)
        return message
    }
    
    func getDiagnosticsMessage(_ zoneId: UInt8, _ mode: SmartVisionZone.SvlMode_t) -> SmartVisionMessage {
        let message = SmartVisionMessage(SVL_MSG_GET_DIAGNOSTICS, serialNumber, false)
        var data = Data()
        data.append(0)
        data.append(zoneId)
        data.append(UInt8(mode.rawValue))
        message.setData(data)
        
        return message
    }
    
    func getBatchDiagnosticsMessage() -> SmartVisionMessage {
        let message = SmartVisionMessage(SVL_MSG_GET_BATCH_DIAGNOSTICS, serialNumber, false)
        var data = Data()
        data.append(0)
        message.setData(data)
        
        return message
    }
    
    func configurationMessage(_ zoneId: UInt8 , _ ackRequested: Bool) -> SmartVisionMessage {
        let message = SmartVisionMessage(SVL_MSG_CONFIGURATION, serialNumber, ackRequested)
        var data = Data()
        data.append(0)
        data.append(zoneId)
        let intensity = zones[Int(zoneId)].getPercentage() * 10
        print("Saving Intensity: "+String(intensity))
        data.append(UInt8(intensity & 255))
        data.append(UInt8(intensity.byteSwapped & 255))
        data.append(UInt8(Int(zones[Int(zoneId)].getMode().rawValue)))
        data.append(UInt8(Int(zones[Int(zoneId)].getState().rawValue)))
        message.setData(data)
        return message
    }
    
    func batchConfigurationMessage(_ ackRequested: Bool) -> SmartVisionMessage {
        let message = SmartVisionMessage(SVL_MSG_BATCH_CONFIG, serialNumber, ackRequested)
        var data = Data()
        data.append(0)
        var z = 0 as UInt8
        for zoneId in 0..<numZones{
            var i = 0 as UInt8
            for calType in 0..<numCal{
                let percentage = zones[Int(zoneId)].getPercentage(SmartVisionZone.SvlMode_t(rawValue: Int(calType)) ?? .CONTINUOUS) * 10
                print("CFG", "Percentage: "+String(percentage))
                let enabled = UInt8(zones[Int(zoneId)].getState().rawValue)
                data.append(zoneId)
                data.append(calType)
                data.append(UInt8(percentage & 255))
                data.append(UInt8(percentage.byteSwapped & 255))
                data.append(enabled)
                i = i + 1
            }
            
            if i < SVL_MAX_NUM_CAL{
                for calType in i..<SVL_MAX_NUM_CAL{
                    data.append(zoneId)
                    data.append(0)
                    data.append(0)
                    data.append(calType)
                    data.append(0)
                }
            }
            
            z = z+1
        }
        
        if z < SVL_MAX_NUM_ZONES
        {
            for zoneId in z..<SVL_MAX_NUM_ZONES{
                for calType in 0..<SVL_MAX_NUM_CAL{
                    data.append(zoneId)
                    data.append(0)
                    data.append(0)
                    data.append(calType)
                    data.append(0)
                }
            }
        }
        
        data.append(UInt8(getMode().rawValue))
        message.setData(data)
        return message
    }
    
    func setState(ofZone zoneId: Int, to state: SmartVisionZone.SvlZoneState_t)
    {
        zones[zoneId].setState(state)
    }
    
    func getState(ofZone zoneId: Int) -> SmartVisionZone.SvlZoneState_t
    {
        return zones[zoneId].getState()
    }
    
    func setPercentage(ofZone zoneId: Int, to percentage: UInt16)
    {
        zones[zoneId].setPercentage(percentage)
    }
    
    func getPercentage(ofZone zoneId: Int) -> UInt16
    {
        return zones[zoneId].getPercentage()
    }
    
    func setMode(to mode: SmartVisionZone.SvlMode_t){
        for zone in zones{
            zone.setMode(mode)
        }
    }
    
    func getMode() -> SmartVisionZone.SvlMode_t
    {
        return zones[0].mode
    }
}

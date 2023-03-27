//
//  SmartVisionZone.swift
//  SmartVisionLink
//
//  Created by Nick Schrock on 12/20/18.
//  Copyright © 2018 Phase 1 Engineering. All rights reserved.
//

import Foundation

var MAX_PERCENTAGE = 100 as Int
var MIN_PERCENTAGE = 10 as Int
let MAX_DUTY_CYCLE = 1023 as UInt16
let MIN_DUTY_CYLCE = 0 as UInt16
let MAX_CONT_DUTY_CYCLE = 297 as UInt16
let MIN_CONT_DUTY_CYCLE = 173 as UInt16
let MIN_OD_DUTY_CYCLE = 246 as UInt16
let MAX_INTENSITY = 2000 as UInt16
let MIN_INTENSITY = 173 as UInt16
let MAX_CONT_INTENSITY = 330 as UInt16
let MIN_OD_INTENSITY = 200 as UInt16



class SmartVisionZone
{
    var zoneId = 0 as UInt8
    enum SvlMode_t: Int, CaseIterable
    {
        case CONTINUOUS = 0
        case OVERDRIVE = 1
    }
    
    enum SvlZoneState_t: Int
    {
        case DISABLED = 0
        case ENABLED = 1
    }
    
    
    class SvlMode
    {
        var state: SvlZoneState_t
        var value: UInt16
        var type: SvlMode_t
        
        init(_ type: SvlMode_t, _ value: UInt16, _ state: SvlZoneState_t){
            self.state = state
            self.value = value
            self.type = type
        }
    }
    
    var modes: [SvlMode]
    var mode: SvlMode_t
    
    init(_ zoneId: UInt8)
    {
        modes = []
        for mode in SvlMode_t.allCases{
            modes.append(SvlMode(mode, 0, .DISABLED))
        }
        mode = .CONTINUOUS
        self.zoneId = zoneId
    }
    
    
    func setState(_ mode: SvlMode_t, _ state: SvlZoneState_t)
    {
        modes[mode.rawValue].state = state
    }
    
    func setState(_ state: SvlZoneState_t)
    {
        setState(mode, state)
    }
    
    func getState() -> SvlZoneState_t
    {
        return modes[mode.rawValue].state
    }
    
    func getState(_ mode: SvlMode_t) -> SvlZoneState_t
    {
        return modes[mode.rawValue].state
    }
    
    
    func setMode(_ mode: SvlMode_t){
        self.mode = mode
    }
    
    func getMode() -> SvlMode_t
    {
        return self.mode
    }
    
    func setPercentage(_ mode: SvlMode_t, _ percentage: UInt16)
    {
        modes[mode.rawValue].value = percentage
        //modes[mode.rawValue].value = percentageToIntensity(percentage)
    }
    
    func setPercentage(_ percentage: UInt16)
    {
        modes[mode.rawValue].value = percentage
        //modes[mode.rawValue].value = percentageToIntensity(percentage)
    }
    
    func getPercentage(_ mode: SvlMode_t) -> UInt16
    {
        return modes[mode.rawValue].value
        //return intensityToPercentage(modes[mode.rawValue].value)
    }
    
    func getPercentage() -> UInt16
    {
        return modes[mode.rawValue].value
        //return intensityToPercentage(modes[mode.rawValue].value)
    }
    
//    func setIntensity(_ mode: SvlMode_t, _ intensity: UInt16)
//    {
//        modes[mode.rawValue].value = intensity
//    }
//
//    func getIntensity() -> UInt16
//    {
//        return modes[mode.rawValue].value
//    }
    
    func interpolate(_ val: UInt16, _ min1: UInt16, _ max1: UInt16, _ min2: UInt16, _ max2: UInt16) -> UInt16
    {
        var v = val
        if(min2 > max2){
            return 0
        }
        else if (min1 > max1){
            return 0
        }
        if(val < min1){
            v = min1
        }
        else if(val > max1){
            v = max1
        }
        let range1 = Double(max1 - min1)
        let range2 = Double(max2 - min2)
        let range3 = Double(v - min1)
        
        if(range2 == 0 || range3 == 0 || range1 == 0){
            return min2
        }

        return UInt16(round(( (range3 * range2) / range1))) + min2
    }
    
    func percentageToIntensity(_ val: UInt16) -> UInt16
    {
        switch mode
        {
        case .OVERDRIVE:
            return interpolate(val, UInt16(MIN_PERCENTAGE), UInt16(MAX_PERCENTAGE), MIN_OD_DUTY_CYCLE, MAX_DUTY_CYCLE)
        case .CONTINUOUS:
            return interpolate(val, UInt16(MIN_PERCENTAGE), UInt16(MAX_PERCENTAGE), MIN_CONT_DUTY_CYCLE, MAX_CONT_DUTY_CYCLE)
        }
        
    }
    
    func intensityToPercentage(_ val: UInt16) -> UInt16
    {
        switch mode{
        case .OVERDRIVE:
            return interpolate(val, MIN_OD_DUTY_CYCLE, MAX_DUTY_CYCLE, UInt16(MIN_PERCENTAGE), UInt16(MAX_PERCENTAGE))
        case .CONTINUOUS:
            return interpolate(val, MIN_CONT_DUTY_CYCLE, MAX_CONT_DUTY_CYCLE, UInt16(MIN_PERCENTAGE), UInt16(MAX_PERCENTAGE))
        }
    }
}

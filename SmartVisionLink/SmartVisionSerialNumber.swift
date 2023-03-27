//
//  VegaSerialNumber.swift
//  Vega
//
//  Created by Nick Schrock on 12/10/18.
//  Copyright © 2018 Phase 1 Engineering. All rights reserved.
//

import Foundation


class SmartVisionSerialNumber
{
    var intVal: Int
    var lsb_1: UInt8
    var lsb_2: UInt8
    var lsb_3: UInt8
    var msb: UInt8
    
    init(_ intVal: Int)
    {
        self.intVal = intVal
        
        lsb_1 = UInt8(intVal & 0xFF)
        lsb_2 = UInt8( (intVal >> 8) & 0xFF)
        lsb_3 = UInt8( (intVal >> 16) & 0xFF)
        msb = UInt8( (intVal >> 24) & 0xFF)
    }
    
    init(_ d: Data)
    {
        if(d.count >= 4){
            let a = Int(d[0]) << 24
            let b = Int(d[1] & 0xFF) << 16
            let c = Int(d[2] & 0xFF) << 8
            let d = Int(d[3] & 0xFF)
            self.intVal = a | b | c | d
            
        }
        else{
            self.intVal = 0
        }
        lsb_1 = UInt8(intVal & 0xFF)
        lsb_2 = UInt8( (intVal & 0xFF00) >> 8)
        lsb_3 = UInt8( ( intVal & 0xFF0000)  >> 16)
        msb = UInt8( ( intVal & 0xFF000000)  >> 24)
    }
}

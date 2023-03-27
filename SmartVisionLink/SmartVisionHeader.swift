//
//  VegaHeader.swift
//  Vega
//
//  Created by Nick Schrock on 12/10/18.
//  Copyright © 2018 Phase 1 Engineering. All rights reserved.
//

import Foundation

let APP_SN = SmartVisionSerialNumber(0)

let HEADER_LENGTH = 11 as UInt8
let LIGHT_DIAGNOSTIC_MSG_LENGTH = HEADER_LENGTH + 10

class SmartVisionHeader
{
    
    let MIN_ACK_ID = 1 as UInt8
    let MAX_ACK_ID = 100 as UInt8
    
    
    
    var nBytes: UInt8 = 5
    var destination: SmartVisionSerialNumber
    var source: SmartVisionSerialNumber = APP_SN
    var id: UInt8 = SVL_MSG_CONFIGURATION
    var ackId: UInt8 = 0
    
    init(_ data: Data)
    {

        self.nBytes = data[0]
    
        var serNum = Data()
    
        serNum.append(data[4])
        serNum.append(data[3])
        serNum.append(data[2])
        serNum.append(data[1])
        self.source = SmartVisionSerialNumber(serNum)
    
        serNum[0] = data[8]
        serNum[1] = data[7]
        serNum[2] = data[6]
        serNum[3] = data[5]
        self.destination = SmartVisionSerialNumber(serNum)
    
        self.id = data[9]
        self.ackId = data[10]
        
    }
    
    init(_ id: UInt8, _ destination: SmartVisionSerialNumber, _ ackRequested: Bool)
    {
        self.nBytes = HEADER_LENGTH
        self.source = APP_SN
        self.destination = destination
        self.id = id
        if ackRequested{
            ackId = UInt8.random(in: MIN_ACK_ID..<MAX_ACK_ID)
        }
        else{
            ackId = 0
        }
    }
    
    func toData() -> Data
    {
        var data = Data()
        data.append(nBytes)
        data.append(source.lsb_1)
        data.append(source.lsb_2)
        data.append(source.lsb_3)
        data.append(source.msb)
        data.append(destination.lsb_1)
        data.append(destination.lsb_2)
        data.append(destination.lsb_3)
        data.append(destination.msb)
        data.append(id)
        data.append(ackId)
        return data
    }
}

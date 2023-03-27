//
//  SmartVisionMessage.swift
//  Vega
//
//  Created by Nick Schrock on 12/10/18.
//  Copyright © 2018 Phase 1 Engineering. All rights reserved.
//

import Foundation

let MAX_PACKET_SIZE = 200

class SmartVisionMessage
{
    var header: SmartVisionHeader
    var data: Data
    
    init(_ header: SmartVisionHeader)
    {
        self.header = header
        data = Data()
    }
    
    init(_ data: Data)
    {
        self.header = SmartVisionHeader(data)
        self.data = Data()
        if(data.count > HEADER_LENGTH+1 && data.count < MAX_PACKET_SIZE){
            for i in (Int)(HEADER_LENGTH)+1..<data.count{
                self.data.append(data[i])
            }
        }
    }
    
    init(_ id: UInt8, _ destination: SmartVisionSerialNumber, _ ackRequested: Bool)
    {
        self.header = SmartVisionHeader(id, destination, ackRequested)
        self.data = Data()
    }
    
    func getMessageSize() -> Int
    {
        return (Int)(HEADER_LENGTH) + data.count
    }
    
    func toData() -> Data
    {
        var data = Data()
        data.append(self.header.toData())
        data.append(self.data)
        return data
    }
    
    func setData(_ data:Data)
    {
        self.data = data
        self.header.nBytes = UInt8(getMessageSize())
    }
}

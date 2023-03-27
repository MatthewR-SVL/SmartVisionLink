//
//  DataPacket.swift
//  SmartVisionLink
//
//  Created by Nick Schrock on 12/10/18.
//  Copyright © 2018 Phase 1 Engineering. All rights reserved.
//

import Foundation


class DataPacket: NSObject
{
    let STX = 0x0F as UInt8
    let ETX = 0x04 as UInt8
    let DLE = 0x05 as UInt8
    
    var packet: Data
    var startFlag: Bool
    var escapeFlag: Bool
    var addToPacket: Bool
    var checksum: Int
    
    
    init(_ data: Data)
    {
        startFlag = false
        escapeFlag = false
        addToPacket = false
        self.checksum = 0
        
        packet = Data()
        var tempByte: UInt8
        var checksum: Int
        checksum = 0
        var packetIndex: Int
        packetIndex = 2
        
        if(data.count == 0){
            super.init()
            return
        }
        
        packet.append(STX)
        packet.append(STX)
        
        for packetCount in 0..<data.count{
            switch(data[packetCount])
            {
            case STX:
                fallthrough
            case ETX:
                fallthrough
            case DLE:
                packet.append(DLE)
                packetIndex = packetIndex + 1
                break
            default:
                break
            }
            packet.append(data[packetCount])
            checksum = checksum + (Int)(packet[packetIndex])
            packetIndex = packetIndex + 1
        }
        
        //Insert Checksum
        tempByte = (UInt8)(((~(checksum))+1)&255)
        switch(tempByte)
        {
        case STX:
            fallthrough
        case ETX:
            fallthrough
        case DLE:
            packet.append(DLE)
            packetIndex = packetIndex + 1
            break
        default:
            break
        }
        packet.append(tempByte)
        packetIndex = packetIndex + 1
        packet.append(ETX)
        packetIndex = packetIndex + 1
        
        super.init()
    }
    
    override init()
    {
        packet = Data()
        startFlag = false
        escapeFlag = false
        addToPacket = false
        checksum = 0
        super.init()
    }
    
    func testChecksum() -> Bool
    {
        let check = ((~(checksum & 255)+1)&255)
        if(check == 0){
            return true
        }
        else{
            return false
        }
    }
    
    func clear()
    {
        packet = Data()
        startFlag = false
        escapeFlag = false
        addToPacket = false
        checksum = 0
    }
    
    func decode(byte b: UInt8) -> Int
    {
        if b == DLE && !escapeFlag{
            escapeFlag = true
            startFlag = false
        }
        else if b == STX && !escapeFlag && !startFlag {
            startFlag = true
        }
        else if b == STX && !escapeFlag {
            addToPacket = true
            startFlag = false
        }
        else if b == ETX && !escapeFlag {
            startFlag = false
            return 1
        }
        else if addToPacket {
            startFlag = false
            escapeFlag = false
            self.packet.append(b)
            self.checksum = checksum + (Int)(b)
        }
        else{
            self.clear()
        }
        
        return -1
    }
}

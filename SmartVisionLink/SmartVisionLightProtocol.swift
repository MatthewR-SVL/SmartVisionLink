//
//  SmartVisionLightProtocol.swift
//  SmartVisionLink
//
//  Created by Nick Schrock on 12/20/18.
//  Copyright © 2018 Phase 1 Engineering. All rights reserved.
//

import Foundation


protocol SmartVisionLightProtocol
{
    func onDiagnosticsMessage(_ message: SmartVisionMessage)
    func onBatchDiagnosticsMessage(_ message: SmartVisionMessage)
    
    func saveMessage(_ unsave: Bool) -> SmartVisionMessage
    func flashMessage(_ nFlashes: UInt8, _ flashPeriod: UInt16, _ onTime: UInt16) -> SmartVisionMessage
    func configurationMessage(_ zoneId: UInt8 , _ ackRequested: Bool) -> SmartVisionMessage
    func getDiagnosticsMessage(_ zoneId: UInt8, _ mode: SmartVisionZone.SvlMode_t) -> SmartVisionMessage
    func getBatchDiagnosticsMessage() -> SmartVisionMessage
}

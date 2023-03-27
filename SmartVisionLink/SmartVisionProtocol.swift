//
//  SmartVisionProtocol.swift
//  SmartVisionLink
//
//  Created by Nick Schrock on 12/20/18.
//  Copyright © 2018 Phase 1 Engineering. All rights reserved.
//

import Foundation

protocol SmartVisionProtocol
{
    func onDiagnosticsReceived()
    func onLightNotResponding()
    func onRamModuleFound(_ ramModule: BLEDevice)
    func onLightFound(_ light: SmartVisionLight)
}

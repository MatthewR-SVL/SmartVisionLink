//
//  SvlInputConfiguration.swift
//  SmartVisionLink
//
//  Created by Nick Schrock on 9/9/19.
//  Copyright © 2019 Phase 1 Engineering. All rights reserved.
//

import Foundation



class SvlInputConfiguration
{
    enum SvlInputCfg_t: Int
    {
        case INPUT_ANALOG = 0
        case INPUT_PNP = 1
        case INPUT_NPN = 2
        case INPUT_LIN = 3
    }
    
    var inputWhite: SvlInputCfg_t
    var inputBlack: SvlInputCfg_t
    var inputGrey: SvlInputCfg_t
    
    init(_ inputWhite: SvlInputCfg_t, _ inputBlack: SvlInputCfg_t, _ inputGrey: SvlInputCfg_t)
    {
        self.inputWhite = inputWhite
        self.inputBlack = inputBlack
        self.inputGrey = inputGrey
    }
}


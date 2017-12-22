//
//  Commands.swift
//  TelnetKit
//
//  Created by James Power on 12/24/17.
//

import Foundation

enum Commands: Int {
    case se = 240 // end of subnegotiation parameters
    case nop // no operation
    case dm // data mark
    case brk // break
    case ip // suspend (aka: interrupt process)
    case ao // abort output
    case ayt // are you there?
    case ec // erase character
    case el // erase line
    case ga // go ahead
    case sb // subnegotiations
    case will // will you
    case wont // wont you
    case `do` // do you
    case dont // don't you
    case iac // interpret as command

    func commandName() -> String {
        switch self {
            case .se: return "se"
            case .nop: return "nop"
            case .dm: return "dm"
            case .brk: return "brk"
            case .ip: return "ip"
            case .ao: return "ao"
            case .ayt: return "ayt"
            case .ec: return "ec"
            case .el: return "el"
            case .ga: return "ga"
            case .sb: return "sb"
            case .will: return "will"
            case .wont: return "wont"
            case .`do`: return "do"
            case .dont: return "dont"
            case .iac: return "iac"
        }
    }
}

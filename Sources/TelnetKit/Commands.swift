////
////  Commands.swift
////  TelnetKit
////
////  Created by James Power on 12/24/17.


import Foundation

public typealias Byte = UInt8
public typealias Bytes = [Byte]

// Copied most of these from:
// https://github.com/TooTallNate/node-telnet/blob/master/lib/telnet.js

enum Commands: Byte {
    case se = 240 // end of subnegotiation parameters
    case nop      // no operation
    case dm       // data mark
    case brk      // break
    case ip       // suspend (aka: interrupt process)
    case ao       // abort output
    case ayt      // are you there?
    case ec       // erase character
    case el       // erase line
    case ga       // go ahead
    case sb       // subnegotiations
    case will     // will you
    case wont     // wont you
    case `do`     // do you
    case dont     // don't you
    case iac      // interpret as command
}

enum Options: Byte {
    case transmit_binary = 0    // http://tools.ietf.org/html/rfc856
    case echo                   // http://tools.ietf.org/html/rfc857
    case reconnect              // http://tools.ietf.org/html/rfc671
    case suppress_go_ahead      // http://tools.ietf.org/html/rfc858
    case amsn                   // Approx Message Size Negotiation
    // https://google.com/search?q=telnet+option+AMSN
    case status                 // http://tools.ietf.org/html/rfc859
    case timing_mark            // http://tools.ietf.org/html/rfc860
    case rcte                   // http://tools.ietf.org/html/rfc563
    // http://tools.ietf.org/html/rfc726
    case naol                   // (Negotiate) Output Line Width
    // https://google.com/search?q=telnet+option+NAOL
    // http://tools.ietf.org/html/rfc1073
    case naop                   // (Negotiate) Output Page Size
    // https://google.com/search?q=telnet+option+NAOP
    // http://tools.ietf.org/html/rfc1073
    case naocrd                 // http://tools.ietf.org/html/rfc652
    case naohts                 // http://tools.ietf.org/html/rfc653
    case naohtd                 // http://tools.ietf.org/html/rfc654
    case naoffd                 // http://tools.ietf.org/html/rfc655
    case naovts                 // http://tools.ietf.org/html/rfc656
    case naovtd                 // http://tools.ietf.org/html/rfc657
    case naolfd                 // http://tools.ietf.org/html/rfc658
    case extend_ascii           // http://tools.ietf.org/html/rfc698
    case logout                 // http://tools.ietf.org/html/rfc727
    case bm                     // http://tools.ietf.org/html/rfc735
    case det                    // http://tools.ietf.org/html/rfc732
    // http://tools.ietf.org/html/rfc1043
    case supdup                 // http://tools.ietf.org/html/rfc734
    // http://tools.ietf.org/html/rfc736
    case supdup_output          // http://tools.ietf.org/html/rfc749
    case send_location          // http://tools.ietf.org/html/rfc779
    case terminal_type          // http://tools.ietf.org/html/rfc1091
    case end_of_record          // http://tools.ietf.org/html/rfc885
    case tuid                   // http://tools.ietf.org/html/rfc927
    case outmrk                 // http://tools.ietf.org/html/rfc933
    case ttyloc                 // http://tools.ietf.org/html/rfc946
    case regime_3270            // http://tools.ietf.org/html/rfc1041
    case x3_pad                 // http://tools.ietf.org/html/rfc1053
    case naws                   // http://tools.ietf.org/html/rfc1073
    case terminal_speed         // http://tools.ietf.org/html/rfc1079
    case toggle_flow_control    // http://tools.ietf.org/html/rfc1372
    case linemode               // http://tools.ietf.org/html/rfc1184
    case x_display_location     // http://tools.ietf.org/html/rfc1096
    case environ                // http://tools.ietf.org/html/rfc1408
    case authentication         // http://tools.ietf.org/html/rfc2941
    // http://tools.ietf.org/html/rfc1416
    // http://tools.ietf.org/html/rfc2942
    // http://tools.ietf.org/html/rfc2943
    // http://tools.ietf.org/html/rfc2951
    case encrypt                // http://tools.ietf.org/html/rfc2946
    case new_environ            // http://tools.ietf.org/html/rfc1572
    case tn3270e                // http://tools.ietf.org/html/rfc2355
    case xauth                  // https://google.com/search?q=telnet+option+xauth
    case charset                // http://tools.ietf.org/html/rfc2066
    case rsp                    // http://tools.ietf.org/html/draft-barnes-telnet-rsp-opt-01
    case com_port_option        // http://tools.ietf.org/html/rfc2217
    case sle                    // http://tools.ietf.org/html/draft-rfced-exp-atmar-00
    case start_tls              // http://tools.ietf.org/html/draft-altman-telnet-starttls-02
    case kermit                 // http://tools.ietf.org/html/rfc2840
    case send_url               // http://tools.ietf.org/html/draft-croft-telnet-url-trans-00
    case forward_x              // http://tools.ietf.org/html/draft-altman-telnet-fwdx-01
    case pragma_logon = 138     // https://google.com/search?q=telnet+option+pragma_logon
    case sspi_logon = 139       // https://google.com/search?q=telnet+option+sspi_logon
    case pragma_heartbeat = 140 // https://google.com/search?q=telnet+option+pramga_heartbeat
    case exopl = 255            // http://tools.ietf.org/html/rfc861
}

struct Sub {
    static let `is` = Byte(0)
    static let send = Byte(1)
    static let info = Byte(2)
    static let variable = Byte(0)
    static let value = Byte(1)
    static let esc = Byte(2)
    static let userVariable = Byte(3)
}

// TODO: implement this harder.
// Uh, not really sure is this stuff is valid or useful at this point - I just wanted to:
// a) determine whether or not a client response ought to be interpreted as user input vs
//    client communication, and
// b) have a way to produce human readable strings from Bytes to more easily follow the
//    negotiations.
// Mainly reading: http://www.pcmicro.com/netfoss/telnet.html to see if this makes sense.
extension Array where Element == Byte {
    func isTelnetCommand() -> Bool {
        if self.count < 2 { return false }

        let first = self[0]
        let second = self[1]
        return first == Commands.iac.rawValue && second != Commands.iac.rawValue
    }

    func telnetCommandList() -> String {
        var output = ""
        for byte in self {
            // Can not quite be correct because there are overlaps between commands + option values
            // and this can not support extended options.
            if let value = Commands(rawValue: byte) {
                output.append("\(value) ")
                continue
            }
            if let value = Options(rawValue: byte) {
                output.append("\(value) ")
                continue
            }
            output.append("UNKNOWN ")
        }
        return output
    }
}

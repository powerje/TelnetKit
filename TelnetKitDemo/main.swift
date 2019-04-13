//
//  main.swift
//  TelnetKitDemo
//
//  Created by James Power on 12/22/17.
//

import Foundation
import TelnetKit

func main() {
    print("Starting server...")
    let server = TelnetServer() {
        beginEcho(client: $0)
    }
    server.serve()
}

private func beginEcho(client: TelnetClient) {
    while client.connected {
        if let input = client.readString() {
            print(input)
            if input.trimmingCharacters(in: .whitespacesAndNewlines) == "quit" {
                client.write(string: "buh bye!\n")
                client.disconnect()
            } else {
                client.write(string: input)
            }
        }
    }
}

main()

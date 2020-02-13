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
    let bytes = [Command.iac.rawValue, Command.will.rawValue, Option.echo.rawValue]
    print("bytes: \(bytes.telnetCommandList)")
    client.write(bytes: bytes)

    let response = client.readBytes()
    if let response = response {
        print("Response: \(response)")
    }

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

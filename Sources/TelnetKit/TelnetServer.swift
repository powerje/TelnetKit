import Dispatch
import Foundation
import Socket

public typealias HandleClient = (_ client: TelnetClient) -> Void

private let log = Log()

public class TelnetServer {

    let port: Int

    private let handleClient: HandleClient
    private var listenSocket: Socket?
    private let socketLockQueue = DispatchQueue(label: "com.telnetkit.Server.SocketLockQueue")

    public init(port: Int = 9000, handleClient: @escaping HandleClient) {
        self.port = port
        self.handleClient = handleClient
    }

    public func serve() {
        print("Listening on port \(port)")
        do {
            try self.listenSocket = Socket.create(family: .inet)
            guard let server = self.listenSocket else {
                log.errorMessage("Unable to unwrap socket...")
                return
            }
            try server.listen(on: self.port)
            while let client = try? server.acceptClientConnection() {
                DispatchQueue.global(qos: .background).async {
                    let connection = TelnetClient(client)
                    log.debugMessage("Client connected: \(connection.domain())")
                    self.handshake(client: connection)
                    self.handleClient(connection)
                    connection.disconnect()
                }
            }

        } catch {
            log.errorMessage("Error: \(error)")
        }

    }

    public func stop() {
        guard let listenSocket = self.listenSocket else { return }
        listenSocket.close()
    }

    private func handshake(client: TelnetClient) {
//        let bytes = [Command.iac.rawValue, Command.will.rawValue, Option.echo.rawValue]
//        print("bytes: \(bytes.telnetCommandList)")
//        client.write(bytes: bytes)

//        let bytes = Bytes(arrayLiteral: Commands.iac.rawValue, Commands.iac.rawValue, Commands.will.rawValue, Byte(24))
//        client.write(bytes: bytes)
//        let response = client.readBytes()
//        print("response: \(String(describing: response))")
    }
}

public class TelnetClient {

    fileprivate let client: Socket
    public var connected = true

    init(_ client: Socket) {
        self.client = client
    }

    public func readString() -> String? {
        guard let message = try? client.readString() else {
            log.debugMessage("Client is disconnected, report up somehow?")
            disconnect()
            return nil
        }

        return message
    }

    public func readBytes() -> Bytes? {
        var data = Data()
        guard let _ = try? client.read(into: &data) else {
            log.debugMessage("Client is disconnected, report up somehow?")
            disconnect()
            return nil
        }
        let byteArray: [UInt8] = data.map { $0 }
        return byteArray
    }

    @discardableResult public func write(string: String) -> Bool {
        let result = try? client.write(from: string)
        return result != nil
    }

    @discardableResult public func write(bytes: Bytes) -> Bool {
        let result = try? client.write(from: Data(bytes))
        return result != nil
    }

    public func disconnect() {
        // TODO: Report up that client has closed?
        client.close()
        connected = false
    }

    public func domain() -> String {
        return client.remoteHostname
//        guard let ip = client.remoteAddress else { return "not connected" }
//        return Connection.reverseDNS(ip: ip)
    }

    public func ip() -> String {
        return client.remotePath ?? "not connected"
    }

    // TODO: maybe remove this as Blue Socket's remoteHostname may cover this?
    private static func reverseDNS(ip: String) -> String {
        var results: UnsafeMutablePointer<addrinfo>? = nil
        defer {
            if let results = results {
                freeaddrinfo(results)
            }
        }
        let error = getaddrinfo(ip, nil, nil, &results)
        if (error != 0) {
            log.debugMessage("Unable to reverse ip: \(ip)")
            return ip
        }

        for addrinfo in sequence(first: results, next: { $0?.pointee.ai_next }) {
            guard let pointee = addrinfo?.pointee else {
                log.debugMessage("Unable to reverse ip: \(ip)")
                return ip
            }

            let hname = UnsafeMutablePointer<Int8>.allocate(capacity: Int(NI_MAXHOST))
            defer {
                hname.deallocate()
            }
            let error = getnameinfo(pointee.ai_addr, pointee.ai_addrlen, hname, socklen_t(NI_MAXHOST), nil, 0, 0)
            if (error != 0) {
                continue
            }
            return String(cString: hname)
        }

        return ip
    }

}

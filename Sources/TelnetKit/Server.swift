import Async
import Bits
import Dispatch
import Foundation
import TCP
import Willow

let log = Logger(logLevels: [.all], writers: [ConsoleWriter()])
public typealias HandleClient = (_ client: Client) -> Void

public class Server {
    fileprivate static let readMax = 4096

    let port: UInt16
    private let handleClient: HandleClient
    private var serverSocket: TCPSocket?

    public init(port: UInt16 = 9000, handleClient: @escaping HandleClient) {
        self.port = port
        self.handleClient = handleClient
    }

    public func serve() {
        print("Listening on port \(port)")
        do {
            // TODO: should this default to non blocking? It almost certainly should be an option.
            serverSocket = try TCPSocket(isNonBlocking: false)
            var server = try TCPServer(socket: serverSocket!)
            try server.start(port: port)
            while let client = try? server.accept() {
                guard let client = client else { continue }
                DispatchQueue.global(qos: .background).async {
                    let connection = Connection(client)
                    log.debugMessage("Client connected: \(connection.ip())")
                    self.handshake(connection: connection)
                    self.handleClient(connection)
                    connection.disconnect()
                }
            }
        } catch {
            fatalError("Server Error: \(error.localizedDescription)")
        }
    }

    public func stop() {
        guard let serverSocket = self.serverSocket else { return }
        serverSocket.close()
    }

    private func handshake(connection: Connection) {
        let client = connection.client
        let iac: Byte = 255
        let will: Byte = 253
        let tt: Byte = 24
        let bytes = Bytes(arrayLiteral: iac, will, tt)
        _ = try? client.socket.write(Data(bytes: bytes)) // [Byte] needs to be Data now
        let response = try? [UInt8](client.socket.read(max: Server.readMax))
        print("response: \(response?.telnetCommandList() ?? "no response")")
    }
}

public protocol Client {
    func read() -> String?
    @discardableResult func write(string: String) -> Bool
    var connected: Bool { get }
    func disconnect()
    func domain() -> String
    func ip() -> String
}

class Connection: Client, Hashable, Equatable {
    fileprivate let client: TCPClient
    public var connected = true

    init(_ client: TCPClient) {
        self.client = client
    }

    func read() -> String? {
        guard let data = try? client.socket.read(max: Server.readMax),
            let message = String(data: data, encoding: .utf8) else {
                log.debugMessage("Client is disconnected, report up somehow?")
                disconnect()
                return nil
        }

        guard message != "" else {
            log.debugMessage("Client is disconnected, report up somehow?")
            disconnect()
            return nil
        }

        return message
    }

    @discardableResult func write(string: String) -> Bool {
        guard let toWrite = string.data(using: .utf8) else { return false }
        let result = try? client.socket.write(toWrite)
        return result != nil
    }

    func disconnect() {
        // TODO: Report up that client has closed?
        client.close()
        connected = false
    }

    func domain() -> String {
        guard let ip = client.socket.address?.remoteAddress else { return "not connected" }
        return Connection.reverseDNS(ip: ip)
    }

    func ip() -> String {
        return client.socket.address?.remoteAddress ?? "not connected"
    }

    public var hashValue: Int {
        return String(describing: client.socket.address).hashValue
    }

    public static func == (lhs: Connection, rhs: Connection) -> Bool {
        return String(describing: lhs.client.socket.address) == String(describing: rhs.client.socket.address)
    }

    private static func reverseDNS(ip: String) -> String {
        var results: UnsafeMutablePointer<addrinfo>? = nil
        defer {
            results?.deallocate()
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

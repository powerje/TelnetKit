import Dispatch
import Foundation
import Socket
import Willow

let log = Logger(logLevels: [.all], writers: [ConsoleWriter()])
public typealias HandleClient = (_ client: Client) -> Void

public class Server {

    let port: Int
    private let handleClient: HandleClient
    private var listenSocket: Socket?
    private let socketLockQueue = DispatchQueue(label: "com.telnetkit.Server.SocketLockQueue")

//    private var serverSocket: TCPSocket?

    public init(port: Int = 9000, handleClient: @escaping HandleClient) {
        self.port = port
        self.handleClient = handleClient
    }

    public func serve() {
        print("Listening on port \(port)")
        do {
            try self.listenSocket = Socket.create(family: .inet6)
            guard let server = self.listenSocket else {
                print("Unable to unwrap socket...")
                return
            }
            try server.listen(on: self.port)
            while let client = try? server.acceptClientConnection() {
                DispatchQueue.global(qos: .background).async {
                    let connection = Connection(client)
                    log.debugMessage("Client connected: \(connection.domain())")
                    self.handshake(connection: connection)
                    self.handleClient(connection)
                    connection.disconnect()
                }
            }

        } catch {
            print("Error: \(error)")
        }

    }

    public func stop() {
        guard let listenSocket = self.listenSocket else { return }
        listenSocket.close()
    }

    private func handshake(connection: Connection) {
//        let client = connection.client
//        let iac: Byte = 255
//        let will: Byte = 253
//        let tt: Byte = 24
//        let bytes = Bytes(arrayLiteral: iac, will, tt)
//        _ = try? client.socket.write(Data(bytes: bytes)) // [Byte] needs to be Data now
//        let response = try? [UInt8](client.socket.read(max: Server.readMax))
//        print("response: \(response?.telnetCommandList() ?? "no response")")
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

class Connection: Client {
    fileprivate let client: Socket
    public var connected = true

    init(_ client: Socket) {
        self.client = client
    }

    func read() -> String? {
        guard let message = try? client.readString() else {
            log.debugMessage("Client is disconnected, report up somehow?")
            disconnect()
            return nil
        }

        return message
    }

    @discardableResult func write(string: String) -> Bool {
        let result = try? client.write(from: string)
        return result != nil
    }

    func disconnect() {
        // TODO: Report up that client has closed?
        client.close()
        connected = false
    }

    func domain() -> String {
        return client.remoteHostname
//        guard let ip = client.remoteAddress else { return "not connected" }
//        return Connection.reverseDNS(ip: ip)
    }

    func ip() -> String {
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

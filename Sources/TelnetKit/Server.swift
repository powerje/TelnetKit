import Sockets
import Willow

let log = Logger(logLevels: [.all], writers: [ConsoleWriter()])
public typealias HandleClient = (_ client: Client) -> ()

public class Server {
    let port: Int
    private let handleClient: HandleClient
    private var serverSocket: TCPInternetSocket?

    public init(port: Int = 9000, handleClient: @escaping HandleClient) {
        self.port = port
        self.handleClient = handleClient
    }

    public func serve() {
        guard let serverSocket = socket() else { fatalError("Unable to start server on port \(port)") }
        self.serverSocket = serverSocket
        listen()
    }

    public func stop() {
        guard let serverSocket = self.serverSocket else { return }
        try! serverSocket.close()
    }

    private func socket() -> TCPInternetSocket? {
        log.debugMessage("Creating socket on port \(self.port)")

        guard let serverSocket = try? TCPInternetSocket(scheme: "telnet", hostname: "0.0.0.0", port: UInt16(port)) else {
            log.debugMessage("Failed to start server!")
            return nil
        }

        try! serverSocket.bind()
        try! serverSocket.listen(max: 4096)
        log.debugMessage("Listening on port \(self.port)")

        return serverSocket
    }

    private func listen() {
        while let client = try? serverSocket?.accept() {
            guard let client = client else { continue }
            log.debugMessage("Client connected: \(client.address)")
            background {
                let connection = Connection(client)
                self.handshake(connection: connection)
                self.handleClient(connection)
                // TODO: Report that the client has been closed?
                connection.disconnect()
            }
        }
    }

    private func handshake(connection: Connection) {
        let client = connection.client
        let iac: Byte = 255
        let will: Byte = 253
        let tt: Byte = 24
        let bytes = Bytes(arrayLiteral: iac, will, tt)
        let _ = try? client.write(bytes)        
        let response = try? client.readAll()
        print("response: \(String(describing: response))")
    }

}

public protocol Client {
    func read() -> String?
    @discardableResult func write(string: String) -> Bool
    var connected: Bool { get }
    func disconnect()
}

class Connection: Client, Hashable, Equatable {
    fileprivate let client: TCPInternetSocket
    public var connected = true

    init(_ client: TCPInternetSocket) {
        self.client = client

    }

    func read() -> String? {
        guard let message = try? client.read(max: 2048).makeString() else {
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
        if let _ = try? client.write(string) { return true }
        return false
    }

    func disconnect() {
        // Report up that client has closed?
        try? client.close()
        connected = false
    }

    public var hashValue: Int {
        return String(describing: client.address).hashValue
    }

    public static func ==(lhs: Connection, rhs: Connection) -> Bool {
        return String(describing: lhs.client.address) == String(describing: rhs.client.address)
    }
}



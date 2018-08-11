:warning: Not very useful yet :warning:

# TelnetKit

Implementation of a server adhering to [RFC 854](https://tools.ietf.org/html/rfc854.html) in Swift.

## What is currently implemented:
Almost nothing! Connections can be made and are a thin layer over [Vapor Sockets](https://github.com/vapor/sockets) which does all the difficult work. The project includes a demo app which creates a server that echos the clients inputs back to them.

## Roadmap:
  - [ ] NVT
  - [ ] Pluggable module for Telnet negotiations
  - [ ] Negotiate basic options
	  - [ ] [Terminal Type](https://tools.ietf.org/html/rfc1091)
  - [ ] Symmetric view of terminals and processes

## Building
Build using the Swift Package Manager:
`swift build`

To generate the xcodeproj:
`swift package generate-xcodeproj`


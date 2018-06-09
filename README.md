# Sync Extension Test

This is a simple test project to test an idea I have for a Finder Sync Extension on MacOS. I want to store the sync status in a 
file's extended attributes. Obviously I could use some notification system or another shared database to share the sync status
between the synchronisation task and the finder extension. I like the idea of using extended attributes, as that completely
detaches the two processes, and the status is intrinsically linked to the actual file.

Unfortunately the Sync Extension gets an error 1 - Operation not permitted, because it is running in a sandbox. So far I have
not found how to give the extension the required permissions or entitlements (or even which entitlement is responsible).

## Getting Started

This is the Finder Sync Extension template that comes with XCode, togther with some code to request the extended attribute for 
each file when a badge is requested.

Additionally there is a small command like utility to test the extended attributes from a plain command line application.

### Prerequisites

This project should build with XCode 8.2 and run on macOS 10.12.6. If you have Dropbox running you need to temporarily disable
it, because otherwise the extension will not receive requestBadgeIdentifierForURL messages.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

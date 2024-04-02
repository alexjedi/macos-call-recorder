import AppKit
import SwiftUI

let delegate = AppDelegate()
NSApplication.shared.delegate = delegate
NSApplication.shared.run()
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)

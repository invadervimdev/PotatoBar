//
//  Shortcuts.swift
//
//  Let's the user select a shortcut (from the Shortcuts app) that lets them
//  handle when the work interval starts and stops.
//

import SwiftUI
import OSLog

class PBShortcuts: ObservableObject {
    @AppStorage("shortcutsScript") var shortcutsScript: String = ""
    
    private let logger = Logger(subsystem: "com.tomatoBar.shortcuts", category: "PBShortcuts")
    
    func runShortcut() {
        // Only run if the toggle is on and a shortcut has been selected
        guard !shortcutsScript.isEmpty else { return }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/shortcuts")
        process.arguments = ["run", shortcutsScript]
        
        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            logger.error("Failed to run shortcut '\(self.shortcutsScript)': \(error.localizedDescription)")
        }
    }
    
    static func fetchInstalledShortcuts() -> [String] {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/shortcuts")
        process.arguments = ["list"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                // Split output lines and filter out empty strings
                return output.components(separatedBy: .newlines)
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
            }
        } catch {
            print("Error fetching shortcuts: \(error)")
        }
        
        return []
    }
}

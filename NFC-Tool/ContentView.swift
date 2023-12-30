//
//  ContentView.swift
//  NFC-Tool
//
//  Created by Cheng Chien on 2023/12/30.
//

import SwiftUI
import Foundation

func checkIfFileOrDirectoryExists(path: String, name: String) -> Bool {
    let fileManager = FileManager.default
    let fullPath = (path as NSString).appendingPathComponent(name)
    return fileManager.fileExists(atPath: fullPath)
}

struct ContentView: View {
    @State private var uid: String = "UID will Appear Here"
    @State private var currentLogSet = 0
       @State private var logMessages: [[String]] = [[],[]]

    var body: some View {
    
        GeometryReader { geometry in
            VStack {
                // UID display
                Text("UID: \(uid)")
                    .padding()
                    .font(.system(size: 30))
                    .monospaced()
            

                // Buttons for UID actions
                Button(action: {
                    readUID()
                }) {
                    Text("Read  UID")
                        .font(.system(size: 20))
                        .monospaced()
                }

                Button(action: {
                    writeUID()
                }) {
                    Text("Write UID")
                        .font(.system(size: 20))
                        .monospaced()
                }
                
                Button("Show full logs") {
                    currentLogSet = (currentLogSet + 1) % logMessages.count
                }

                // Log display area with auto-scroll
                ScrollViewReader { scrollView in
                    ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(logMessages[currentLogSet].indices, id: \.self) { index in
                                Text(logMessages[currentLogSet][index])
                                    .font(.system(.body, design: .monospaced))
                                    .id(index) // Assign ID for each log message
                            }
                        }
                        .padding(5)
                    }
                    .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.5)
                    .border(Color.gray, width: 2)
                    .onChange(of: logMessages[currentLogSet]) { _ in
                        withAnimation {
                            scrollView.scrollTo(logMessages[currentLogSet].count - 1, anchor: .bottom)
                        }
                    }
                }
                
                Spacer() // Pushes everything up

                HStack {
                    Spacer() // Pushes text to the right
                    VStack(alignment: .leading) {
                        Text("Designed by Cheng Chien")
                        Text("cchen1999@cs.nycu.edu.tw")
                    }
                    .padding()
                }

            }
            .padding()
            .onAppear {
                performInitialSetup()
            }
        }
    }
    private func shell(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/bash"
        task.standardInput = nil
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        print("Command: ",command)
        addlog(messages: "Command: "+command, FullOnly: true)
        print("#################")
        print("# Shell message #")
        print("#################")
        print(output)
        addlog(messages: output, FullOnly: true, ShowTime: false)
        
        
        return output
    }
    
    private func addlog(messages : String, FullOnly: Bool = false, ShowTime: Bool = true) -> Void {
        var log = messages
        
        if ShowTime {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let yourDate = formatter.date(from: formatter.string(from: Date()))
            let myStringDate = formatter.string(from: yourDate!)
            log = "[" + myStringDate + "]" + "   " + messages
        }
        
        if FullOnly {
            logMessages[1].append(log)
        }
        else {
            logMessages[0].append(log)
            logMessages[1].append(log)
        }
        print(log)
    }

    private func performInitialSetup() {
        var ShellMsg = "", command = ""
        if checkIfFileOrDirectoryExists(path: "/opt", name: "homebrew") {
            if checkIfFileOrDirectoryExists(path: "/opt/homebrew/bin", name: "nfc-list") {
                
            } else {
                print("nfc-list does not exist, installing...")
                addlog(messages: "nfc-list does not exist, installing...")
                
                command = "/opt/homebrew/bin/brew install libnfc"
                ShellMsg = shell(command)
                addlog(messages: ShellMsg)
            }
        } 
        else {
            print("homebrew and nfc-list does not exist, installing...")
            addlog(messages: "homebrew and nfc-list does not exist, installing...")
            
            command = "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            ShellMsg = shell(command)
            addlog(messages: ShellMsg)
        
            command = "/opt/homebrew/bin/brew install libnfc"
            ShellMsg = shell(command)
            addlog(messages: ShellMsg)
        }
        
        let device = shell("/opt/homebrew/bin/nfc-list")
        let findDevice = /NFC\ device:.*\ /
        if let DEVICE = try! findDevice.firstMatch(in: device){
            addlog(messages: String(DEVICE.0))
        }
    }

    // Function to simulate reading UID
    private func readUID() {
        let readMessage = shell("/opt/homebrew/bin/nfc-list")
        
        let findUID = /UID.*: [0-9a-zA-Z][0-9a-zA-Z]  [0-9a-zA-Z][0-9a-zA-Z]  [0-9a-zA-Z][0-9a-zA-Z]  [0-9a-zA-Z][0-9a-zA-Z]/
        
        var log = ""
        if let UID = try! findUID.firstMatch(in: readMessage) {
            uid = String(UID.0).components(separatedBy: ":")[1].replacingOccurrences(of: "  ", with: " ")
            log = "Read UID: " + uid
        }
        else {
            uid = "Unknow UID or No card"
            log = "Read error. Unknow UID or No card"
        }
        
        addlog(messages:log)
    }

    // Function to simulate writing UID
    private func writeUID() {
        let CheckedUID = uid.replacingOccurrences(of: " ", with: "")
        print(CheckedUID)
        let findUID = /^[0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z]$/
        
        var log = ""
        if (try! findUID.firstMatch(in: CheckedUID)) != nil {
            _ = shell("/opt/homebrew/bin/nfc-mfsetuid -f " + CheckedUID)
            log = "Write UID:" + uid
        }
        else {
            uid = "Unknow UID or No card"
            log = "Write error. Unknow UID or No card"
        }
        addlog(messages:log)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

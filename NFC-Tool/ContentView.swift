//
//  ContentView.swift
//  NFC-Tool
//
//  Created by 錢承 on 2023/12/30.
//

import SwiftUI
import Foundation

func shell(_ command: String) -> String {
    let task = Process()
    let pipe = Pipe()
    
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.launchPath = "/bin/zsh"
    task.standardInput = nil
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    
    print("#################")
    print("# Shell message #")
    print("#################")
    print(output)
    
    return output
}


struct ContentView: View {
    @State private var uid: String = "UID will appear here"
    @State private var logMessages: [String] = []

    var body: some View {
    
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

            // Log display area with auto-scroll
            ScrollViewReader { scrollView in
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(logMessages.indices, id: \.self) { index in
                            Text(logMessages[index])
                                .font(.system(.body, design: .monospaced))
                                .id(index) // Assign ID for each log message
                        }
                    }
                    .padding(5)
                }
                .frame(width: 800, height: 200)
                .border(Color.gray, width: 2)
                .onChange(of: logMessages) { _ in
                    withAnimation {
                        scrollView.scrollTo(logMessages.count - 1, anchor: .bottom)
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
    
    private func addlog(messages : String) -> Void {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let yourDate = formatter.date(from: formatter.string(from: Date()))
        let myStringDate = formatter.string(from: yourDate!)
        var log = "[" + myStringDate + "]" + "   " + messages
        logMessages.append(log)
        print(log)
    }

    private func performInitialSetup() {
        // Your initial setup code here
        // For example, you could read the initial UID or log a welcome message
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
            let ShellMessage = shell("/opt/homebrew/bin/nfc-mfsetuid -f" + CheckedUID)
            log = "Write UID:" + uid
        }
        else {
            uid = "Unknow UID or No card"
            log = "Write error. Unknow UID or No card"
        }
        
        
        addlog(messages:log)
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

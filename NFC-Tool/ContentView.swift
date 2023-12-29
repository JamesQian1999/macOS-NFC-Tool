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

            // Buttons for UID actions
            Button(action: {
                readUID()
            }) {
                Text("Read UID")
            }

            Button(action: {
                writeUID()
            }) {
                Text("Write UID")
            }

            // Log display area with auto-scroll
            ScrollViewReader { scrollView in
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(logMessages.indices, id: \.self) { index in
                            Text(logMessages[index])
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

        }
        .padding()
        .onAppear {
                    performInitialSetup()
                }
    }
    

    private func performInitialSetup() {
        // Your initial setup code here
        // For example, you could read the initial UID or log a welcome message
        let device = shell("/opt/homebrew/bin/nfc-list").components(separatedBy: "\n")
        logMessages.append(device[1])
        print(device)
    }

    // Function to simulate reading UID
    private func readUID() {
        let readMessage = shell("/opt/homebrew/bin/nfc-list").components(separatedBy: "\n")
        var log = ""
        if readMessage.count <= 3 {
            uid = "Unknow UID or Empty"
            log = "Unknow UID or Empty"
        }
        else {
            uid = readMessage[5].components(separatedBy: ":")[1]
            log = "Read " + readMessage[5]
        }
                
        logMessages.append(log)
    }

    // Function to simulate writing UID
    private func writeUID() {
        let writeMessage = "Write UID: ABCD-EF12-3456-7890"
        uid = "ABCD-EF12-3456-7890"
        logMessages.append(writeMessage)
        print(writeMessage)
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

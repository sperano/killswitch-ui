//
//  ContentView.swift
//  LED NHL Killswitch
//
//  Created by Éric Spérano on 10/17/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("serverURL") private var serverURL: String = ""
    @AppStorage("serverPassword") private var serverPassword: String = ""
    @State private var showingSettings = false

    var body: some View {
        if serverURL.isEmpty || serverPassword.isEmpty {
            SetupView(serverURL: $serverURL, serverPassword: $serverPassword)
        } else {
            MainView(showingSettings: $showingSettings)
                .sheet(isPresented: $showingSettings) {
                    SetupView(serverURL: $serverURL, serverPassword: $serverPassword, isEditMode: true)
                }
        }
    }
}

struct SetupView: View {
    @Binding var serverURL: String
    @Binding var serverPassword: String
    @Environment(\.dismiss) private var dismiss

    @State private var urlInput: String = ""
    @State private var passwordInput: String = ""

    var isEditMode: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text(isEditMode ? "Settings" : "Setup Required")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(isEditMode ? "Update your server details" : "Please enter your server details to continue")
                .font(.subheadline)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                Text("Server URL")
                    .font(.headline)
                TextField("Enter server URL", text: $urlInput)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.headline)
                SecureField("Enter password", text: $passwordInput)
                    .textFieldStyle(.roundedBorder)
            }

            Button(action: {
                serverURL = urlInput
                serverPassword = passwordInput
                if isEditMode {
                    dismiss()
                }
            }) {
                Text("Save")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(urlInput.isEmpty || passwordInput.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(urlInput.isEmpty || passwordInput.isEmpty)

            if isEditMode {
                Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.secondary.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .onAppear {
            if isEditMode {
                urlInput = serverURL
                passwordInput = serverPassword
            }
        }
    }
}

struct MainView: View {
    @Binding var showingSettings: Bool
    @AppStorage("serverURL") private var serverURL: String = ""
    @AppStorage("serverPassword") private var serverPassword: String = ""

    @State private var statusText: String = "Connecting..."
    @State private var timer: Timer?
    @State private var isProcessRunning: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image("AppIconDisplay")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 240, height: 240)
                    .cornerRadius(48)

                Text(statusText)
                    .multilineTextAlignment(.center)

                Toggle("Process Status", isOn: $isProcessRunning)
                    .toggleStyle(.switch)
                    .padding(.horizontal)
                    .onChange(of: isProcessRunning) { oldValue, newValue in
                        // Only send command if user toggled (not from status update)
                        if oldValue != newValue {
                            sendCommand(start: newValue)
                        }
                    }
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .onAppear {
                fetchStatus()
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    fetchStatus()
                }
            }
            .onDisappear {
                timer?.invalidate()
            }
            .onChange(of: serverURL) { _, _ in
                fetchStatus()
            }
            .onChange(of: serverPassword) { _, _ in
                fetchStatus()
            }
        }
    }

    private func fetchStatus() {
        guard let url = URL(string: serverURL + "/status") else {
            statusText = "Invalid URL: \(serverURL)/status"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(serverPassword)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    statusText = "Error: \(error.localizedDescription)"
                    isProcessRunning = false
                    return
                }

                guard let data = data, let text = String(data: data, encoding: .utf8) else {
                    statusText = "No data received from \(url.absoluteString)"
                    isProcessRunning = false
                    return
                }
                statusText = text
                isProcessRunning = text.hasPrefix("Process is running with PID")
            }
        }.resume()
    }

    private func sendCommand(start: Bool) {
        let endpoint = start ? "/start" : "/stop"
        guard let url = URL(string: serverURL + endpoint) else {
            statusText = "Invalid URL: \(serverURL)\(endpoint)"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(serverPassword)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    statusText = "Command Error: \(error.localizedDescription)"
                    return
                }
                fetchStatus()
            }
        }.resume()
    }
}

#Preview {
    ContentView()
}

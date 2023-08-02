//
//  ContentView.swift
//  LeaTea
//
//  Created by William Ma on 8/2/23.
//

import SwiftUI
import TDLibKit

struct ContentView: View {

    @State private var showLoginView: Bool = false

    @AppStorage("FirstNameFormat", store: .leaTeaAppGroup)
    private var firstNameFormat: String = ""

    @AppStorage("LastNameFormat", store: .leaTeaAppGroup)
    private var lastNameFormat: String = ""

    @AppStorage("StatusValue")
    private var status: String = "😀"

    @State private var telegramApi: TdApi!
    @State private var telegramAuthorizationState: AuthorizationState = .authorizationStateClosed
    @State private var telegramName: String?

    @AppStorage("SetNameAgent", store: .leaTeaAppGroup)
    private var setNameAgent: String?

    @AppStorage("SetNameDate", store: .leaTeaAppGroup)
    private var setNameDate: Double?

    private static let dateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.formattingContext = .beginningOfSentence
        formatter.unitsStyle = .short
        return formatter
    }()

    var body: some View {
        Form {
            Section("Format") {
                LabeledContent("First Name") {
                    TextField("First", text: $firstNameFormat)
                        .multilineTextAlignment(.trailing)
                }
                LabeledContent("Last Name") {
                    TextField("Last", text: $lastNameFormat)
                        .multilineTextAlignment(.trailing)
                }
            }
            Section("Variables") {
                LabeledContent("Status") {
                    TextField("Status", text: $status)
                        .multilineTextAlignment(.trailing)
                }
            }
            Section("Telegram") {
                LabeledContent("API") {
                    AuthorizationStateView(authorizationState: telegramAuthorizationState)
                }
                Button {
                    Task {
                        try! await getTelegramName()
                    }
                } label: {
                    LabeledContent("Get Name") {
                        if let name = telegramName {
                            Text(name)
                        } else {
                            EmptyView()
                        }
                    }
                }
                Button {
                    Task {
                        try! await setTelegramName()
                    }
                } label: {
                    LabeledContent("Set Name") {
                        if let agent = setNameAgent, !agent.isEmpty,
                           let setNameDate {
                            Text("\(Date(timeIntervalSinceReferenceDate: setNameDate), formatter: ContentView.dateFormatter) by \(agent)")
                        } else {
                            EmptyView()
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showLoginView) {
            LoginView(api: telegramApi) { authorizationState in
                if authorizationState == .authorizationStateReady {
                    showLoginView = false

                    Task {
                        try! await telegramApi.close()
                        telegramApi = nil
                    }
                }
            }
        }
    }

    private func withTelegramApi(_ handler: (TdApi) async throws -> Void) async throws {
        telegramApi = try await TdApi(authorizationState: $telegramAuthorizationState)

        if try await telegramApi.getAuthorizationState() != .authorizationStateReady {
            showLoginView = true
            return
        }

        try await handler(telegramApi)

        try await telegramApi.close()
        telegramApi = nil
    }

    @MainActor
    private func getTelegramName() async throws {
        try await withTelegramApi { api in
            let me = try await telegramApi.getMe()
            telegramName = "\(me.firstName) \(me.lastName)"
        }
    }

    @MainActor
    private func setTelegramName() async throws {
        try await withTelegramApi { api in
            let firstName = Model
                .format(Model.parseFormatString(firstNameFormat), substitutions: ["status": status])
                .trimmingCharacters(in: .whitespaces)
            let lastName = Model
                .format(Model.parseFormatString(lastNameFormat),substitutions: ["status": status])
                .trimmingCharacters(in: .whitespaces)
            try await api.setName(firstName: firstName, lastName: lastName)

            let me = try await telegramApi.getMe()
            telegramName = "\(me.firstName) \(me.lastName)"

            setNameAgent = "app"
            setNameDate = Date().timeIntervalSinceReferenceDate
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

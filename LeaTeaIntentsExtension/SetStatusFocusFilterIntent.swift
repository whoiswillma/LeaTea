//
//  SetStatusFocusFilterIntent.swift
//  LeaTeaIntentsExtension
//
//  Created by William Ma on 8/2/23.
//

import AppIntents
import TDLibKit

struct SetStatusFocusFilterIntent: SetFocusFilterIntent {

    static var title: LocalizedStringResource = "Set Status on Telegram"

    @Parameter(title: "Status", default: "")
    var status: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "Set Status on Telegram", subtitle: "\"\(status)\"")
    }

    func perform() async throws -> some IntentResult {
        let api = try await TdApi()

        if try await api.getAuthorizationState() != .authorizationStateReady {
            return .result(value: "Log in using the app")
        }

        let firstNameFormat = UserDefaults.leaTeaAppGroup.string(forKey: "FirstNameFormat") ?? ""
        let lastNameFormat = UserDefaults.leaTeaAppGroup.string(forKey: "LastNameFormat") ?? ""

        let firstName = Model
            .format(Model.parseFormatString(firstNameFormat), substitutions: ["status": status])
            .trimmingCharacters(in: .whitespaces)
        let lastName = Model
            .format(Model.parseFormatString(lastNameFormat),substitutions: ["status": status])
            .trimmingCharacters(in: .whitespaces)
        try await api.setName(firstName: firstName, lastName: lastName)

        try await api.close()

        UserDefaults.leaTeaAppGroup.set("focus filter", forKey: "SetNameAgent")
        UserDefaults.leaTeaAppGroup.set(Date().timeIntervalSinceReferenceDate, forKey: "SetNameDate")

        return .result(value: "Status set to \"\(status)\"")
    }

}

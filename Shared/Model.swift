//
//  Model.swift
//  LeaTea
//
//  Created by William Ma on 8/2/23.
//

import Foundation
import SwiftUI
import TDLibKit

enum FormatToken: Codable {
    case literal(String)
    case variable(String)
}

class Model {

    static func parseFormatString(_ formatString: String) -> [FormatToken] {
        formatString.split(separator: " ").map { substring in
            if substring.starts(with: "$") {
                return .variable(String(substring[substring.index(after: substring.startIndex)...]))
            } else {
                return .literal(String(substring))
            }
        }
    }

    static func format(_ tokens: [FormatToken], substitutions: [String: String]) -> String {
        tokens.map { token in
            switch token {
            case .literal(let literal): return literal
            case .variable(let variable): return substitutions[variable] ?? ""
            }
        }.joined(separator: " ")
    }

}

extension UserDefaults {
    static let leaTeaAppGroup = UserDefaults(suiteName: "group.dev.williamma.LeaTeaAppGroup") ?? .standard
}

extension TdApi {

    func setLeaTeaParameters() async throws {
        var systemInfo = utsname()
        uname(&systemInfo)
        let deviceModel = withUnsafePointer(to: &systemInfo.machine) { ptr in
            ptr.withMemoryRebound(to: CChar.self, capacity: 1) { ptr in
                String(validatingUTF8: ptr)
            }
        }

        let documentsDirectory = FileManager
            .default
            .containerURL(
                forSecurityApplicationGroupIdentifier: "group.dev.williamma.LeaTeaAppGroup"
            )!

        try await setTdlibParameters(
            apiHash: "0f3d9ec838a06e31327c3a6d9a3a7e86",
            apiId: 29332980,
            applicationVersion: "1.0",
            databaseDirectory: documentsDirectory.appending(path: "tdlib").path(),
            databaseEncryptionKey: nil,
            deviceModel: deviceModel,
            enableStorageOptimizer: false,
            filesDirectory: nil,
            ignoreFileNames: false,
            systemLanguageCode: Locale.current.identifier,
            systemVersion: nil,
            useChatInfoDatabase: false,
            useFileDatabase: false,
            useMessageDatabase: false,
            useSecretChats: false,
            useTestDc: false
        )
    }

    convenience init(authorizationState: Binding<AuthorizationState>? = nil) async throws {
        self.init(client: TdClientImpl())

        client.run { [weak self] result in
            guard let self,
                  let json = try? JSONSerialization.jsonObject(with: result, options:[]),
                  let dictionary = json as? [String: Any],
                  let type = dictionary["@type"] as? String else {
                return
            }

            switch type {
            case "updateAuthorizationState":
                if let data = try? JSONSerialization.data(withJSONObject: dictionary["authorization_state"] as Any),
                   let value = try? decoder.decode(AuthorizationState.self, from: data) {
                    authorizationState?.wrappedValue = value
                }
            default:
                break
            }
        }

        if try await getAuthorizationState() == .authorizationStateWaitTdlibParameters {
            try await setLeaTeaParameters()
        }
    }

}

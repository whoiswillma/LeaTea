//
//  LoginView.swift
//  LeaTea
//
//  Created by William Ma on 8/2/23.
//

import SwiftUI
import TDLibKit

struct LoginView: View {

    let api: TdApi
    let handler: (AuthorizationState) -> Void

    @State private var authorizationState: AuthorizationState?

    @State private var phoneNumber: String = ""
    @State private var code: String = ""
    @State private var password: String = ""

    var body: some View {
        NavigationStack {
            switch authorizationState {
            case nil:
                Text("Updating authorization state")
                    .onAppear {
                        Task {
                            try! await updateAuthorizationState()
                        }
                    }

            case .authorizationStateWaitTdlibParameters:
                Form {
                    Text("Setting Tdlib Parameters")
                        .onAppear {
                            Task {
                                try! await api.setLeaTeaParameters()
                                try! await updateAuthorizationState()
                            }
                        }
                }

            case .authorizationStateWaitPhoneNumber:
                Form {
                    TextField("Phone Number", text: $phoneNumber)
                        .onSubmit {
                            Task {
                                try! await api.setAuthenticationPhoneNumber(phoneNumber: phoneNumber, settings: nil)
                                try! await updateAuthorizationState()
                            }
                        }
                }

            case .authorizationStateWaitCode:
                Form {
                    TextField("Authentication Code", text: $code)
                        .onSubmit {
                            Task {
                                try! await api.checkAuthenticationCode(code: code)
                                try! await updateAuthorizationState()
                            }
                        }
                }

            case .authorizationStateWaitPassword:
                Form {
                    SecureField("Password", text: $password)
                        .onSubmit {
                            Task {
                                try! await api.checkAuthenticationPassword(password: password)
                                try! await updateAuthorizationState()
                            }
                        }
                }

            default:
                Text(String(describing: authorizationState))
            }
        }
    }

    private func updateAuthorizationState() async throws {
        authorizationState = try await api.getAuthorizationState()
        handler(authorizationState!)
    }
    
}

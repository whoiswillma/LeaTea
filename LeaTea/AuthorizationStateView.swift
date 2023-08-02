//
//  AuthorizationStateView.swift
//  LeaTea
//
//  Created by William Ma on 8/2/23.
//

import SwiftUI
import TDLibKit

struct AuthorizationStateView: View {

    let authorizationState: AuthorizationState

    var body: some View {
        switch authorizationState {
        case .authorizationStateWaitTdlibParameters:
            Text("Wait TdLib Parameters")
        case .authorizationStateWaitPhoneNumber:
            Text("Wait Phone Number")
        case .authorizationStateWaitEmailAddress:
            Text("Wait Email Address")
        case .authorizationStateWaitEmailCode:
            Text("Wait Email Code")
        case .authorizationStateWaitCode:
            Text("Wait Code")
        case .authorizationStateWaitOtherDeviceConfirmation:
            Text("Wait Other Device Confirmation")
        case .authorizationStateWaitRegistration:
            Text("Wait Registration")
        case .authorizationStateWaitPassword:
            Text("Wait Password")
        case .authorizationStateReady:
            Text("Ready")
        case .authorizationStateLoggingOut:
            Text("Logging Out")
        case .authorizationStateClosing:
            Text("Closing")
        case .authorizationStateClosed:
            Text("Closed")
        }
    }
}

struct AuthorizationStateView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorizationStateView(authorizationState: .authorizationStateReady)
    }
}

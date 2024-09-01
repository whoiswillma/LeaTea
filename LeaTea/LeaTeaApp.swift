//
//  LeaTeaApp.swift
//  LeaTea
//
//  Created by William Ma on 8/2/23.
//

import SwiftUI
import TDLibKit

@main
struct LeaTeaApp: App {

    enum AppState {
        case loading
        case login
        case main
    }

    @State var api: TdApi?
    @State var state: AppState = .loading

    var body: some Scene {
        WindowGroup {
            switch state {
            case .loading:
                ProgressView()
                    .task {
                        api = try! await TdApi()

                        if try! await api!.getAuthorizationState() == .authorizationStateReady {
                            try! await api!.close()
                            api = nil

                            state = .main
                        } else {
                            state = .login
                        }
                    }

            case .login:
                LoginView(api: api!) { authorizationState in
                    if authorizationState == .authorizationStateReady {
                        Task {
                            try! await api!.close()
                            api = nil

                            state = .main
                        }
                    }
                }

            case .main:
                NavigationStack {
                    ContentView()
                        .navigationTitle("Lea Tea")
                }
            }
        }
    }

}

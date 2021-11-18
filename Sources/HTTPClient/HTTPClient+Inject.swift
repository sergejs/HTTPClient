//
//  HTTPClient+Inject.swift
//  
//
//  Created by Sergejs Smirnovs on 17.11.21.
//

import Foundation
import ServiceContainer

private struct HTTPClientKey: InjectionKey {
    static var currentValue: HTTPClientRequestDispatcher = HTTPClient(session: URLSession.shared)
}

public extension InjectedValues {
    var httpClient: HTTPClientRequestDispatcher {
        get { Self[HTTPClientKey.self] }
        set { Self[HTTPClientKey.self] = newValue }
    }
}

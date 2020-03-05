//
// Created by Mykhailo Bondarenko on 05.03.2020.
//

import Foundation
import Vapor

struct LoginContext: Encodable {
    let title: String = "Log In"
    let loginError: Bool

    init(loginError: Bool = false) {
        self.loginError = loginError
    }
}

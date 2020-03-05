//
// Created by Mykhailo Bondarenko on 05.03.2020.
//

import Foundation
import Vapor

struct RegisterContext: Encodable {
    let title: String = "Register"
    let message: String?

    init(message: String? = nil) {
        self.message = message
    }
}

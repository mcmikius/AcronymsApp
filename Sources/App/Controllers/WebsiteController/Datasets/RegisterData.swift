//
// Created by Mykhailo Bondarenko on 05.03.2020.
//

import Foundation
import Vapor

struct RegisterData: Content {
    let name: String
    let username: String
    let password: String
    let confirmPassword: String
}

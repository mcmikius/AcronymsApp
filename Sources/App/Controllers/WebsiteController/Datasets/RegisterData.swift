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
    let emailAddress: String
    let twitterURL: String?
}

extension RegisterData: Validatable, Reflectable {
    static func validations() throws -> Validations<RegisterData> {
        var validations = Validations(RegisterData.self)
        try validations.add(\.name, .ascii)
        try validations.add(\.username, .alphanumeric && .count(3...))
        try validations.add(\.password, .count(8...))
        try validations.add(\.emailAddress, .email)
        validations.add("password match") { model in
            guard model.password == model.confirmPassword else {
                throw BasicValidationError("password don't match")
            }
        }
        return validations
    }
}

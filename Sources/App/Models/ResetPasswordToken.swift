//
//  ResetPasswordToken.swift
//  AcronymsAppPackageDescription
//
//  Created by Mykhailo Bondarenko on 06.03.2020.
//

import Foundation
import Vapor
import FluentPostgreSQL


final class ResetPasswordToken: Codable {
    var id: UUID?
    var token: String
    var userID: User.ID
    
    init(token: String, userID: User.ID) {
        self.token = token
        self.userID = userID
    }
}
extension ResetPasswordToken: PostgreSQLUUIDModel {}

extension ResetPasswordToken: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}

extension ResetPasswordToken {
    var user: Parent<ResetPasswordToken, User> {
        return parent(\.userID)
    }
}

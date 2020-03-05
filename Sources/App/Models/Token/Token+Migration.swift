//
// Created by Mykhailo Bondarenko on 05.03.2020.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

extension Token: Migration {
    static func prepare(on connection: PostgreSQLConnection)
            -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}
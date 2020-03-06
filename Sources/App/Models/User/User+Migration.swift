//
//  User+Migration.swift
//  AcronymsAppPackageDescription
//
//  Created by Mykhailo Bondarenko on 05.03.2020.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

extension User: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.username)
            builder.unique(on: \.email)
        }
    }
}

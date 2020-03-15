//
//  User+PostgreSQLUUIDModel.swift
//  AcronymsAppPackageDescription
//
//  Created by Mykhailo Bondarenko on 05.03.2020.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

extension User: PostgreSQLUUIDModel {
    static let deletedAtKey: TimestampKey? = \.deletedAt
    
    func willCreate(on conn: PostgreSQLConnection) throws -> Future<User> {
        return User.query(on: conn).filter(\.username == self.username).count().map(to: User.self) { count in
            guard count == 0 else {
              throw BasicValidationError("Username already exists")
            }
            return self
        }
    }
}

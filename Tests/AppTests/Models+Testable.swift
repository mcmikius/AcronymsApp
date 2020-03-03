//
//  Models+Testable.swift
//  AcronymsAppPackageDescription
//
//  Created by Mykhailo Bondarenko on 03.03.2020.
//

@testable import App
import FluentPostgreSQL

extension User {
    static func create(name: String = "Luke", username: String = "skywalker", on connection: PostgreSQLConnection) throws -> User {
        let user = User(name: name, username: username)
        return try user.save(on: connection).wait()
    }
}

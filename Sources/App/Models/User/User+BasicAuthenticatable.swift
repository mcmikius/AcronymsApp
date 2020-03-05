//
//  User+BasicAuthenticatable.swift
//  AcronymsAppPackageDescription
//
//  Created by Mykhailo Bondarenko on 05.03.2020.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

extension User: BasicAuthenticatable {
    static let usernameKey: UsernameKey = \User.username
    static let passwordKey: PasswordKey = \User.password
}
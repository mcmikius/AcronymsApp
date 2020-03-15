//
//  UserType.swift
//  AcronymsAppPackageDescription
//
//  Created by Mykhailo Bondarenko on 15.03.2020.
//

import Foundation
import FluentPostgreSQL

enum UserType: String, PostgreSQLEnum, PostgreSQLMigration {
    case admin
    case standard
    case restricted
}

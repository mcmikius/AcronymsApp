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
}

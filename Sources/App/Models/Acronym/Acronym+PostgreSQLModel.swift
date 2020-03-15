//
//  Acronym+PostgreSQLModel.swift
//  AcronymsAppPackageDescription
//
//  Created by Mykhailo Bondarenko on 05.03.2020.
//

import Vapor
import FluentPostgreSQL

extension Acronym: PostgreSQLModel {
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
}

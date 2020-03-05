//
//  Token.swift
//  AcronymsAppPackageDescription
//
//  Created by Mykhailo Bondarenko on 05.03.2020.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

final class Token: Codable {
    var id: UUID?
    var token: String
    var userID: User.ID

    init(token: String, userID: User.ID) {
        self.token = token
        self.userID = userID
    }
}

extension Token {
    static  func generation(for user: User) throws  -> Token {
        let random = try CryptoRandom().generateData(count: 16)
        return try Token(token: random.base64URLEncodedString(), userID: user.requireID())
    }
}
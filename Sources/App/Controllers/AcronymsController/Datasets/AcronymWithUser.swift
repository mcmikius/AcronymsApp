//
//  AcronymWithUser.swift
//  AcronymsAppPackageDescription
//
//  Created by Mykhailo Bondarenko on 15.03.2020.
//

import Vapor

struct AcronymWithUser: Content {
    let id: Int?
    let short: String
    let long: String
    let user: User.Public
}

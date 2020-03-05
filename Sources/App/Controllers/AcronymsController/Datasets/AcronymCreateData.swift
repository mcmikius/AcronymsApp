//
//  AcronymCreateData.swift
//  AcronymsAppPackageDescription
//
//  Created by Mykhailo Bondarenko on 05.03.2020.
//

import Vapor

struct AcronymCreateData: Content {
    let short: String
    let long: String
}

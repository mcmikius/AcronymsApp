//
//  GoogleUserInfo.swift
//  AcronymsAppPackageDescription
//
//  Created by Mykhailo Bondarenko on 06.03.2020.
//

import Foundation
import Vapor

struct GoogleUserInfo: Content {
    let email: String
    let name: String
}

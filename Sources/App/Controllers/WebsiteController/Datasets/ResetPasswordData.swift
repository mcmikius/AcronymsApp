//
//  ResetPasswordData.swift
//  App
//
//  Created by Mykhailo Bondarenko on 06.03.2020.
//

import Foundation
import Vapor

struct ResetPasswordData: Content {
    let password: String
    let confirmPassword: String
}

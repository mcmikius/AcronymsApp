//
//  ResetPasswordContext.swift
//  App
//
//  Created by Mykhailo Bondarenko on 06.03.2020.
//

import Foundation
import Vapor

struct ResetPasswordContext: Encodable {
    let title = "Reset Password"
    let error: Bool?
    
    init(error: Bool? = false) {
        self.error = error
    }
}

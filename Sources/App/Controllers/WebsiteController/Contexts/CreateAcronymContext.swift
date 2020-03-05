//
// Created by Mykhailo Bondarenko on 04.03.2020.
//

import Foundation
import Vapor

struct CreateAcronymContext: Encodable {
    let title: String = "Create An Acronym"
    let csrfToken: String
}

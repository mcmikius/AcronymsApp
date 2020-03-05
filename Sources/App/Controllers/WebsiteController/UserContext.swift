//
// Created by Mykhailo Bondarenko on 04.03.2020.
//

import Foundation
import Vapor

struct UserContext: Encodable {
    let title: String
    let user: User
    let acronyms: [Acronym]
}

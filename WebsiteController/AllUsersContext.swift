//
// Created by Mykhailo Bondarenko on 04.03.2020.
//

import Foundation
import Vapor

struct AllUsersContext: Encodable {
    let title: String
    let users: [User]
}

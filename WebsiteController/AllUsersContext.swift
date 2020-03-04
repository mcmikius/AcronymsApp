//
// Created by Mykhailo Bondarenko on 04.03.2020.
//

import Foundation

struct AllUsersContext: Encodable {
    let title: String
    let users: [User]
}

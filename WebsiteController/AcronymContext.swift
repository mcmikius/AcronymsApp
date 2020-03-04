//
// Created by Mykhailo Bondarenko on 04.03.2020.
//

import Foundation

struct AcronymContext: Encodable {
    let title: String
    let acronym: Acronym
    let user: User
}

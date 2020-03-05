//
// Created by Mykhailo Bondarenko on 04.03.2020.
//

import Foundation
import Vapor

struct IndexContext: Encodable {
    let title: String
    let acronyms: [Acronym]
}

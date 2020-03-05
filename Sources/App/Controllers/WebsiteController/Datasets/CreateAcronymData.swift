//
// Created by Mykhailo Bondarenko on 04.03.2020.
//

import Foundation
import Vapor

struct CreateAcronymData: Content {
    let short: String
    let long: String
    let categories: [String]?
    let csrfToken: String?
}

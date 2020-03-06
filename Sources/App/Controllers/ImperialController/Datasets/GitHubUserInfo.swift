//
// Created by Mykhailo Bondarenko on 06.03.2020.
//

import Foundation
import Vapor

struct GitHubUserInfo: Content {
    let name: String
    let login: String
}

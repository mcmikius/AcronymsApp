//
// Created by Mykhailo Bondarenko on 05.03.2020.
//

import Foundation
import Vapor

struct LoginPostData: Content {
    let username: String
    let password: String
}

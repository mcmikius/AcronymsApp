//
// Created by Mykhailo Bondarenko on 05.03.2020.
//

import Foundation
import Authentication

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}
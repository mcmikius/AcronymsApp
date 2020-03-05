//
// Created by Mykhailo Bondarenko on 05.03.2020.
//

import Foundation
import Authentication

extension Token: BearerAuthenticatable {
    static let tokenKey: TokenKey = \Token.token
}
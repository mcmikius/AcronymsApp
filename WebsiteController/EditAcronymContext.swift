//
// Created by Mykhailo Bondarenko on 04.03.2020.
//

import Foundation
import Vapor

struct EditAcronymContext: Encodable {
    let title: String = "Edit Acronym"
    let acronym: Acronym
    let users: Future<[User]>
    let editing: Bool = true
}

//
// Created by Mykhailo Bondarenko on 04.03.2020.
//

import Foundation
import Vapor

struct AllCategoriesContext: Encodable {
    let title: String = "All Categories"
    let categories: Future<[Category]>
}

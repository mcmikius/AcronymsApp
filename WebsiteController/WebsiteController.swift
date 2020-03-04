//
// Created by Mykhailo Bondarenko on 04.03.2020.
//

import Foundation
import Vapor
import Leaf

struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        router.get(use: indexHandler)
    }

    func indexHandler(_ req: Request) throws -> Future<View> {
        return Acronym.query(on: req).all().flatMap(to: View.self) { acronyms in
            let acronymsData = acronyms.isEmpty ? nil : acronyms
            let context = IndexContext(title: "Home page", acronyms: acronymsData)
            return try req.view().render("index", context)
        }
    }
}

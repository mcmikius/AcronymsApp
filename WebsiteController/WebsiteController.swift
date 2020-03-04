//
// Created by Mykhailo Bondarenko on 04.03.2020.
//

import Foundation
import Vapor
import Leaf

struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        router.get(use: indexHandler)
        router.get("acronym", Acronym.parameter, use: acronymHandler)
    }

    func indexHandler(_ req: Request) throws -> Future<View> {
        return Acronym.query(on: req).all().flatMap(to: View.self) { acronyms in
            let acronymsData = acronyms.isEmpty ? nil : acronyms
            let context = IndexContext(title: "Home page", acronyms: acronymsData)
            return try req.view().render("index", context)
        }
    }

    func acronymHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Acronym.self).flatMap(to: View.self) { acronym in
            return acronym.user.get(on: req).flatMap(to: View.self) { user in
                let context = AcronymContext(title: acronym.short, acronym: acronym, user: user)
                return try req.view().render("acronym", context)
            }
        }
    }
}

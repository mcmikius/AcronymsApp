//
// Created by Mykhailo Bondarenko on 04.03.2020.
//

import Foundation
import Vapor
import Leaf

struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        router.get(use: indexHandler)
        router.get("acronyms", Acronym.parameter, use: acronymHandler)
        router.get("users", User.parameter, use: userHandler)
        router.get("users", use: allUsersHandler)
        router.get("categories", use: allCategoriesHandler)
        router.get("categories", Category.parameter, use: categoryHandler)
        router.get("acronyms", "create", use: createAcronymHandler)
        router.post(CreateAcronymData.self, at: "acronyms", "create", use: createAcronymPostHandler)
        router.get("acronyms", Acronym.parameter, "edit", use: editAcronymHandler)
        router.post("acronyms", Acronym.parameter, "edit", use: editAcronymPostHandler)
        router.post("acronyms", Acronym.parameter, "delete", use: deleteAcronymHandler)
    }

    func indexHandler(_ req: Request) throws -> Future<View> {
        return Acronym.query(on: req).all().flatMap(to: View.self) { acronyms in
            let context = IndexContext(title: "Home page", acronyms: acronyms)
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

    func userHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(User.self).flatMap(to: View.self) { user in
            return try user.acronyms.query(on: req).all().flatMap(to: View.self) { acronyms in
                let context = UserContext(title: user.name, user: user, acronyms: acronyms)
                return try req.view().render("user", context)
            }
        }
    }

    func allUsersHandler(_ req: Request) throws -> Future<View> {
        return User.query(on: req).all().flatMap(to: View.self) { users in
            let context = AllUsersContext(title: "All Users", users: users)
            return try req.view().render("allUsers", context)
        }
    }

    func allCategoriesHandler(_ req: Request) throws -> Future<View> {
        let categories = Category.query(on: req).all()
        let context = AllCategoriesContext(categories: categories)
        return try req.view().render("allCategories", context)
    }

    func categoryHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Category.self)
            .flatMap(to: View.self) { category in
                let acronyms = try category.acronyms.query(on: req).all()
                let context = CategoryContext(title: category.name, category: category, acronyms: acronyms)
                return try req.view().render("category", context)
            }
    }

    func createAcronymHandler(_ req: Request) throws -> Future<View> {
        let context = CreateAcronymContext(users: User.query(on: req).all())
        return try req.view().render("createAcronym", context)
    }

    func createAcronymPostHandler(_ req: Request, data: CreateAcronymData) throws -> Future<Response> {
        let acronym = Acronym(short: data.short, long: data.long, userID: data.userID)
        return acronym.save(on: req).flatMap(to: Response.self) { acronym in
            guard let id = acronym.id else {
                throw Abort(.internalServerError)
            }
            var categorySaves: [Future<Void>] = []
            for category in data.categories ?? [] {
                try categorySaves.append(Category.addCategory(category, to: acronym, on: req))
            }
            let redirect = req.redirect(to: "/acronyms/\(id)")
            return categorySaves.flatten(on: req).transform(to: redirect)
        }
    }

    func editAcronymHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Acronym.self).flatMap(to: View.self) { acronym in
            let context = EditAcronymContext(acronym: acronym, users: User.query(on: req).all())
            return try req.view().render("createAcronym", context)
        }
    }

    func editAcronymPostHandler(_ req: Request) throws -> Future<Response> {
        return try flatMap(to: Response.self, req.parameters.next(Acronym.self), req.content.decode(Acronym.self)) { acronym, data in
            acronym.short = data.short
            acronym.long = data.long
            acronym.userID = data.userID
            guard let id = acronym.id else {
                throw Abort(.internalServerError)
            }
            let redirect = req.redirect(to: "/acronyms/\(id)")
            return acronym.save(on: req).transform(to: redirect)
        }
    }

    func deleteAcronymHandler(_ req: Request) throws -> Future<Response> {
        return try req.parameters.next(Acronym.self).delete(on: req).transform(to: req.redirect(to: "/"))
    }
}

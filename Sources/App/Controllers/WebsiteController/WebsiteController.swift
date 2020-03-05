//
// Created by Mykhailo Bondarenko on 04.03.2020.
//

import Foundation
import Vapor
import Leaf
import Authentication

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
        router.get("login", use: loginHandler)
        router.post(LoginPostData.self, at: "login", use: loginPostHandler)

        let authSessionRoutes = router.grouped(User.authSessionsMiddleware())
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
                let categories = try acronym.categories.query(on: req).all()
                let context = AcronymContext(title: acronym.short, acronym: acronym, user: user, categories: categories)
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
            let users = User.query(on: req).all()
            let categories = try acronym.categories.query(on: req).all()
            let context = EditAcronymContext(acronym: acronym, users: User.query(on: req).all(), categories: categories)
            return try req.view().render("createAcronym", context)
        }
    }

    func editAcronymPostHandler(_ req: Request) throws -> Future<Response> {
        return try flatMap(to: Response.self, req.parameters.next(Acronym.self), req.content.decode(CreateAcronymData.self)) { acronym, data in
            acronym.short = data.short
            acronym.long = data.long
            acronym.userID = data.userID
            guard let id = acronym.id else {
                throw Abort(.internalServerError)
            }
            return acronym.save(on: req).flatMap(to: [Category].self) { _ in
                try acronym.categories.query(on: req).all()
            }.flatMap(to: Response.self) { existingCategories in
                let existingStringArray = existingCategories.map { $0.name }
                let existingSet = Set<String>(existingStringArray)
                let newSet = Set<String>(data.categories ?? [])
                let categoriesToAdd = newSet.subtracting(existingSet)
                let categoriesToRemove = existingSet.subtracting(newSet)
                var categoryResults: [Future<Void>] = []
                for newCategory in categoriesToAdd {
                    categoryResults.append(try Category.addCategory(newCategory, to: acronym, on: req))
                }
                for categoryNameToRemove in categoriesToRemove {
                    let categoryToRemove = existingCategories.first { $0.name == categoryNameToRemove }
                    if let category = categoryToRemove {
                        categoryResults.append(acronym.categories.detach(category, on: req))
                    }
                }
                let redirect = req.redirect(to: "/acronyms/\(id)")
                return categoryResults.flatten(on: req).transform(to: redirect)
            }
        }
    }

    func deleteAcronymHandler(_ req: Request) throws -> Future<Response> {
        return try req.parameters.next(Acronym.self).delete(on: req).transform(to: req.redirect(to: "/"))
    }

    func loginHandler(_ req: Request) throws -> Future<View> {
        let context: LoginContext
        if req.query[Bool.self, at: "error"] != nil {
            context = LoginContext(loginError: true)
        } else {
            context = LoginContext()
        }
        return try req.view().render("login", context)
    }

    func loginPostHandler(_ req: Request, userData: LoginPostData) throws -> Future<Response> {
        return User.authenticate(username: userData.username, password: userData.password, using: BCryptDigest(), on: req).map(to: Response.self) { user in
            guard let user = user else {
                return req.redirect(to: "/login?error")
            }
            try req.authenticateSession(user)
            return req.redirect(to: "/")
        }
    }
}

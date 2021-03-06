//
//  AcronymsController.swift
//  AcronymsAppPackageDescription
//
//  Created by Mykhailo Bondarenko on 02.03.2020.
//

import Foundation
import Vapor
import Fluent
import Authentication

struct AcronymsController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let acronymsRoutes = router.grouped("api", "acronyms")
        acronymsRoutes.get(use: getAllHandler)
        acronymsRoutes.get(Acronym.parameter, use: getHandler)
        acronymsRoutes.get("search", use: searchHandler)
        acronymsRoutes.get("first", use: getFirstHandler)
        acronymsRoutes.get("sorted", use: sortedHandler)
        acronymsRoutes.get(Acronym.parameter, "user", use: getUserHandler)
        acronymsRoutes.get(Acronym.parameter, "categories", use: getCategoriesHandler)
        acronymsRoutes.get("mostRecent", use: getMostRecentAcronyms)
        acronymsRoutes.get("users", use: getAcronymsWithUser)
        acronymsRoutes.get("raw", use: getAllAcronymsRaw)

        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = acronymsRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenAuthGroup.post(AcronymCreateData.self, use: createHandler)
        tokenAuthGroup.delete(Acronym.parameter, use: deleteHandler)
        tokenAuthGroup.put(Acronym.parameter, use: updateHandler)
        tokenAuthGroup.post(Acronym.parameter, "categories", Category.parameter, use: addCategoriesHandler)
        tokenAuthGroup.delete(Acronym.parameter, "categories", Category.parameter, use: removeCategoriesHandler)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).all()
    }
    
    func createHandler(_ req: Request, data: AcronymCreateData) throws -> Future<Acronym> {
        let user = try req.requireAuthenticated(User.self)
        let acronym = try Acronym(short: data.short, long: data.long, userID: user.requireID())
        return acronym.save(on: req)
    }
    
    func getHandler(_ req: Request) throws -> Future<Acronym> {
        return try req.parameters.next(Acronym.self)
    }
    
    func updateHandler(_ req: Request) throws -> Future<Acronym> {
        return try flatMap(to: Acronym.self, req.parameters.next(Acronym.self), req.content.decode(AcronymCreateData.self)) { acronym, updateData in
            acronym.short = updateData.short
            acronym.long = updateData.long
            let user = try req.requireAuthenticated(User.self)
            acronym.userID = try user.requireID()
            return acronym.save(on: req)
        }
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Acronym.self).delete(on: req).transform(to: .noContent)
    }
    
    func searchHandler(_ req: Request) throws -> Future<[Acronym]> {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return Acronym.query(on: req).group(.or) { or in
            or.filter(\.short == searchTerm)
            or.filter(\.long == searchTerm)
        }.all()
    }
    
    func getFirstHandler(_ req: Request) throws -> Future<Acronym> {
        return Acronym.query(on: req).first().unwrap(or: Abort(.notFound))
    }
    
    func sortedHandler(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).sort(\.short, .ascending).all()
    }
    
    func getUserHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(Acronym.self).flatMap(to: User.Public.self) { acronym in
            acronym.user.get(on: req).convertToPublic()
        }
    }
    
    func addCategoriesHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self, req.parameters.next(Acronym.self), req.parameters.next(Category.self), { (acronym, category) in
            return acronym.categories.attach(category, on: req).transform(to: .created)
        })
    }
    
    func getCategoriesHandler(_ req: Request) throws -> Future<[Category]> {
        return try req.parameters.next(Acronym.self).flatMap(to: [Category].self, { (acronym) in
            try acronym.categories.query(on: req).all()
        })
    }
    
    func removeCategoriesHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self, req.parameters.next(Acronym.self), req.parameters.next(Category.self)
        ) { acronym, category in
            return acronym.categories.detach(category, on: req).transform(to: .noContent)
        }
    }
    
    func getMostRecentAcronyms(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).sort(\.updatedAt, .descending).all()
    }
    
    func getAcronymsWithUser(_ req: Request) throws -> Future<[AcronymWithUser]> {
        return Acronym.query(on: req).join(\User.id, to: \Acronym.userID).alsoDecode(User.self).all().map(to: [AcronymWithUser].self) { acronymUserPairs in
            acronymUserPairs
              .map { acronym, user -> AcronymWithUser in
                AcronymWithUser(id: acronym.id, short: acronym.short, long: acronym.long, user: user.convertToPublic())
            }
        }
    }
    
    func getAllAcronymsRaw(_ req: Request) throws -> Future<[Acronym]> {
        return req.withPooledConnection(to: .psql) { conn in
          conn.raw("SELECT * from \"Acronym\"").all(decoding: Acronym.self)
        }
    }
}

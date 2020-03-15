//
//  UserController.swift
//  AcronymsAppPackageDescription
//
//  Created by Mykhailo Bondarenko on 02.03.2020.
//

import Foundation
import Vapor
import Crypto
import Fluent

struct UsersController: RouteCollection {
    
    func boot(router: Router) throws {
        let usersRoute = router.grouped("api", "users")
        usersRoute.get(use: getAllHandler)
        usersRoute.get(User.parameter, use: getHandler)
        usersRoute.get(User.parameter, "acronyms", use: getAcronymsHandler)

        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
        basicAuthGroup.post("login", use: loginHandler)

        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = usersRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenAuthGroup.post(User.self, use: createHandler)
        tokenAuthGroup.delete(User.parameter, use: deleteHandler)
        tokenAuthGroup.post(UUID.parameter, "restore", use: restoreHandler)
        tokenAuthGroup.delete(User.parameter, "force", use: forceDeleteHandler)
        
        let usersV2Route = router.grouped("api", "v2", "users")
        usersV2Route.get(User.parameter, use: getV2Handler)
    }
    
    func createHandler(_ req: Request, user: User) throws -> Future<User.Public> {
        user.password = try BCrypt.hash(user.password)
        return user.save(on: req).convertToPublic()
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[User.Public]> {
        return User.query(on: req).decode(data: User.Public.self).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(User.self).convertToPublic()
    }
    
    func getV2Handler(_ req: Request) throws -> Future<User.PublicV2> {
      return try req.parameters.next(User.self).convertToPublicV2()
    }
    
    func getAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
        return try req.parameters.next(User.self).flatMap(to: [Acronym].self, { (user) in
            try user.acronyms.query(on: req).all()
        })
    }

    func loginHandler(_ req: Request) throws -> Future<Token> {
        let user = try req.requireAuthenticated(User.self)
        let token = try Token.generation(for: user)
        return token.save(on: req)
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(User.self).delete(on: req).transform(to: .noContent)
    }
    
    func restoreHandler(_ req: Request) throws -> Future<HTTPStatus> {
        let userID = try req.parameters.next(UUID.self)
        return User.query(on: req, withSoftDeleted: true).filter(\.id == userID).first().flatMap(to: HTTPStatus.self) { (user) in
            guard let user = user else {
                throw Abort(.notFound)
            }
            return user.restore(on: req).transform(to: .ok)
        }
    }
    
    func forceDeleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(User.self).flatMap(to: HTTPStatus.self, { (user) in
            user.delete(force: true, on: req).transform(to: .noContent)
        })
    }
    
}

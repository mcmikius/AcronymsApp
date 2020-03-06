//
// Created by Mykhailo Bondarenko on 05.03.2020.
//

import Foundation
import Vapor
import Imperial
import Authentication

struct ImperialController: RouteCollection {

    func boot(router: Router) throws {
        guard let googleCallbackURL = Environment.get("GOOGLE_CALLBACK_URL") else {
            fatalError("Google callback URL not set")
        }
        try router.oAuth(from: Google.self, authenticate: "login-google", callback: googleCallbackURL, scope: ["profile", "email"], completion: processGoogleLogin)

        guard let githubCallbackURL = Environment.get("GITHUB_CALLBACK_URL") else {
            fatalError("GitHub callback URL not set")
        }
        try router.oAuth(from: GitHub.self, authenticate: "login-github", callback: githubCallbackURL, scope: ["user:email"], completion: processGitHubLogin)
    }

    func processGoogleLogin(request: Request, token: String) throws -> Future<ResponseEncodable> {
        return try Google.getUser(on: request).flatMap(to: ResponseEncodable.self) { userInfo in
            return User.query(on: request).filter(\.username == userInfo.email).first().flatMap(to: ResponseEncodable.self) { foundUser in
                guard let existingUser = foundUser else {
                    let user = User(name: userInfo.name, username: userInfo.email, password: UUID().uuidString, email: userInfo.email)
                    return user.save(on: request).map(to: ResponseEncodable.self) { user in
                        try request.authenticateSession(user)
                        return request.redirect(to: "/")
                    }
                }
                try request.authenticateSession(existingUser)
                return request.future(request.redirect(to: "/"))
            }
        }
    }

    func processGitHubLogin(request: Request, token: String) throws -> Future<ResponseEncodable> {
        return try flatMap(to: ResponseEncodable.self, GitHub.getUser(on: request), GitHub.getEmails(on: request)) { userInfo, emailInfo in
            return User.query(on: request).filter(\.username == userInfo.login).first().flatMap(to: ResponseEncodable.self) { foundUser in
                guard let existingUser = foundUser else {
                    let user = User(name: userInfo.name, username: userInfo.login, password: UUID().uuidString, email: emailInfo[0].email)
                    return user.save(on: request).map(to: ResponseEncodable.self) { user in
                        try request.authenticateSession(user)
                        return request.redirect(to: "/")
                    }
                }
                try request.authenticateSession(existingUser)
                return request.future(request.redirect(to: "/"))
            }
        }
    }
}

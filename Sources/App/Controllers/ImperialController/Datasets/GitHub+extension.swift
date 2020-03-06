//
// Created by Mykhailo Bondarenko on 06.03.2020.
//

import Foundation
import Vapor
import Imperial

extension GitHub {
    static func getUser(on request: Request) throws -> Future<GitHubUserInfo> {
        var headers = HTTPHeaders()
        headers.bearerAuthorization =
            try BearerAuthorization(token: request.accessToken())
        let githubUserAPIURL = "https://api.github.com/user"
        return try request.client().get(githubUserAPIURL, headers: headers).map(to: GitHubUserInfo.self) { response in
            guard response.http.status == .ok else {
                if response.http.status == .unauthorized {
                    throw Abort.redirect(to: "/login-github")
                } else {
                    throw Abort(.internalServerError)
                }
            }
            return try response.content.syncDecode(GitHubUserInfo.self)
        }
    }

    static func getEmails(on request: Request) throws -> Future<[GitHubEmailInfo]> {
        var headers = HTTPHeaders()
        headers.bearerAuthorization =
            try BearerAuthorization(token: request.accessToken())

        let githubUserAPIURL = "https://api.github.com/user/emails"
        return try request.client().get(githubUserAPIURL, headers: headers).map(to: [GitHubEmailInfo].self) { response in
            guard response.http.status == .ok else {
                if response.http.status == .unauthorized {
                    throw Abort.redirect(to: "/login-github")
                } else {
                    throw Abort(.internalServerError)
                }
            }
            return try response.content.syncDecode([GitHubEmailInfo].self)
        }
    }
}
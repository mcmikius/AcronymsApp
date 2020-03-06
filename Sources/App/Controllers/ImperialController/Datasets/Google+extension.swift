//
//  Google+extension.swift
//  AcronymsAppPackageDescription
//
//  Created by Mykhailo Bondarenko on 06.03.2020.
//

import Foundation
import Imperial

extension Google {
    static func getUser(on request: Request) throws -> Future<GoogleUserInfo> {
        var headers = HTTPHeaders()
        headers.bearerAuthorization = try BearerAuthorization(token: request.accessToken())
        let googleAPIURL = "https://www.googleapis.com/oauth2/v1/userinfo?alt=json"
        return try request.client().get(googleAPIURL, headers: headers).map(to: GoogleUserInfo.self) { response in
            guard response.http.status == .ok else {
                if response.http.status == .unauthorized {
                    throw Abort.redirect(to: "/login-google")
                } else {
                    throw Abort(.internalServerError)
                }
            }
            return try response.content.syncDecode(GoogleUserInfo.self)
        }
    }
}

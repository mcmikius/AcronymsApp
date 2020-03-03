//
//  UserTest.swift
//  AcronymsAppPackageDescription
//
//  Created by Mykhailo Bondarenko on 03.03.2020.
//

@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class UserTests: XCTestCase {
    
    // Getting the users from API
    func testUsersCanBeRetrievedFromAPI() throws {
        
        // MARK: - Run revert. Set up database on a separate connection
        // Set arguments
        let revertEnvironmentArguments = ["vapor", "revert", "--all", "-y"]
        
        //Set up services, configuration, testing environment
        var revertConfig = Config.default()
        var revertServices = Services.default()
        var revertEnvironment = Environment.testing
        
        //Set arguments in the environment
        revertEnvironment.arguments = revertEnvironmentArguments
        
        // Create different App object
        try App.configure(&revertConfig, &revertEnvironment, &revertServices)
        let revertApp = try Application(config: revertConfig, environment: revertEnvironment, services: revertServices)
        try App.boot(revertApp)
        try revertApp.asyncRun().wait()
        
        // MARK: - Run migrations. Set up database on a separate connection
        
        // Set arguments
        let migrateEnvironmentArguments = ["vapor", "migrate", "-y"]
        
        //Set up services, configuration, testing environment
        var migrateConfig = Config.default()
        var migrateServices = Services.default()
        var migrateEnv = Environment.testing
        
        //Set arguments in the environment
        migrateEnv.arguments = migrateEnvironmentArguments
        
        // Create different App object
        try App.configure(&migrateConfig, &migrateEnv, &migrateServices)
        let migrateApp = try Application(config: migrateConfig, environment: migrateEnv, services: migrateServices)
        try App.boot(migrateApp)
        try migrateApp.asyncRun().wait()
        
        // MARK: - Test
        // Define expected values
        let expectedName = "Darth"
        let expectedUsername = "Vaider"
        
        // Create application
        var config = Config.default()
        var services = Services.default()
        var environment = Environment.testing
        try App.configure(&config, &environment, &services)
        let app = try Application(config: config, environment: environment, services: services)
        try App.boot(app)
        
        // Create database connection
        let connection = try app.newConnection(to: .psql).wait()
        
        // Create a couple of users
        let user = User(name: expectedName, username: expectedUsername)
        let savedUser = try user.save(on: connection).wait()
        _ = try User(name: "Like", username: "Skywalker")
        
        // Create Responder
        let responder = try app.make(Responder.self)
        
        // Send GET request to /api/users
        let request = HTTPRequest(method: .GET, url: URL(string: "/api/users")!)
        let wrappedRequest = Request(http: request, using: app)
        
        // Send request and get response
        let response = try responder.respond(to: wrappedRequest).wait()
        
        // Decode response data
        let data = response.http.body.data
        let users = try JSONDecoder().decode([User].self, from: data!)
        
        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(users[0].name, expectedName)
        XCTAssertEqual(users[0].username, expectedUsername)
        XCTAssertEqual(users[0].id, savedUser.id)
        
        // Close the connection to the database
        connection.close()
        
    }
}

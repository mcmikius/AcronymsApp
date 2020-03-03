//
//  UserTests.swift
//  AcronymsAppPackageDescription
//
//  Created by Mykhailo Bondarenko on 03.03.2020.
//

@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class UserTests: XCTestCase {
    
    let usersName = "Darth"
    let usersUsername = "vaider"
    let usersURI = "/api/users/"
    var app: Application!
    var connection: PostgreSQLConnection!
    
    override func setUp() {
        try! Application.reset()
        app = try! Application.testable()
        connection = try! app.newConnection(to: .psql).wait()
    }
    
    override func tearDown() {
        connection.close()
        try? app.syncShutdownGracefully()
    }
    
    func testUsersCanBeRetrievedFromAPI() throws {
        let user = try User.create(name: usersName, username: usersUsername, on: connection)
        _ = try User.create(on: connection)
        
        let users = try app.getResponse(to: usersURI, decodeTo: [User].self)
        
        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(users[0].name, usersName)
        XCTAssertEqual(users[0].username, usersUsername)
        XCTAssertEqual(users[0].id, user.id)
    }
    
    func testUserCanBeSavedWithAPI() throws {
        let user = User(name: usersName, username: usersUsername)
        let receivedUser = try app.getResponse(to: usersURI, method: .POST, headers: ["Content-Type": "application/json"], data: user, decodeTo: User.self)
        
        XCTAssertEqual(receivedUser.name, usersName)
        XCTAssertEqual(receivedUser.username, usersUsername)
        XCTAssertNotNil(receivedUser.id)
        
        let users = try app.getResponse(to: usersURI, decodeTo: [User].self)
        
        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(users[0].name, usersName)
        XCTAssertEqual(users[0].username, usersUsername)
        XCTAssertEqual(users[0].id, receivedUser.id)
    }
    
    func testGettingASingleUserFromTheAPI() throws {
        let user = try User.create(name: usersName, username: usersUsername, on: connection)
        let receivedUser = try app.getResponse(to: "\(usersURI)\(user.id!)", decodeTo: User.self)
        
        XCTAssertEqual(receivedUser.name, usersName)
        XCTAssertEqual(receivedUser.username, usersUsername)
        XCTAssertEqual(receivedUser.id, user.id)
    }
    
    func testGettingAUsersAcronymsFromTheAPI() throws {
        let user = try User.create(on: connection)
        let acronymShort = "OMG"
        let acronymLong = "Oh My God"
        let acronym1 = try Acronym.create(short: acronymShort, long: acronymLong, user: user, on: connection)
        _ = try Acronym.create(short: "LOL", long: "Laugh Out Loud", user: user, on: connection)
        
        let acronyms = try app.getResponse(to: "\(usersURI)\(user.id!)/acronyms", decodeTo: [Acronym].self)
        
        XCTAssertEqual(acronyms.count, 2)
        XCTAssertEqual(acronyms[0].id, acronym1.id)
        XCTAssertEqual(acronyms[0].short, acronymShort)
        XCTAssertEqual(acronyms[0].long, acronymLong)
    }
}

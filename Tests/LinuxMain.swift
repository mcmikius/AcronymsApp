import XCTest
// Import the AppTests module
@testable import AppTests

// These are executed when testing your application on Linux. 
XCTMain([
  testCase(AcronymTests.allTests),
  testCase(CategoryTests.allTests),
  testCase(UserTests.allTests)
])

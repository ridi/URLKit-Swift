import XCTest
@testable import URLKit

final class URLKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(URLKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

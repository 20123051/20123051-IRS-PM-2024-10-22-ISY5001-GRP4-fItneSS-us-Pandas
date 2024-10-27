//
//  fItneSS_usTests.swift
//  fItneSS_usTests
//
//  Created by 夏逸超 on 7/10/24.
//

import Testing
@testable import fItneSS_us

struct fItneSS_usTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        #expect(fItneSS_us().text == "Hello, World!")
    }

}

//
//  BankAccountClassVersionTests.swift
//  ConcurrencyPlaygroundTests
//
//  Created by 박성원 on 11/26/23.
//

import XCTest
@testable import ConcurrencyPlayground

final class BankAccountClassVersionTests: XCTestCase {
    func testFailedRaceData() {
        let account = BankAccountClassVersion(balance: 1000)
        let expectation = XCTestExpectation(description: "입출금 테스트 완료")

        Task {
            for _ in 1...1000 {
                account.deposit(amount: 1)
            }
            expectation.fulfill()
        }

        Task {
            for _ in 1...1000 {
                account.withdraw(amount: 1)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)

        // 최종 잔액이 1000과 일치하는지 확인
        XCTAssertNotEqual(account.balanceConfig(), 1000, "모든 거래 후 잔액이 1000이어야 합니다")
    }
}

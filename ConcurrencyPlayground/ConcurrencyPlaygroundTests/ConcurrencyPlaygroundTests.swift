//
//  ConcurrencyPlaygroundTests.swift
//  ConcurrencyPlaygroundTests
//
//  Created by 박성원 on 11/26/23.
//

import XCTest
@testable import ConcurrencyPlayground

final class ConcurrencyPlaygroundTests: XCTestCase {
    // 계좌 2개를 생성합니다.
    let account1 = BankAccount(balance: 100)
    let account2 = BankAccount(balance: 100)
    
    func testBankAccount() throws {
        runAsyncTest { [weak self] in
            guard let self else {
                return
            }
            
            print("테스트 시작")
            await update()
            print("계좌 입출금 진행")
            await config()
            print("테스트 완료")
        }
    }
    
    private func transfer(amount: Int, from: BankAccount, to: BankAccount) async throws {
        // 인출 후
        let available = await from.withdraw(amount: amount)
        
        // 입금 시도
        await to.deposit(amount: available)
    }
    
    private func update() async {
        // 비동기 작업 시작
        Task {
            try await transfer(amount: 75, from: account2, to: account1)
            print("Transfer complete :: account2 => account1: 75 ")
        }
        
        // 비동기 작업 시작
        Task {
            try await transfer(amount: 50, from: account1, to: account2)
            print("Transfer complete :: account1 => account2 : 50 ")
        }
    }

    private func config() async {
        Task {
            let balance1 = await account1.balanceConfig() // actor method
            let balance2 = await account2.balanceConfig() // actor method
            
            XCTAssertTrue(balance1 == 125, "balance1: \(balance1), balance2: \(balance2)")
            XCTAssert(balance2 == 75, "balance1: \(balance1), balance2: \(balance2)")
        }
    }
}

//
//  BankAccount.swift
//  ConcurrencyPlayground
//
//  Created by 박성원 on 11/26/23.
//

import SwiftUI

/// 은행계좌
actor BankAccount {
    /// 계좌 잔액
    private var balance: Int
    
    init(balance: Int) {
        self.balance = balance
    }
    
    /// 예금
    func deposit(amount: Int) {
        balance += amount
    }
    
    /// 인출
    func withdraw(amount: Int) -> Int {
        // 현금 인출이 가능하면
        if balance >= amount {
            balance -= amount
            
            // 인출한 금액을 알려줍니다.
            return amount
        }
        
        // 잔액부족
        let available = balance
        balance = 0
        
        // 현재 잔액을 보여줍니다.
        return available
    }
    
    /// 현재 잔액
    func balanceConfig() -> Int {
        self.balance
    }
}

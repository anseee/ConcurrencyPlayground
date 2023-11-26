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
    @discardableResult
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

class BankAccountClassVersion {
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
    @discardableResult
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

final class BankAccountDispatchQueue {
    private var balance: Int
    private let queue = DispatchQueue(label: "com.bankAccount.serialQueue")

    init(balance: Int) {
        self.balance = balance
    }

    func deposit(amount: Int) {
        queue.sync {
            self.balance += amount
        }
    }

    @discardableResult
    func withdraw(amount: Int) -> Int {
        queue.sync {
            if self.balance >= amount {
                self.balance -= amount
                return amount
            } else {
                let available = self.balance
                self.balance = 0
                return available
            }
        }
    }
}

final class BankAccountSemaphore {
    private var balance: Int
    private let semaphore = DispatchSemaphore(value: 1)

    init(balance: Int) {
        self.balance = balance
    }

    func deposit(amount: Int) {
        semaphore.wait()
        self.balance += amount
        semaphore.signal()
    }

    @discardableResult
    func withdraw(amount: Int) -> Int {
        semaphore.wait()
        defer { semaphore.signal() }

        if self.balance >= amount {
            self.balance -= amount
            return amount
        } else {
            let available = self.balance
            self.balance = 0
            return available
        }
    }
}

final class BankAccountLock {
    private var balance: Int
    private let lock = NSLock()

    init(balance: Int) {
        self.balance = balance
    }

    func deposit(amount: Int) {
        lock.lock()
        self.balance += amount
        lock.unlock()
    }

    @discardableResult
    func withdraw(amount: Int) -> Int {
        lock.lock()
        defer { lock.unlock() }

        if self.balance >= amount {
            self.balance -= amount
            return amount
        } else {
            let available = self.balance
            self.balance = 0
            return available
        }
    }
    
    /// 데드락 발생!
    func transfer(amount: Int, to account: BankAccountLock) {
        lock.lock()
        defer { lock.unlock() }
        account.lock.lock()
        defer { account.lock.unlock() }
        
        withdraw(amount: amount)
        account.deposit(amount: amount)
    }
}

final class BankAccountRecursiveLock {
    private var balance: Int
    private let lock = NSRecursiveLock()

    init(balance: Int) {
        self.balance = balance
    }

    func deposit(amount: Int) {
        lock.lock()
        self.balance += amount
        lock.unlock()
    }

    @discardableResult
    func withdraw(amount: Int) -> Int {
        lock.lock()
        defer { lock.unlock() }

        if self.balance >= amount {
            self.balance -= amount
            return amount
        } else {
            let available = self.balance
            self.balance = 0
            return available
        }
    }

    func autoAdjustBalance(target: Int) {
        lock.lock()
        defer { lock.unlock() }
        
        if balance < target {
            // 목표 잔액에 도달할 때까지 계속 입금
            deposit(amount: 1)
            autoAdjustBalance(target: target)
        } else if balance > target {
            // 목표 잔액이 초과될 경우 계속 인출
            withdraw(amount: 1)
            autoAdjustBalance(target: target)
        }
    }
}

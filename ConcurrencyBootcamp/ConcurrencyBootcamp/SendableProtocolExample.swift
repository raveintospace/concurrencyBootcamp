//
//  SendableProtocolExample.swift
//  ConcurrencyBootcamp
//  https://youtu.be/wSmTbtOwgbE?si=ilgMl692WMEZlb7T
//  Created by Uri on 19/7/24.
//  Protocol to send objects to Actors

import SwiftUI

actor CurrentUserManager {
    
    func updateDatabase(userInfo: MyClassUserInfo) {}
    
}

// Sendable so we can send thread-safely an object of MyUserInfo to our Actor
// Conforming a struct to sendable increases its performance
struct MyUserInfo: Sendable {
    let name: String
}

// approach not recommended, better use a struct if possible
final class MyClassUserInfo: @unchecked Sendable {
    let name: String
    private var age: Int
    
    // makes the class thread safe
    private let queue = DispatchQueue(label: "com.MyAppName.MyClassUserInfo")
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
    func updateAge(newAge: Int) {
        queue.async {
            self.age = newAge
        }
    }
}

final class SendableProtocolViewModel: ObservableObject {
    
    let manager = CurrentUserManager()
    
    // we send an object from the class (not thread safe) to our actor (thread safe)
    func updateCurrentUserInfo() async {
        
        let info = MyClassUserInfo(name: "Username", age: 18)
        
        await manager.updateDatabase(userInfo: info)
    }
}

struct SendableProtocolExample: View {
    
    @StateObject private var viewModel = SendableProtocolViewModel()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    SendableProtocolExample()
}

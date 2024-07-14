//
//  StructClassActor.swift
//  ConcurrencyBootcamp
//  https://youtu.be/-JLenSTKEcA?si=rEKfmKmex4gX1xnp
//  Created by Uri on 14/7/24.
//

import SwiftUI

struct StructClassActor: View {
    var body: some View {
        Text("Hello, World!")
            .onAppear {
                runTest()
            }
    }
}

#Preview {
    StructClassActor()
}

struct MyStruct {
    let title: String
}

extension StructClassActor {
    
    private func runTest() {
        print("Test started")
        structTest1()
    }
    
    private func structTest1() {
        let objectA = MyStruct(title: "Starting title")
        print("Object A: ", objectA.title)
        
        let objectB = objectA
        print("Object B: ", objectB.title)
    }
}

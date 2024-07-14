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

// Value type
struct MyStruct {
    var title: String
}

// Reference type
class MyClass {
    var title: String
    
    init(title: String) {
        self.title = title
    }
}

extension StructClassActor {
    
    private func runTest() {
        print("Test started")
        structTest1()
        printDivider()
        classTest1()
    }
    
    private func printDivider() {
        print("""
        --------------------
        """)
    }
    
    private func structTest1() {
        print("structTest1")
        let objectA = MyStruct(title: "Starting title")
        print("Object A: ", objectA.title)
        
        print("Pass the VALUES of objectA to objectB")
        var objectB = objectA       // creates a total new object
        print("Object B: ", objectB.title)
        
        objectB.title = "Second title"
        print("ObjectB title changed")      // changes title only for objectB
        
        print("Object A: ", objectA.title)
        print("Object B: ", objectB.title)
    }
    
    private func classTest1() {
        print("classTest1")
        let objectA = MyClass(title: "Starting title")
        print("Object A: ", objectA.title)
        
        print("Pass the REFERENCE of objectA to objectB")
        let objectB = objectA       // updates data of existing object
        print("Object B: ", objectB.title)
        
        objectB.title = "Second title"      // updates title for every existing object (A & B)
        print("ObjectB title changed")
        
        print("Object A: ", objectA.title)
        print("Object B: ", objectB.title)
    }
}

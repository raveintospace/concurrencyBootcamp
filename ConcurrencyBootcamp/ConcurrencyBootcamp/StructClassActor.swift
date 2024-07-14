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
//        structTest1()
//        printDivider()
//        classTest1()
        
        structTest2()
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

// Immutable struct
struct CustomStruct {
    let title: String
    
    // creates a new object
    func updateTitle(newTitle: String) -> CustomStruct {
        return CustomStruct(title: newTitle)
    }
}

// Mutable struct
struct MutatingStruct {
    
    // private(set) so it can't be updated without using the func
    // set allows us to access to property (ie print its value), but won't allow to be updated
    private(set) var title: String
    
    // required as its property is private
    init(title: String) {
        self.title = title
    }
    
    // updates the current object entirely
    mutating func updateTitle(newTitle: String) {
        title = newTitle
    }
}

extension StructClassActor {
    
    private func structTest2() {
        print("structTest2")
        
        print("Update value of mutable struct (var)")
        var struct1 = MyStruct(title: "Title 1")
        print("Struct1: ", struct1.title)
        struct1.title = "Title 2"
        print("Struct1: ", struct1.title)
        
        print("Update value of immutable struct (let)")
        var struct2 = CustomStruct(title: "Title 1")
        print("Struct2: ", struct2.title)
        struct2 = CustomStruct(title: "Title2")
        print("Struct2: ", struct2.title)
        
        print("Update value of immutable struct (let), second option")
        var struct3 = CustomStruct(title: "Title 1")
        print("Struct3: ", struct3.title)
        struct3 = struct3.updateTitle(newTitle: "Title2")
        print("Struct3: ", struct3.title)
        
        print("Update value of mutable struct")
        var struct4 = MutatingStruct(title: "Title 1")
        print("Struct4: ", struct4.title)
        struct4.updateTitle(newTitle: "Title 2")
        print("Struct4: ", struct4.title)
    }
}

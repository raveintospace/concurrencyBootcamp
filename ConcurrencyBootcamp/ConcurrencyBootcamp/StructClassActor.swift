//
//  StructClassActor.swift
//  ConcurrencyBootcamp
//  https://youtu.be/-JLenSTKEcA?si=rEKfmKmex4gX1xnp
//  Created by Uri on 14/7/24.
//

// Lesson recap
/*
Value types:
 - Struct, Enum, String, Int...
 - Stored in the stack
 - Faster
 - Thread safe
 - Creates a new copy of data
 - Cup of coffee empty / cup of coffe full
 
 Reference types:
 - Class, Functions, Actor
 - Stored in the heap
 - Slower but synchronized
 - Not thread safe by default
 - Creates a new reference/pointer to the original instance
 - Two cups of coffee full
 
 -----------------------------
 
 Stack:
 - Stores value types
 - Each thread has its own stack
 
 Heap:
 - Stores reference types
 - Shared across threads
 
 -----------------------------
 
 Struct:
 - Based on values
 - Can be mutated
 - Stored in the stack
 
 Class:
 - Based on references/instances
 - Stored in the heap
 - Can't be mutated outside the class, require a method in the class
 - Can inherit from other classes, not common in SwiftUI
 
 Actor:
 - Same as class, but thread safe
 
 -----------------------------
 
 Struct: Data Models, because we want them to be fast and thread safe
 Struct: Views
 
 Class: ViewModels
 
 Actor: For "shared" DataManagers and DataStores that are accessed by several locations in our app (ie, viewModels)
 */

import SwiftUI

actor StructClassActorDataManager {
    
}

// only initialized once
final class StructClassActorViewModel: ObservableObject {
    
    @Published var title: String = ""
    
    init() {
        print("ViewModel INIT, view instantiates VM")
    }
}

// initialized every time we update the view (ie updating isActive value)
struct StructClassActor: View {
    
    @StateObject private var viewModel = StructClassActorViewModel()
    let isActive: Bool
    
    init(isActive: Bool) {
        self.isActive = isActive
        print("View INIT")
    }
    
    var body: some View {
        Text("Hello, World!")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .background(isActive ? Color.red : Color.blue)
            .onAppear {
                //runTest()
            }
    }
}

struct StructClassActorHomeView: View {
    
    @State private var isActive: Bool = false
    
    var body: some View {
        StructClassActor(isActive: isActive)
            .onTapGesture {
                isActive.toggle()
            }
    }
}

#Preview {
    StructClassActor(isActive: true)
}

// MARK: - Struct Vs Class examples

// Struct: Value type, a copy of data
struct MyStruct {
    var title: String
}

// Class: Reference type, a reference to original
final class MyClass {
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
        printDivider()
        classTest2()
        actorTest1()
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

// MARK: - Structs in depth

// Immutable struct
struct ImmutableStruct {
    let title: String
    
    // creates a new object
    func updateTitle(newTitle: String) -> ImmutableStruct {
        return ImmutableStruct(title: newTitle)
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
        var struct2 = ImmutableStruct(title: "Title 1")
        print("Struct2: ", struct2.title)
        struct2 = ImmutableStruct(title: "Title2")
        print("Struct2: ", struct2.title)
        
        print("Update value of immutable struct (let), second option")
        var struct3 = ImmutableStruct(title: "Title 1")
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

// MARK: - Class in depth + Actor

final class MyClass2 {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    func updateTitle(newTitle: String) {
        title = newTitle
    }
}

actor MyActor {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    func updateTitle(newTitle: String) {
        title = newTitle
    }
}

extension StructClassActor {
    
    private func classTest2() {
        print("classTest2")
        
        print("Update property value of all objects of class MyClass")
        let class2 = MyClass2(title: "Title 1")
        print("Class 2: ", class2.title)
        class2.title = "Title 2"
        print("Class 2: ", class2.title)
        
        let class3 = MyClass2(title: "Title 1")
        print("Class 3: ", class3.title)
        class3.updateTitle(newTitle: "Title 2")
        print("Class 3: ", class3.title)
    }
    
    private func actorTest1() {
        Task {
            print("actorTest1")
            let objectA = MyActor(title: "Starting title")
            await print("Object A: ", objectA.title)
            
            print("Pass the REFERENCE of objectA to objectB")
            let objectB = objectA       // updates data of existing object
            await print("Object B: ", objectB.title)
            
            await objectB.updateTitle(newTitle: "Second title") // updates title for every existing object (A & B)
            print("ObjectB title changed")
            
            await print("Object A: ", objectA.title)
            await print("Object B: ", objectB.title)
        }
    }
}

//
//  MVVMExample.swift
//  ConcurrencyBootcamp
//  https://youtu.be/OpJcInSZpc8?si=aO6v4O7OVwBTdvp5
//  Created by Uri on 20/7/24.
//

import SwiftUI

final class MyManagerClass {
    
    func getData() async throws -> String {
        "Some data from class"
    }
}

// this actor is not on MainActor
actor MyManagerActor {
    
    func getData() async throws -> String {
        "Some data from actor"
    }
}

// the whole VM runs on MainActor, as we update the view with its content
@MainActor
final class MVVMExampleViewModel: ObservableObject {
    
    let managerClass = MyManagerClass()
    let managerActor = MyManagerActor()
    
    @Published private(set) var myData: String = "Starting text"
    
    // Tasks that return Void and never throw error
    private var myTasks: [Task<Void, Never>] = []
    
    func cancelTasks() {
        myTasks.forEach({ $0.cancel() })
        myTasks = []
    }
    
    func ButtonActionFromClass() {
        let task1 = Task {
            do {
                myData = try await managerClass.getData()
            } catch {
                debugPrint(error)
            }
        }
        myTasks.append(task1)
    }
    
    // As VM is on MainActor, when managerActor.getData returns, we go to MainActor
    // Therefore we don't need MainActor.run
    func ButtonActionFromActor() {
        let task1 = Task {
            do {
                myData = try await managerActor.getData()
            } catch {
                debugPrint(error)
            }
        }
        myTasks.append(task1)
    }
}

struct MVVMExample: View {
    
    @StateObject private var viewModel = MVVMExampleViewModel()
    
    var body: some View {
        VStack(spacing: 30) {
            Button("Click me") {
                viewModel.ButtonActionFromClass()
            }
            Button(viewModel.myData) {
                viewModel.ButtonActionFromClass()
            }
            Button(viewModel.myData) {
                viewModel.ButtonActionFromActor()
            }
        }
        .onDisappear {
            viewModel.cancelTasks()
        }
    }
}

#Preview {
    MVVMExample()
}

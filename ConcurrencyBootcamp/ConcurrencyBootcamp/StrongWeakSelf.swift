//
//  StrongWeakSelf.swift
//  ConcurrencyBootcamp
//  https://youtu.be/HRHtOdTJH70?si=Jg67ooFIzQu7w2QG
//  Created by Uri on 20/7/24.
//

import SwiftUI

final class StrongWeakSelfDataManager {
    
    func getData() async -> String {
        return "Updated data"
    }
}

final class StrongWeakSelfViewModel: ObservableObject {
    
    @Published var data: String = "Some Title"
    let manager = StrongWeakSelfDataManager()
    
    // Task that returns void and never throws errors
    private var someTask: Task<Void, Never>? = nil
    
    private var myTasks: [Task<Void, Never>] = []
    
    // Not necessary if we use .task modifier in view instead of .onDisappear
    // Check updateData8
    func cancelTasks() {
        someTask?.cancel()
        someTask = nil
        
        myTasks.forEach({ $0.cancel() })
        myTasks = []
    }
    
    // This is a strong reference
    func updateData() {
        Task {
            data = await manager.getData()
        }
    }
    
    // This is a strong reference
    func updateData2() {
        Task {
            self.data = await self.manager.getData()
        }
    }
    
    // This is a strong reference
    func updateData3() {
        Task { [self] in
            self.data = await manager.getData()
        }
    }
    
    // This is a weak reference
    func updateData4() {
        Task { [weak self] in
            guard let self = self else { return }
            self.data = await manager.getData()
        }
    }
    
    // We don't need to manage weak / strong
    // We manage the task and hold the reference to it (someTask =)
    func updateData5() {
        someTask = Task {
            self.data = await self.manager.getData()
        }
    }
    
    // We manage the task and hold the reference to it (task1 =)
    func updateData6() {
        let task1 = Task {
            self.data = await self.manager.getData()
        }
        myTasks.append(task1)
        
        let task2 = Task {
            self.data = await self.manager.getData()
        }
        myTasks.append(task2)
    }
    
    // We purposely don't cancel tasks to keep strong references
    func updateData7() {
        Task {
            self.data = await self.manager.getData()
        }
        Task.detached {
            self.data = await self.manager.getData()
        }
    }
    
    // used with .task modifier, doesn't need to be cancelled
    func updateData8() async {
        data = await manager.getData()
    }
}

struct StrongWeakSelf: View {
    
    @StateObject private var viewModel = StrongWeakSelfViewModel()
    
    var body: some View {
        Text(viewModel.data)
            .onAppear {
                viewModel.updateData()
            }
            .onDisappear {
                viewModel.cancelTasks()
            }
            .task {
                await viewModel.updateData8()
            }
    }
}

#Preview {
    StrongWeakSelf()
}

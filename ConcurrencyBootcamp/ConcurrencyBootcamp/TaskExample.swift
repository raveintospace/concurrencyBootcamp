//
//  Task.swift
//  ConcurrencyBootcamp
//  L4 - min 8:40
//  Created by Uri on 8/7/24.
//

import SwiftUI

final class TaskViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil
    
    private var dummyArray: [String] = []
    
    func fetchImage() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        for _ in dummyArray {
            // work
            
            try? Task.checkCancellation()
        }
        
        do {
            guard let url = URL(string: "https://picsum.photos/200") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            await MainActor.run {
                self.image = UIImage(data: data)
            }
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    func fetchImage2() async {
        do {
            guard let url = URL(string: "https://picsum.photos/200") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            await MainActor.run {
                self.image2 = UIImage(data: data)
            }
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}

struct TaskExampleHomeView: View {
    
    var body: some View {
        NavigationStack {
            ZStack {
                NavigationLink("Click me 🤓") {
                    TaskExample()
                }
            }
        }
    }
}

struct TaskExample: View {
    
    @StateObject private var viewModel = TaskViewModel()
    
    @State private var fetchImageTask: Task<(), Never>? = nil
    
    var body: some View {
        VStack(spacing: 40) {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            if let image = viewModel.image2 {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
            await viewModel.fetchImage()
        }
        
        // onDisappear
        /*.onDisappear {
            fetchImageTask?.cancel()
        }
         */
        
        // onAppear
        /*.onAppear {
            fetchImageTask = Task {
                await viewModel.fetchImage()
            }
//            Task {
//                await viewModel.fetchImage2()
//            }
            
            // Task(priority: .)
            /*Task(priority: .high) {
                //try? await Task.sleep(nanoseconds: 2)
                await Task.yield()
                debugPrint("High: \(Thread()) : \(Task.currentPriority)")
            }
            Task(priority: .userInitiated) {
                debugPrint("User initiated: \(Thread()) : \(Task.currentPriority)")
            }
            Task(priority: .medium) {
                debugPrint("Medium: \(Thread()) : \(Task.currentPriority)")
            }
            Task(priority: .low) {
                debugPrint("Low: \(Thread()) : \(Task.currentPriority)")
            }
            Task(priority: .utility) {
                debugPrint("Utility: \(Thread()) : \(Task.currentPriority)")
            }
            Task(priority: .background) {
                debugPrint("Background: \(Thread()) : \(Task.currentPriority)")
            }
             */
            /*Task(priority: .low) {
                debugPrint("Low: \(Thread()): \(Task.currentPriority)")
                
                Task.detached {
                    debugPrint("Detached: \(Thread()): \(Task.currentPriority)")
                }
            }
             */
            /*
             debugprint
             "High: <NSThread: 0x600001728b80>{number = 7, name = main} : TaskPriority.high"
             "Medium: <NSThread: 0x600001728c40>{number = 8, name = main} : TaskPriority.medium"
             "User initiated: <NSThread: 0x600001728e40>{number = 9, name = main} : TaskPriority.high"
             "Low: <NSThread: 0x600001728bc0>{number = 10, name = main} : TaskPriority.low"
             "Utility: <NSThread: 0x600001728ec0>{number = 11, name = main} : TaskPriority.low"
             "Background: <NSThread: 0x600001728c00>{number = 12, name = main} : TaskPriority.background"
            */
        }*/
    }
}

#Preview {
    TaskExampleHomeView()
}

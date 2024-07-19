//
//  GlobalActorExample.swift
//  ConcurrencyBootcamp
//  https://youtu.be/BRBhMrJj5f4?si=ykNIH2Mxu8CbwTD5
//  Created by Uri on 19/7/24.
//

import SwiftUI

@globalActor struct MyFirstGlobalActor {
    
    static var shared = MyNewDataManager()
    private init() {}
}

actor MyNewDataManager {
    
    // func is async because is inside actor
    func getDataFromDatabase() -> [String] {
        return ["One", "Two", "Three", "Four", "Five"]
    }
}

final class GlobalActorExampleViewModel: ObservableObject {
    
    // @MainActor so dataArray is updated on main thread, as it is used in our view
    @MainActor @Published var dataArray: [String] = []
    
    let manager = MyFirstGlobalActor.shared
    
    @MyFirstGlobalActor func getData() {
        
        // Heavy complex methods
        
        Task {
            let data = await manager.getDataFromDatabase()
            
            // MainActor.run required to update a MainActor property
            await MainActor.run {
                dataArray = data
            }
        }
    }
    
}

struct GlobalActorExample: View {
    
    @StateObject private var viewModel = GlobalActorExampleViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) {
                    Text($0)
                        .font(.headline)
                }
            }
        }
        .task {
            await viewModel.getData()
        }
    }
}

#Preview {
    GlobalActorExample()
}

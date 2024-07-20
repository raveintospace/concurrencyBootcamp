//
//  AsyncPublisherExample.swift
//  ConcurrencyBootcamp
//  https://youtu.be/ePPm2ftSVqw?si=N6VSjCc5B0-GPbdM
//  Created by Uri on 20/7/24.
//  Subscribe to @Published properties without Combine

import SwiftUI
import Combine

actor AsyncPublisherDataManager {
    
    @Published var myData: [String] = []
    
    func addData() async {
        myData.append("Apple")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Banana")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Peach")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Strawberry")
    }
}

final class AsyncPublisherExampleViewModel: ObservableObject {
    
    @MainActor @Published var dataArray: [String] = []
    let manager = AsyncPublisherDataManager()
    var cancellables = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    // Combine
    /*
    private func addSubscribersWithCombine() {
        manager.$myData
            .receive(on: DispatchQueue.main)
            .sink { receivedDataArray in
                self.dataArray = receivedDataArray
            }
            .store(in: &cancellables)
    }
     */
    
    private func addSubscribers() {
        Task {
            for await value in await manager.$myData.values {
                await MainActor.run {
                    self.dataArray = value
                }
            }
        }
    }
    
    func start() async {
        await manager.addData()
    }
}

struct AsyncPublisherExample: View {
    
    @StateObject private var viewModel = AsyncPublisherExampleViewModel()
    
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
            await viewModel.start()
        }
    }
}

#Preview {
    AsyncPublisherExample()
}

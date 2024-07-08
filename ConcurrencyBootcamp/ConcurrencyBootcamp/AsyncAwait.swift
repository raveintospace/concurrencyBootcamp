//
//  AsyncAwait.swift
//  ConcurrencyBootcamp
//  L3
//  Created by Uri on 8/7/24.
//

import SwiftUI

class AsyncAwaitViewModel: ObservableObject {
    
    @Published var dataArray: [String] = []
    
    func addTitle1() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.dataArray.append("Title 1: \(Thread.current)")
        }
    }
    
    func addTitle2() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
            let title = "Title 2: \(Thread.current)"
            DispatchQueue.main.async {
                self.dataArray.append(title)
            }
        }
    }
    
    func addAuthor1() async {
        await MainActor.run {
            let author1 = "Author 1: \(Thread())"
            self.dataArray.append(author1)
        }
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let author2 = "Author 2: \(Thread())"
        await MainActor.run {
            self.dataArray.append(author2)
            
            let author3 = "Author 3: \(Thread())"
            self.dataArray.append(author3)
        }
    }
    
    func doSomething() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        let something1 = "Something 1: \(Thread())"
        await MainActor.run {
            self.dataArray.append(something1)
            
            let something2 = "Something 2: \(Thread())"
            self.dataArray.append(something2)
        }
    }
}

struct AsyncAwait: View {
    
    @StateObject private var viewModel = AsyncAwaitViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.dataArray, id: \.self) { data in
                Text(data)
            }
        }
        .onAppear {
            Task {
                await viewModel.addAuthor1()
                await viewModel.doSomething()
                
                let finalText = "Final text \(Thread())"
                viewModel.dataArray.append(finalText)
            }
            
            // viewModel.addTitle1()
            // viewModel.addTitle2()
        }
    }
}

#Preview {
    AsyncAwait()
}

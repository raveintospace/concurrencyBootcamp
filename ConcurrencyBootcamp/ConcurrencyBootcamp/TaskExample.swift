//
//  Task.swift
//  ConcurrencyBootcamp
//  L4 - min 8:40
//  Created by Uri on 8/7/24.
//

import SwiftUI

class TaskViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil
    
    func fetchImage() async {
        do {
            guard let url = URL(string: "https://picsum.photos/200") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            self.image = UIImage(data: data)
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    func fetchImage2() async {
        do {
            guard let url = URL(string: "https://picsum.photos/200") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            self.image2 = UIImage(data: data)
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}

struct TaskExample: View {
    
    @StateObject private var viewModel = TaskViewModel()
    
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
        .onAppear {
            Task {
                await viewModel.fetchImage()
            }
            Task {
                await viewModel.fetchImage2()
            }
        }
    }
}

#Preview {
    TaskExample()
}

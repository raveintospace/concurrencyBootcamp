//
//  TaskGroup.swift
//  ConcurrencyBootcamp
//  https://youtu.be/epBbbysk5cU?si=uFIgTg18i5acJAvs
//  Created by Uri on 13/7/24.
//

import SwiftUI

final class TaskgroupViewModel: ObservableObject {
    
    @Published var images: [UIImage] = []
}

struct TaskGroup: View {
    
    @StateObject private var viewModel = TaskgroupViewModel()
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Task Group")
        }
    }
}

#Preview {
    TaskGroup()
}

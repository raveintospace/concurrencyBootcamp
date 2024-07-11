//
//  AsyncLet.swift
//  ConcurrencyBootcamp
//  https://youtu.be/1OmJJwVF7uQ?si=u3ZlEb7GLXAElfea
//  Created by Uri on 11/7/24.
//  Ideal when you need to do several fetch requests at the same time and get the result at the same time -> Navigating to a new screen

import SwiftUI

struct AsyncLet: View {
    
    @State private var images: [UIImage] = []
    @State private var title: String = "Dummy Title 🥸"
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    let url = URL(string: "https://picsum.photos/300")!
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle(title)
            .onAppear {
                Task {
                    do {
                        async let fetchImage1 = fetchImage()
                        async let fetchTitle1 = fetchTitle()
                        async let fetchImage2 = fetchImage()
                        async let fetchImage3 = fetchImage()
                        async let fetchImage4 = fetchImage()
                        
                        let (image1, title1, image2, image3, image4) = await (try fetchImage1, fetchTitle1, try fetchImage2, try fetchImage3, try fetchImage4)
                        self.images.append(contentsOf: [image1, image2, image3, image4])
                        self.title = title1
                        
                        // block of try await x4
                        /*let image1 = try await fetchImage()
                        self.images.append(image1)
                        
                        let image2 = try await fetchImage()
                        self.images.append(image2)
                        
                        let image3 = try await fetchImage()
                        self.images.append(image3)
                        
                        let image4 = try await fetchImage()
                        self.images.append(image4)
                         */
                        
                    } catch {
                        debugPrint("An error onAppear")
                    }
                }
            }
        }
    }
}

#Preview {
    AsyncLet()
}

extension AsyncLet {
    
    private func fetchImage() async throws -> UIImage {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badURL)
            }
        } catch {
            throw error
        }
    }
    
    private func fetchTitle() -> String {
        return "Async let example 🥳"
    }
}

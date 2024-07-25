//
//  PhotosPickerExample.swift
//  ConcurrencyBootcamp
//  https://youtu.be/IZEYVX4vTOA?si=iMGPL-XHn7__3_UC
//  Created by Uri on 25/7/24.
//

import SwiftUI
import PhotosUI

@MainActor
final class PhotosPickerViewModel: ObservableObject {
    
    // MARK: - one image
    @Published private(set) var selectedImage: UIImage? = nil
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageSelection)
        }
    }
    
    // triggered with didSet when imageSelection is updated
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else { return }
        
        // convert the data from the image to a UIImage
        Task {
            if let data = try? await selection.loadTransferable(type: Data.self) {
                if let convertedUiImage = UIImage(data: data) {
                    selectedImage = convertedUiImage
                }
            }
        }
    }
    
    private func setImageDoTryCatch(from selection: PhotosPickerItem?) {
        guard let selection else { return }
        
        // convert the data from the image to a UIImage, throwing errors if we don't have data
        Task {
            do {
                let data = try await selection.loadTransferable(type: Data.self)
                
                guard let data, let convertedUiImage = UIImage(data: data) else {
                    throw URLError(.badServerResponse)
                }
                
                selectedImage = convertedUiImage
                
            } catch {
                debugPrint(error)
            }
        }
    }
    
    // MARK: Multiple images
    @Published private(set) var selectedImages: [UIImage] = []
    @Published var imageSelections: [PhotosPickerItem] = [] {
        didSet {
            setImages(from: imageSelections)
        }
    }
    
    private func setImages(from selections: [PhotosPickerItem]) {
        Task {
            var images: [UIImage] = []
            for selection in selections {
                if let data = try? await selection.loadTransferable(type: Data.self) {
                    if let convertedUiImage = UIImage(data: data) {
                        images.append(convertedUiImage)
                    }
                }
            }
            selectedImages = images
        }
    }
}

struct PhotosPickerExample: View {
    
    @StateObject private var viewModel = PhotosPickerViewModel()
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Hello, World!")
            
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            // single image
            PhotosPicker(selection: $viewModel.imageSelection, matching: .images) {
                Text("Open the single photo picker")
                    .foregroundStyle(Color.red)
            }
            
            if !viewModel.selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.selectedImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // multiple images
            PhotosPicker(selection: $viewModel.imageSelections) {
                Text("Open the multiple photos picker")
                    .foregroundStyle(Color.green)
            }
        }
    }
}

#Preview {
    PhotosPickerExample()
}

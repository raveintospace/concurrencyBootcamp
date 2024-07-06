//
//  DoTryCatchThrows.swift
//  ConcurrencyBootcamp
//
//  Created by Uri on 6/7/24.
//

import SwiftUI

class DoTryCatchThrowsDataManager {
    
    let isActive: Bool = true
    
    // returns both an Optional String and an Optional Error
    func getTitle() -> (title: String?, error: Error?) {
        if isActive {
            return ("New Text", nil)
        } else {
            return (nil, URLError(.badURL))
        }
    }
    
    // returns only a Result, that will be of type String or Error
    func getTitle2() -> Result<String, Error> {
        if isActive {
            return .success("New Title")
        } else {
            return .failure(URLError(.badServerResponse))
        }
    }
    
    // throws means that func can thrown an error
    // Func returns a String or throws an error
    func getTitle3() throws -> String {
        if isActive {
            return "New Title"
        } else {
            throw URLError(.backgroundSessionInUseByAnotherProcess)
        }
    }
    
    func getTitle4() throws -> String {
        if isActive {
            return "Final text"
        } else {
            throw URLError(.backgroundSessionInUseByAnotherProcess)
        }
    }
}

class DoTryCatchThrowsViewModel: ObservableObject {
    
    @Published var text: String = "Starting text"
    let manager = DoTryCatchThrowsDataManager()
    
    func fetchTitle() {
        // getTitle - Tuple with optional String & optional Error
        /*
        let returnedValue = manager.getTitle()
        if let newTitle = returnedValue.title {
            self.text = newTitle
        } else if let error = returnedValue.error {
            self.text = error.localizedDescription
        }
         */
        
        // getTitle2 - Result
        /*
        let result = manager.getTitle2()
        
        switch result {
        case .success(let newTitle):
            self.text = newTitle
        case .failure(let error):
            self.text = error.localizedDescription
        }
         */
        
        // try?
        /*
        // returns a string if isActive, nothing happens if !isActive
        let newTitle = try? manager.getTitle3()
        if let newTitle = newTitle {
            self.text = newTitle
        }
         */
        
        do {
            let newTitle = try manager.getTitle3()
            self.text = newTitle
            
            let finalTitle = try manager.getTitle4()
            self.text = finalTitle
        } catch {
            self.text = error.localizedDescription
        }
    }
}

struct DoTryCatchThrows: View {
    
    @StateObject private var viewModel = DoTryCatchThrowsViewModel()
    
    var body: some View {
        Text(viewModel.text)
            .frame(width: 300, height: 300)
            .background(Color.blue)
            .onTapGesture {
                viewModel.fetchTitle()
            }
    }
}

#Preview {
    DoTryCatchThrows()
}

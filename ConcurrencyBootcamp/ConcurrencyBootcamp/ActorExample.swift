//
//  ActorExample.swift
//  ConcurrencyBootcamp
//  https://youtu.be/UUdi137FySk?si=HcTLRcqWF0UNGfqu
//  Created by Uri on 16/7/24.
//

/*
 1. What is the problem that actors solve? When multiple threads try to access the same piece of memory in the heap at the same time
 
 2. How to fix the problem before Actors? "private let queue" in Data Manager
 */
import SwiftUI

class MyDataManager {
    
    static let instance = MyDataManager()
    private init() {}
    
    var data: [String] = []
    private let queue = DispatchQueue(label: "com.MyAppName.MyDataManager")
    
    func getRandomData(completionHandler: @escaping (_ title: String?) -> Void) {
        queue.async {
            self.data.append(UUID().uuidString)
            debugPrint(Thread())
            completionHandler(self.data.randomElement())
        }
    }
}

struct HomeView: View {
    
    let manager = MyDataManager.instance
    
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.green.opacity(0.3).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
            DispatchQueue.global(qos: .background).async {
                manager.getRandomData { title in
                    if let data = title {
                        DispatchQueue.main.async {
                            text = data
                        }
                    }
                }
            }
        }
    }
}

struct BrowseView: View {
    
    let manager = MyDataManager.instance
    
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.3).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
            DispatchQueue.global(qos: .default).async {
                manager.getRandomData { title in
                    if let daata = title {
                        DispatchQueue.main.async {
                            text = data
                        }
                    }
                }
            }
        }
    }
}

struct ActorExample: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
        }
    }
}

#Preview {
    ActorExample()
}

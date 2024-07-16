//
//  ActorExample.swift
//  ConcurrencyBootcamp
//  https://youtu.be/UUdi137FySk?si=HcTLRcqWF0UNGfqu
//  Created by Uri on 16/7/24.
//

/*
 1. What is the problem that actors solve? When two threads access the heap at the same time
 */
import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            Color.green.opacity(0.3).ignoresSafeArea()
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
            
            Text("Hi 2")
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
        }
    }
}

#Preview {
    ActorExample()
}

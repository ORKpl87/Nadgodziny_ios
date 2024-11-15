//
//  ContentView.swift
//  Nadgodziny
//
//  Created by Arek Jaworski on 14/11/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AppViewModel()
    
    var body: some View {
        if viewModel.currentUser == nil {
            OnboardingView()
                .environmentObject(viewModel)
        } else {
            TabView {
                OvertimeListView()
                    .tabItem {
                        Label("Nadgodziny", systemImage: "clock")
                    }
                    .environment(\.locale, Locale(identifier: "pl_PL"))
                
                MonthlyReportView()
                    .tabItem {
                        Label("Raporty", systemImage: "chart.bar")
                    }
                    .environment(\.locale, Locale(identifier: "pl_PL"))
                
                ProfileView()
                    .tabItem {
                        Label("Profil", systemImage: "person")
                    }
                    .environment(\.locale, Locale(identifier: "pl_PL"))
            }
            .environmentObject(viewModel)
            .tint(Theme.primaryColor)
        }
    }
}

#Preview {
    ContentView()
        .environment(\.locale, Locale(identifier: "pl_PL"))
}

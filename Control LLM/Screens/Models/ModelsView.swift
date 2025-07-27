import SwiftUI

struct ModelsView: View {
    @StateObject private var viewModel = ModelsViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                AgentTabsView(viewModel: viewModel)
            }
            .navigationTitle("Models & Agents")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    ModelsView()
} 
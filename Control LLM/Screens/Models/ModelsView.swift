import SwiftUI

struct ModelsView: View {
    @StateObject private var viewModel = ModelsViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                AgentTabsView(viewModel: viewModel)
            }
            .navigationTitle(NSLocalizedString("Models & Agents", comment: ""))
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    ModelsView()
} 
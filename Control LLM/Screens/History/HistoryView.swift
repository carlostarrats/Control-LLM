import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                HistoryTabsView(viewModel: viewModel)
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    HistoryView()
} 
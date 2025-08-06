import SwiftUI

struct SettingsHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteSheet = false
    @State private var referenceChatHistory = true // Default to true
    let onHistoryDeleted: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#1D1D1D")
                .ignoresSafeArea()
            
            // Scrollable content
            ScrollView {
                VStack(spacing: 8) {
                    // Reference Chat History option
                    VStack(spacing: 0) {
                        Button(action: {
                            referenceChatHistory.toggle()
                        }) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Reference Chat History")
                                        .font(.custom("IBMPlexMono", size: 16))
                                        .foregroundColor(Color(hex: "#EEEEEE"))
                                        .multilineTextAlignment(.leading)
                                    
                                    Text("Let the LLM reference recent conversations when responding.")
                                        .font(.custom("IBMPlexMono", size: 12))
                                        .foregroundColor(Color(hex: "#BBBBBB"))
                                        .multilineTextAlignment(.leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                
                                Spacer()
                                
                                Image(systemName: referenceChatHistory ? "checkmark.square.fill" : "square")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(hex: "#BBBBBB"))
                            }
                            .padding(.horizontal, 4)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Horizontal line under the item
                        Rectangle()
                            .fill(Color(hex: "#333333"))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 20)
                    
                    // Delete All History option
                    VStack(spacing: 0) {
                        Button(action: {
                            showingDeleteSheet = true
                        }) {
                            HStack {
                                Text("Delete All History")
                                    .font(.custom("IBMPlexMono", size: 16))
                                    .foregroundColor(Color(hex: "#FF6B6B"))
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                Image(systemName: "trash")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "#FF6B6B"))
                            }
                            .padding(.horizontal, 4)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Horizontal line under the item
                        Rectangle()
                            .fill(Color(hex: "#333333"))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
            }
            .safeAreaInset(edge: .top) {
                // Header
                VStack(spacing: 0) {
                    // Grab bar
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color(hex: "#666666"))
                        .frame(width: 36, height: 5)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    
                    // Header
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "list.bullet")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                            
                            Text("Chat History")
                                .font(.custom("IBMPlexMono", size: 20))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                        }
                        .padding(.leading, 20)
                        
                        Spacer()

                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                                .frame(width: 32, height: 32)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.trailing, 20)
                    }
                    .padding(.bottom, 20)
                }
                .background(
                    Color(hex: "#1D1D1D")
                )
            }
        }
        .sheet(isPresented: $showingDeleteSheet) {
            DeleteHistorySheet(
                onDelete: {
                    // TODO: Implement actual delete functionality
                    onHistoryDeleted()
                    dismiss() // Dismiss the history settings sheet
                }
            )
            .presentationDetents([.height(250)])
        }

    }
}

struct DeleteHistorySheet: View {
    @Environment(\.dismiss) private var dismiss
    let onDelete: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#1D1D1D")
                .ignoresSafeArea()
            
            // Scrollable content
            ScrollView {
                VStack(spacing: 8) {
                                    // Content
                VStack(spacing: 8) {
                                            Text("This action can't be undone.")
                            .font(.custom("IBMPlexMono", size: 16))
                            .foregroundColor(Color(hex: "#EEEEEE"))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 0)
                    
                    // Stacked buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            onDelete()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                dismiss()
                            }
                        }) {
                            Text("Delete All History")
                                .font(.custom("IBMPlexMono", size: 16))
                                .foregroundColor(Color(hex: "#FF6B6B"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(hex: "#2A2A2A"))
                                .cornerRadius(4)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Cancel")
                                .font(.custom("IBMPlexMono", size: 16))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(hex: "#2A2A2A"))
                                .cornerRadius(4)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
                }
                .padding(.bottom, 20)
            }
            .safeAreaInset(edge: .top) {
                // iOS standard header overlay
                VStack(spacing: 0) {
                    // Grab bar
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color(hex: "#666666"))
                        .frame(width: 36, height: 5)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    
                    // Header
                    HStack {
                        Text("Delete All History")
                            .font(.custom("IBMPlexMono", size: 20))
                            .foregroundColor(Color(hex: "#BBBBBB"))
                            .padding(.leading, 20)
                        
                        Spacer()

                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                                .frame(width: 32, height: 32)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.trailing, 20)
                    }
                    
                    // Buffer space below header
                    Spacer()
                        .frame(height: 18)
                }
                .background(
                    Color(hex: "#1D1D1D")
                )
            }
        }
    }
}

 
import SwiftUI

struct LoginPromptSheet: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false

    var onLoginSuccess: (() -> Void)?

    var body: some View {
        VStack(spacing: 24) {
            Capsule()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 40, height: 5)
                .padding(.top, 12)

            Spacer()

            Image(systemName: "lock.shield.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("Sign in Required")
                .font(.title2.bold())

            Text("You need to sign in to access this feature")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            VStack(spacing: 12) {
                if isLoading {
                    ProgressView("Signing in...")
                        .frame(height: 50)
                } else {
                    Button {
                        mockSignIn()
                    } label: {
                        HStack {
                            Image(systemName: "person.fill.checkmark")
                                .font(.title3)
                            Text("Sign in (Demo)")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.secondary)
                .font(.subheadline)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .presentationDetents([.medium])
    }

    private func mockSignIn() {
        isLoading = true
        Task {
            authManager.mockSignIn()
            try? await Task.sleep(for: .milliseconds(500))
            isLoading = false
            dismiss()
            onLoginSuccess?()
        }
    }
}

#Preview {
    LoginPromptSheet()
        .environment(AuthManager())
}

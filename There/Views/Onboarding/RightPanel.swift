// RightPanel.swift

import PostHog
import SwiftUI

struct RightPanel: View {
    @Binding var email: String
    let saveEmail: (@escaping (Bool) -> Void) -> Void
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    private var isValidEmail: Bool {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
            .wholeMatch(of: #/[^@\s]+@[^@\s]+\.[^@\s]+/#) != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Please enter your email")
                .font(.callout)
                .fontWeight(.medium)
                .padding(.bottom, 2)

            Input(text: $email, placeholder: "dena@example.com")

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .fontWeight(.medium)
            }

            PrimaryButton(title: isSubmitting ? "Signing up..." : "Continue", action: {
                guard isValidEmail else {
                    errorMessage = "Please enter a valid email"
                    return
                }

                errorMessage = nil
                isSubmitting = true

                saveEmail { success in
                    isSubmitting = false

                    guard success else {
                        errorMessage = "Couldn't sign you up. Please try again or skip."
                        return
                    }

                    appState.presentMenu()
                    presentationMode.wrappedValue.dismiss()
                }
            })
            .disabled(isSubmitting)

            SecondaryButton(title: "Skip", action: {
                PostHogSDK.shared.capture("sign_up_skipped", properties: ["date": Date.now])
                UserDefaults.standard.setValue(true, forKey: "hasCompletedInitialSetup")
                appState.presentMenu()
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

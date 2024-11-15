import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var user = User()
    @State private var currentStep = 0
    
    var body: some View {
        ZStack {
            Theme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content
                TabView(selection: $currentStep) {
                    welcomeStep
                        .tag(0)
                    
                    personalDataStep
                        .tag(1)
                    
                    notificationStep
                        .tag(2)
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                // Navigation buttons
                navigationButtons
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            AppLogo(size: 100)
            
            Text("Nadgodziny")
                .font(Theme.Typography.title)
                .foregroundColor(Theme.primaryColor)
        }
        .padding(.top, 40)
    }
    
    private var welcomeStep: some View {
        VStack(spacing: 20) {
            Text("Cześć!")
                .font(Theme.Typography.title)
            
            Text("Ta aplikacja pomoże Ci w łatwym zarządzaniu nadgodzinami i tworzeniu raportów miesięcznych, możesz też wysłać raport miesięczny bezpośrednio do swojego pracodawcy!")
                .font(Theme.Typography.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Image(systemName: "arrow.right.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(Theme.primaryColor)
                .padding(.top)
        }
        .padding()
        .modernCard(hasGradient: true)
        .padding()
    }
    
    private var personalDataStep: some View {
        VStack(spacing: 20) {
            Text("Twoje dane")
                .font(Theme.Typography.title)
            
            VStack(spacing: 16) {
                TextField("Imię i nazwisko", text: $user.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Dział", text: $user.department)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Email", text: $user.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                
                TextField("Email kierownika", text: $user.supervisorEmail)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
            }
        }
        .padding()
        .modernCard()
        .padding()
    }
    
    private var notificationStep: some View {
        VStack(spacing: 20) {
            Text("Powiadomienia")
                .font(Theme.Typography.title)
            
            Text("O której godzinie chcesz otrzymywać przypomnienie o dodaniu nadgodzin?")
                .font(Theme.Typography.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            DatePicker("Godzina przypomnienia",
                      selection: $user.notificationTime,
                      displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .environment(\.locale, Locale(identifier: "pl_PL"))
        }
        .padding()
        .modernCard()
        .padding()
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 20) {
            if currentStep > 0 {
                Button(action: { currentStep -= 1 }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Wstecz")
                    }
                    .foregroundColor(Theme.secondaryColor)
                }
            }
            
            if currentStep < 2 {
                Button(action: { currentStep += 1 }) {
                    HStack {
                        Text("Dalej")
                        Image(systemName: "chevron.right")
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.primaryColor)
            } else {
                Button(action: {
                    withAnimation {
                        viewModel.saveUser(user)
                    }
                }) {
                    Text("Rozpocznij")
                        .frame(minWidth: 200)
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.primaryColor)
                .disabled(user.name.isEmpty || user.email.isEmpty || user.supervisorEmail.isEmpty)
            }
        }
        .padding()
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppViewModel())
} 

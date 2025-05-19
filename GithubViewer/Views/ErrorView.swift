import SwiftUI

struct ErrorView: View {
    let error: NetworkError
    var retryAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.red)
            
            Text("Oops! Something Went Wrong")
                .font(.title)
                .fontWeight(.bold)
            
            Text(error.localizedDescription)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            
            if let retryAction = retryAction {
                Button(action: retryAction) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Retry")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            
            Button("Contact Support") {
                // In a real app, this would open an email or support chat
                log("User requested support for error: \(error.localizedDescription)", level: .warning)
            }
            .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

#Preview {
    ErrorView(error: NetworkError.networkFailure(URLError(.badURL))) {
        print("Retry tapped")
    }
}

#Preview("Without Retry") {
    ErrorView(error: NetworkError.networkFailure(URLError(.badURL)), retryAction: nil)
}

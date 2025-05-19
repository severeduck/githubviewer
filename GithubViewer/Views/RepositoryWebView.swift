import SwiftUI
import WebKit

struct RepositoryWebView: View {
    let url: URL
    
    var body: some View {
        WebView(url: url)
            .navigationBarTitle("Repository", displayMode: .inline)
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView(frame: .zero)
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

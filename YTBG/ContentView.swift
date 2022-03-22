//
//  ContentView.swift
//  YTBG
//
//  Created by Viktor Gordienko on 20.03.2022.
//

import SwiftUI
import WebKit

// MARK: - View

struct ContentView: View {
    @State var currentPageUrl = Constants.youTubeURL

    var body: some View {
        Webview(url: URL(string: currentPageUrl)!)
            .overlay(
                Button(action: {
                    YTBG.alert {
                        currentPageUrl = $0 ?? Constants.youTubeURL
                    }
                }) {
                    Image(systemName: "link.circle.fill")
                        .frame(width: 60, height: 60)
                        .font(.system(size: 30))
                }
                    .buttonStyle(GradientButtonStyle()), alignment: .bottomTrailing
            )
            .background(Color("background").ignoresSafeArea())
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: - GradientButtonStyle

struct GradientButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.white)
            .background(LinearGradient(
                gradient: Gradient(colors: [Color.red, Color.orange]),
                startPoint: .leading,
                endPoint: .trailing))
            .cornerRadius(30.0)
            .padding(.bottom, 60)
            .padding(.trailing, 20)
    }
}

// MARK: - Webview

struct Webview: UIViewRepresentable {
    let url: URL
    func makeUIView(context: UIViewRepresentableContext<Webview>) -> WKWebView {
        let webview = WKWebView()
        let request = URLRequest(url: self.url, cachePolicy: .returnCacheDataElseLoad)
        webview.load(request)
        return webview
    }

    func updateUIView(_ webview: WKWebView, context: UIViewRepresentableContext<Webview>) {
        let request = URLRequest(url: self.url, cachePolicy: .returnCacheDataElseLoad)
        webview.load(request)
    }
}

// MARK: - Alert

private func alert(completion: @escaping (String?) -> Void) {
    var myTextField: UITextField = UITextField()
    let alert = UIAlertController(title: Constants.alertTitle, message: Constants.alertMessage, preferredStyle: .alert)
    alert.addTextField {
        myTextField = $0
        myTextField.text = Constants.youTubeURL
        myTextField.placeholder = Constants.alertPlaceholder
    }
    alert.addAction(UIAlertAction(title: Constants.alertCancel, style: .cancel) { _ in })
    alert.addAction(UIAlertAction(title: Constants.alertOK, style: .default) { _ in
        guard let urlString = myTextField.text, urlString != "" else { return }
        let validUrlString = urlString.hasPrefix("http") ? urlString : "http://\(urlString)"
        completion(validUrlString.trimmingCharacters(in: .whitespacesAndNewlines))
    })
    showAlert(alert: alert)
}

func showAlert(alert: UIAlertController) {
    if let controller = topMostViewController() {
        controller.present(alert, animated: true)
    }
}

private func keyWindow() -> UIWindow? {
    return UIApplication.shared.connectedScenes
        .filter {$0.activationState == .foregroundActive}
        .compactMap {$0 as? UIWindowScene}
        .first?.windows.filter {$0.isKeyWindow}.first
}

private func topMostViewController() -> UIViewController? {
    guard let rootController = keyWindow()?.rootViewController else {
        return nil
    }
    return topMostViewController(for: rootController)
}

private func topMostViewController(for controller: UIViewController) -> UIViewController {
    if let presentedController = controller.presentedViewController {
        return topMostViewController(for: presentedController)
    } else if let navigationController = controller as? UINavigationController {
        guard let topController = navigationController.topViewController else {
            return navigationController
        }
        return topMostViewController(for: topController)
    } else if let tabController = controller as? UITabBarController {
        guard let topController = tabController.selectedViewController else {
            return tabController
        }
        return topMostViewController(for: topController)
    }
    return controller
}

// MARK: - Constants

struct Constants {
    static let youTubeURL = "https://youtube.com"
    static let alertTitle = "Enter the URL"
    static let alertMessage = "If nothing happens, the link might be broken"
    static let alertPlaceholder = "there should be a placeholder here"
    static let alertOK = "OK"
    static let alertCancel = "Cancel"
}

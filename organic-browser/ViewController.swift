import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, UITextFieldDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // WKWebViewのセットアップ
        webView.navigationDelegate = self

        // UITextFieldのセットアップ
        urlTextField.delegate = self
        // urlTextField.placeholder = "Enter URL and press Return" // Storyboardで設定済み
        // urlTextField.keyboardType = .URL // Storyboardで設定済み
        // urlTextField.autocapitalizationType = .none // Storyboardで設定済み
        // urlTextField.autocorrectionType = .no // Storyboardで設定済み

        // ボタンの初期状態
        updateNavigationButtons()

        // 広告ブロックのセットアップ
        setupAdBlocking()
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // キーボードを閉じる
        guard let urlString = textField.text, let url = URL(string: fixURLString(urlString)) else {
            showErrorAlert(message: "Invalid URL format.")
            return false
        }

        let request = URLRequest(url: url)
        webView.load(request)
        return true
    }

    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        updateNavigationButtons()
        // ページタイトルをurlTextFieldに表示することも可能
        // urlTextField.text = webView.url?.absoluteString
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        updateNavigationButtons()
        showErrorAlert(message: "Failed to load page: \(error.localizedDescription)")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        updateNavigationButtons()
        showErrorAlert(message: "Failed to start loading page: \(error.localizedDescription)")
    }

    // MARK: - Actions
    @IBAction func goBack(_ sender: UIButton) {
        if webView.canGoBack {
            webView.goBack()
        }
    }

    @IBAction func goForward(_ sender: UIButton) {
        if webView.canGoForward {
            webView.goForward()
        }
    }

    // MARK: - Helper Methods
    private func updateNavigationButtons() {
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
    }

    private func fixURLString(_ urlString: String) -> String {
        if urlString.hasPrefix("http://") || urlString.hasPrefix("https://") {
            return urlString
        }
        return "https://" + urlString // デフォルトでHTTPSを使用
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Ad Blocking (Initial Setup - Rules will be added later)
    func setupAdBlocking() {
        WKContentRuleListStore.default().lookUpContentRuleList(forIdentifier: "adBlockRules") { [weak self] (list, error) in
            if let error = error {
                print("Error looking up content rule list: \(error)")
                return
            }
            if let list = list {
                self?.webView.configuration.userContentController.add(list)
                print("Ad blocking rules applied.")
            } else {
                // ルールリストが存在しない場合、コンパイルを試みる (JSONファイルが必要)
                self?.compileAndApplyAdBlockRules()
            }
        }
    }

    func compileAndApplyAdBlockRules() {
        guard let rulePath = Bundle.main.path(forResource: "adblock-rules", ofType: "json") else {
            print("Ad block rules JSON file not found.")
            return
        }

        do {
            let ruleJSON = try String(contentsOfFile: rulePath, encoding: .utf8)
            WKContentRuleListStore.default().compileContentRuleList(
                forIdentifier: "adBlockRules",
                encodedContentRuleList: ruleJSON) { [weak self] (list, error) in
                if let error = error {
                    print("Error compiling content rule list: \(error)")
                    return
                }
                if let list = list {
                    self?.webView.configuration.userContentController.add(list)
                    print("Ad blocking rules compiled and applied.")
                }
            }
        } catch {
            print("Error reading ad block rules JSON: \(error)")
        }
    }
}
// 後で viewDidLoad 内で setupAdBlocking() を呼び出す必要があります。
// また、adblock-rules.json ファイルを作成し、プロジェクトに追加する必要があります。

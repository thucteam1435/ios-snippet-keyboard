import UIKit

struct Option: Codable {
    let type: String
    let price: String
    let warranty: String
}

struct Product: Codable {
    let title: String
    let options: [Option]
}

class KeyboardViewController: UIInputViewController {

    var keyValueData: [String: Product] = [:]
    var currentInput: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        loadJSON()
        setupKeyboard()
    }

    func loadJSON() {
        if let url = Bundle.main.url(forResource: "quickReplies", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                keyValueData = try JSONDecoder().decode([String: Product].self, from: data)
            } catch {
                print("Error loading JSON:", error)
            }
        }
    }

    var quickButton: UIButton?

    func setupKeyboard() {
        view.backgroundColor = .lightGray

        let button = UIButton(type: .system)
        button.setTitle("Quick Reply", for: .normal)
        button.addTarget(self, action: #selector(didTapQuickReply), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        view.addSubview(button)
        self.quickButton = button

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override func insertText(_ text: String) {
        currentInput += text
        textDocumentProxy.insertText(text)

        if let _ = keyValueData[currentInput] {
            quickButton?.isHidden = false
        } else {
            quickButton?.isHidden = true
        }
    }

    override func deleteBackward() {
        if !currentInput.isEmpty { currentInput.removeLast() }
        textDocumentProxy.deleteBackward()
        if let _ = keyValueData[currentInput] {
            quickButton?.isHidden = false
        } else {
            quickButton?.isHidden = true
        }
    }

    @objc func didTapQuickReply() {
        guard let proxy = textDocumentProxy as UITextDocumentProxy?,
              let product = keyValueData[currentInput] else { return }

        var message = "\(product.title):\n"
        for option in product.options {
            message += "\(option.type): Giá \(option.price), \(option.warranty.lowercased())\n"
        }

        proxy.insertText(message)
        currentInput = ""
        quickButton?.isHidden = true
    }
}


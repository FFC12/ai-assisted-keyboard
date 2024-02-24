import UIKit

enum KeyboardMode {
    case english
    case turkish
    case symbols
    case extraSymbols
}

enum UpperCaseState {
    case upper
    case lower
}

class KeyboardViewController: UIInputViewController {
    // Current mode of the keyboard
    var currentMode: KeyboardMode = .english
    // Current state of the keyboard
    var upperCaseState: UpperCaseState = .lower
    // API service instance
    let apiService = APIService()
    
    // Layouts for different keyboard modes
    let englishLayout = KeyboardLayout(
        row1: ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
        row2: ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
        row3: ["alt", "z", "x", "c", "v", "b", "n", "m", "<-"],
        row4: ["123", "TR", "Space", "Longer", "Fix", "Enter"]
    )
    
    let turkishLayout = KeyboardLayout(
        row1: ["q", "w", "e", "r", "t", "y", "u", "ı", "o", "p", "ğ", "ü"],
        row2: ["a", "s", "d", "f", "g", "h", "j", "k", "l", "ş", "i"],
        row3: ["alt", "z", "x", "c", "v", "b", "n", "m", "ö", "ç", "<-"],
        row4: ["123", "EN", "Boşluk", "Uzat", "Düzelt", "Enter"]
    )
    
    let symbolsLayout = KeyboardLayout(
        row1: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
        row2: ["-", "/", ":", ";", "(", ")", "'", "&", "\""],
        row3: ["#+=", ".", ",", "?", "!", "[", "]", "\\", "<-"],
        row4: ["ABC", ":)", "Space", ".", "@", "Enter"]
    )
    
    let extraSymbolsLayout = KeyboardLayout(
        row1: ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="],
        row2: ["_", "\\", "|", "~", "<", ">", "€", "£", "¥", "₺"],
        row3: ["123", ".", ",", "?", "!", "$", "<-"],
        row4: ["ABC", ":)", "Space", ".", "@", "Enter"]
    )
    
    // Dictionary to map keyboard mode to its respective layout
    lazy var layouts: [KeyboardMode: KeyboardLayout] = [
        .english: englishLayout,
        .turkish: turkishLayout,
        .symbols: symbolsLayout,
        .extraSymbols: extraSymbolsLayout
    ]
    
    // Stack view to hold the keyboard buttons
    var keyboardStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboard()
    }
    
    // Setup the keyboard UI
    func setupKeyboard() {
        keyboardStackView = UIStackView()
        keyboardStackView.axis = .vertical
        keyboardStackView.alignment = .fill
        keyboardStackView.distribution = .fillEqually
        keyboardStackView.spacing = 7
        keyboardStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(keyboardStackView)
        
        NSLayoutConstraint.activate([
            keyboardStackView.leftAnchor.constraint(equalTo: view.leftAnchor),
            keyboardStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            keyboardStackView.topAnchor.constraint(equalTo: view.topAnchor),
            keyboardStackView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        updateKeyboardLayout()
    }
    
    // Update the keyboard layout based on the current mode
    func updateKeyboardLayout() {
        keyboardStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let layout = layouts[currentMode] ?? englishLayout
        let rows = createRows(row1: layout.row1, row2: layout.row2, row3: layout.row3, row4: layout.row4)
        rows.forEach { keyboardStackView.addArrangedSubview($0) }
    }
    
    // Create rows of buttons for the keyboard
    func createRows(row1: [String], row2: [String], row3: [String], row4: [String]) -> [UIStackView] {
        return [row1, row2, row3, row4].map { row in
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.alignment = .fill
            stackView.distribution = .fillEqually
            stackView.spacing = 4
            
            row.forEach { key in
                let button = UIButton(type: .system)
                button.setTitle(key, for: [])
                button.backgroundColor = UIColor.gray
                button.setTitleColor(UIColor.white, for: [])
                button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
                button.layer.cornerRadius = 8
                button.addTarget(self, action: #selector(keyPressed(_:)), for: .touchUpInside)
                stackView.addArrangedSubview(button)
            }
            
            for case let button as UIButton in stackView.arrangedSubviews {
                button.heightAnchor.constraint(equalToConstant: 50).isActive = true
            }
            
            return stackView
        }
    }
    
    // Handle button press events
    @objc func keyPressed(_ sender: UIButton) {
        guard let key = sender.currentTitle else { return }
        if key == "Fix" || key == "FIX" || key == "fix" ||
            key == "Düzelt" || key == "DUZELT" || key == "düzelt" {
            handleCustomButtonPressed()
        } else if key == "Enter" || key == "ENTER" || key == "enter" {
            textDocumentProxy.insertText("\n")
        } else if key == "Space" || key == "SPACE" || key == "space" ||
                    key == "Boşluk" || key == "BOŞLUK" || key == "boşluk" {
            textDocumentProxy.insertText(" ")
        } else if key == "Longer" || key == "LONGER" || key == "longer" ||
                    key == "Uzat" || key == "UZAT" || key == "uzat" {
            textDocumentProxy.insertText("#longer")
            handleCustomButtonPressed()
        } else if key == "<-" {
            textDocumentProxy.deleteBackward()
        } else if key == "alt" || key == "ALT"{
            upperCaseState = upperCaseState == .lower ? .upper : .lower
            toggleCase()
        } else if key == "123" || key == "ABC" {
            toggleMode(to: key == "123" ? .symbols : .english)
        } else if key == "#+=" {
            toggleMode(to: .extraSymbols)
        } else if key == "TR" || key == "tr" || key == "EN" || key == "en" {
            toggleMode(to: key.uppercased() == "TR" ? .turkish : .english)
        } else {
            textDocumentProxy.insertText(key)
        }
    }
    
    // Handle the Fix/Düzelt button press
    func handleCustomButtonPressed() {
        guard let textProxy = textDocumentProxy as? UITextDocumentProxy else {
            return
        }
        let currentText = textProxy.documentContextBeforeInput ?? ""
        let request = APIRequest(data: currentText, service: "fix")
        
        apiService.makeRequestAPI(request: request) { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    for _ in 0..<currentText.count {
                        textProxy.deleteBackward()
                    }
                    textProxy.insertText(response.response)
                }
            case .failure(let error):
                print("API request error:", error)
            }
        }
    }

    // Toggle the case of all buttons
    func toggleCase() {
        for case let stackView as UIStackView in view.subviews {
            for case let arrangedSubView as UIStackView in stackView.arrangedSubviews {
                for case let button as UIButton in arrangedSubView.arrangedSubviews {
                    if let title = button.title(for: .normal) {
                        button.setTitle(upperCaseState == UpperCaseState.upper ? title.uppercased() : title.lowercased(), for: .normal)
                    }
                }
            }
        }
    }
    
    // Change the keyboard mode
    func toggleMode(to mode: KeyboardMode) {
        currentMode = mode
        updateKeyboardLayout()
    }
}

// Structure representing a keyboard layout
struct KeyboardLayout {
    let row1: [String]
    let row2: [String]
    let row3: [String]
    let row4: [String]
}

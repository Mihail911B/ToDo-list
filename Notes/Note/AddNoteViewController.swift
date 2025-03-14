//
//  AddNoteViewController.swift
//  Notes
//
//  Created by М Й on 13.03.2025.
//
import UIKit

class AddNoteViewController: UIViewController, UITextViewDelegate {
    
    // Замыкание для передачи созданной заметки обратно
    var onSaveNote: ((Note) -> Void)?
    

    private let noteTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 22)
        tv.textColor = .systemYellow
        tv.tintColor = .systemYellow
        tv.backgroundColor = .black
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemYellow]
        navigationController?.navigationBar.tintColor = .systemYellow
        
        setupViews()

        noteTextView.delegate = self
        
        updateAttributedText()
    }
    
    // Настройка размещения текстового поля на экране
    private func setupViews() {
        view.addSubview(noteTextView)
        NSLayoutConstraint.activate([
            noteTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            noteTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            noteTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            noteTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Обновление форматирования текста
    
    private func updateAttributedText() {

        let selectedRange = noteTextView.selectedRange
        let fullText = noteTextView.text ?? ""
        

        let lines = fullText.components(separatedBy: "\n")
        let result = NSMutableAttributedString()
        
        if !lines.isEmpty {
 
            let headerParagraph = NSMutableParagraphStyle()
            headerParagraph.paragraphSpacing = 10
            
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 22, weight: .black),
                .foregroundColor: UIColor.white,
                .paragraphStyle: headerParagraph
            ]
            let headerString = lines[0]
            let headerAttributed = NSAttributedString(string: headerString, attributes: headerAttributes)
            result.append(headerAttributed)
            

            if lines.count > 1 {
                result.append(NSAttributedString(string: "\n"))
                
                let descriptionAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 22),
                    .foregroundColor: UIColor.white
                ]

                let descriptionText = lines.dropFirst().joined(separator: "\n")
                let descriptionAttributed = NSAttributedString(string: descriptionText, attributes: descriptionAttributes)
                result.append(descriptionAttributed)
            }
        }
        
        // Временно отключаем делегат для предотвращения зацикливания вызовов
        noteTextView.delegate = nil
        noteTextView.attributedText = result
        noteTextView.selectedRange = selectedRange
        noteTextView.delegate = self
    }
    
    // Делегат UITextView: вызывается при изменении текста
    func textViewDidChange(_ textView: UITextView) {
        updateAttributedText()
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            autoSaveNote()
        }
    }
    
    // Метод автосохранения заметки (без отображения Alert)
    private func autoSaveNote() {
        let content = noteTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        // Если заметка пустая — не сохраняем
        if content.isEmpty {
            return
        }
        let lines = content.components(separatedBy: "\n")
        let noteTitle = lines.first ?? ""
        let noteDescription = lines.dropFirst().joined(separator: "\n")
        
        // Создаем новую заметку, передавая также уникальный идентификатор id
        let newNote = Note(id: UUID(),
                           title: noteTitle,
                           description: noteDescription,
                           creationDate: Date(),
                           completed: false)
        onSaveNote?(newNote)
    }
}

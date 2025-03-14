//
//  NoteDetailViewController.swift
//  Notes
//
//  Created by М Й on 13.03.2025.
//
import UIKit

class NoteDetailViewController: UIViewController {
    
    var note: Note?
    var onUpdateNote: ((Note) -> Void)?
    

    private let titleTextView: UITextView = {
        let tv = UITextView()
        tv.textColor = .white
        tv.backgroundColor = .black
        tv.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        return tv
    }()
    

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    

    private let descriptionTextView: UITextView = {
        let tv = UITextView()
        tv.textColor = .white
        tv.backgroundColor = .black
        tv.tintColor = .systemYellow
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
     
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(backButtonTapped))
        backButton.tintColor = .systemYellow
        navigationItem.leftBarButtonItem = backButton
        

        view.addSubview(titleTextView)
        view.addSubview(dateLabel)
        view.addSubview(descriptionTextView)
        

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
 
            titleTextView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            titleTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            

            dateLabel.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 15),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
 
            descriptionTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 15),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descriptionTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])
        

        if let note = note {
            titleTextView.text = note.title
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yy"
            dateLabel.text = formatter.string(from: note.creationDate)
            descriptionTextView.text = note.description
        }
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveUpdatedNote()
    }
    
    private func saveUpdatedNote() {
        let updatedTitle = titleTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let updatedDescription = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        

        guard !updatedTitle.isEmpty else { return }
        
        let updatedNote = Note(
            id: note?.id ?? UUID(),
            title: updatedTitle,
            description: updatedDescription,
            creationDate: note?.creationDate ?? Date(),
            completed: note?.completed ?? false
        )
        
        onUpdateNote?(updatedNote)
    }
}

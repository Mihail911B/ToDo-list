//
//  NoteTableViewCell.swift
//  Notes
//
//  Created by М Й on 14.03.2025.
//
import UIKit

class NoteTableViewCell: UITableViewCell {
    
    var toggleStatusCallback: ((Note) -> Void)?
    private var currentNote: Note?
    

    private let statusButton: TappableButton = {
        let button = TappableButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        return button
    }()
    
    private let headerLabel: UILabel = {
       let label = UILabel()
       label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
       label.textColor = .white
       label.numberOfLines = 0
       label.translatesAutoresizingMaskIntoConstraints = false
       return label
    }()
    
    private let descriptionLabel: UILabel = {
       let label = UILabel()
       label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
       label.textColor = .white
       label.numberOfLines = 0
       label.translatesAutoresizingMaskIntoConstraints = false
       return label
    }()
    
    private let dateLabel: UILabel = {
       let label = UILabel()
       label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
       label.textColor = .lightGray
       label.textAlignment = .left
       label.translatesAutoresizingMaskIntoConstraints = false
       return label
    }()
    
    private let separatorView: UIView = {
       let view = UIView()
       view.backgroundColor = .gray
       view.translatesAutoresizingMaskIntoConstraints = false
       return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
       super.init(style: style, reuseIdentifier: reuseIdentifier)
       backgroundColor = .black
       contentView.backgroundColor = .black
       
       contentView.addSubview(statusButton)
       contentView.addSubview(headerLabel)
       contentView.addSubview(descriptionLabel)
       contentView.addSubview(dateLabel)
       contentView.addSubview(separatorView)
       
       let horizontalInset: CGFloat = 16
       let verticalSpacing: CGFloat = 10
       
       NSLayoutConstraint.activate([

           statusButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalSpacing),
           statusButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalInset),
           statusButton.widthAnchor.constraint(equalToConstant: 30),
           statusButton.heightAnchor.constraint(equalToConstant: 30),
           

           headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalSpacing),
           headerLabel.leadingAnchor.constraint(equalTo: statusButton.trailingAnchor, constant: 12),
           headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalInset),
           

           descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: verticalSpacing),
           descriptionLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
           descriptionLabel.trailingAnchor.constraint(equalTo: headerLabel.trailingAnchor),
           
 
           dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: verticalSpacing),
           dateLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
           dateLabel.trailingAnchor.constraint(equalTo: headerLabel.trailingAnchor),
           dateLabel.heightAnchor.constraint(equalToConstant: 15),
           

           separatorView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
           separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
           separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
           separatorView.heightAnchor.constraint(equalToConstant: 0.8),
           separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -verticalSpacing)
       ])
       

       statusButton.addTarget(self, action: #selector(didTapStatusButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
       fatalError("init(coder:) не реализован")
    }
    
    override func prepareForReuse() {
       super.prepareForReuse()
       toggleStatusCallback = nil
       currentNote = nil
    }
    
    func configure(with note: Note) {
       currentNote = note
       
       if note.completed {
          statusButton.backgroundColor = .clear
          statusButton.layer.borderWidth = 2
          statusButton.layer.borderColor = UIColor.systemYellow.cgColor
          statusButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
          statusButton.tintColor = .systemYellow
       } else {
          statusButton.backgroundColor = .clear
          statusButton.layer.borderWidth = 2
          statusButton.layer.borderColor = UIColor.gray.cgColor
          statusButton.setImage(nil, for: .normal)
       }
       
       if note.completed {
          let attributes: [NSAttributedString.Key: Any] = [
             .strikethroughStyle: NSUnderlineStyle.single.rawValue,
             .font: UIFont.systemFont(ofSize: 22, weight: .bold),
             .foregroundColor: UIColor.white
          ]
          headerLabel.attributedText = NSAttributedString(string: note.title, attributes: attributes)
       } else {
          let attributes: [NSAttributedString.Key: Any] = [
             .font: UIFont.systemFont(ofSize: 22, weight: .bold),
             .foregroundColor: UIColor.white
          ]
          headerLabel.attributedText = NSAttributedString(string: note.title, attributes: attributes)
       }
       
       descriptionLabel.text = note.description
       
       let dateFormatter = DateFormatter()
       dateFormatter.dateFormat = "dd/MM/yy"
       dateLabel.text = dateFormatter.string(from: note.creationDate)
    }
    
    @objc private func didTapStatusButton() {
       guard let note = currentNote else { return }
       let toggledNote = Note(id: note.id,
                              title: note.title,
                              description: note.description,
                              creationDate: note.creationDate,
                              completed: !note.completed)
       currentNote = toggledNote
       self.configure(with: toggledNote)
       toggleStatusCallback?(toggledNote)
    }
}

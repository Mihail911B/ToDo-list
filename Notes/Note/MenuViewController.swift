//
//  ViewController.swift
//  Notes
//
//  Created by М Й on 13.03.2025.
//
import UIKit

// MARK: - TappableButton


// MARK: - Модель заметки с поддержкой Codable для локального сохранения

struct Note: Codable {
    let id: UUID
    let title: String
    let description: String
    let creationDate: Date
    let completed: Bool
}

// Структуры для обработки API-ответа (останутся для импорта, если локальных данных нет)
struct TodoResponse: Codable {
    let todos: [Todo]
}

struct Todo: Codable {
    let id: Int?
    let todo: String
    let completed: Bool
    let userId: Int?
}


// MARK: - Основной ViewController с локальным сохранением

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    // Переменная notes с наблюдателем, обновляющим количество задач
    private var notes: [Note] = [] {
        didSet {
            countLabel.text = "\(notes.count) Задач"
        }
    }
    private var filteredNotes: [Note] = []
    private var isSearching: Bool {
        return !(searchBar.text?.isEmpty ?? true)
    }
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Задачи"
        label.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        label.textColor = .white
        return label
    }()
    
    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Поиск задачи по заголовку"
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.barStyle = .black
        bar.searchBarStyle = .minimal
        return bar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .black
        let bgView = UIView(frame: table.bounds)
        bgView.backgroundColor = .black
        table.backgroundView = bgView
        table.separatorStyle = .none
        let footer = UIView(frame: .zero)
        footer.backgroundColor = .black
        table.tableFooterView = footer
        return table
    }()
    
    private let bottomContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "note.text")
        button.setImage(image, for: .normal)
        button.tintColor = .systemYellow
        button.backgroundColor = .clear
        button.layer.borderWidth = 0
        button.layer.cornerRadius = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: Жизненный цикл
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        tableView.register(NoteTableViewCell.self, forCellReuseIdentifier: "NoteCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        
        searchBar.delegate = self
        
        setupViews()
        
        // Загружаем заметки из локального хранилища. Если их нет – загружаем с API
        notes = NotesLocalStore.loadNotes()
        if notes.isEmpty {
            loadTodosFromAPI()
        } else {
            filteredNotes = notes
            tableView.reloadData()
        }
    }
    
    // MARK: Загрузка данных
    
    private func loadTodosFromAPI() {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            print("Неверный URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Ошибка загрузки данных: \(error)")
                return
            }
            guard let data = data else {
                print("Данные не получены")
                return
            }
            do {
                let todoResponse = try JSONDecoder().decode(TodoResponse.self, from: data)
                // Преобразуем задачи в объекты Note
                let importedNotes = todoResponse.todos.map { todo -> Note in
                    return Note(
                        id: UUID(),
                        title: todo.todo,
                        description: "",
                        creationDate: Date(),
                        completed: todo.completed
                    )
                }
                DispatchQueue.main.async {
                    self.notes = importedNotes
                    self.filteredNotes = importedNotes
                    self.tableView.reloadData()
                    NotesLocalStore.saveNotes(self.notes)
                }
            } catch {
                print("Ошибка парсинга JSON: \(error)")
            }
        }
        task.resume()
    }
    
    // MARK: Настройка интерфейса
    
    private func setupViews() {
        view.addSubview(headerLabel)
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(bottomContainer)
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            searchBar.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomContainer.topAnchor),
            
            bottomContainer.heightAnchor.constraint(equalToConstant: 70),
            bottomContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        bottomContainer.addSubview(addButton)
        bottomContainer.addSubview(countLabel)
        
        NSLayoutConstraint.activate([
            addButton.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: 10),
            addButton.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -16),
            addButton.widthAnchor.constraint(equalToConstant: 40),
            addButton.heightAnchor.constraint(equalToConstant: 40),
            
            countLabel.centerXAnchor.constraint(equalTo: bottomContainer.centerXAnchor),
            countLabel.centerYAnchor.constraint(equalTo: bottomContainer.centerYAnchor)
        ])
        
        addButton.addTarget(self, action: #selector(addNote), for: .touchUpInside)
    }
    
    // MARK: Действия
    
    @objc private func addNote() {
        let addNoteVC = AddNoteViewController()
        addNoteVC.onSaveNote = { [weak self] newNote in
            guard let self = self else { return }
            self.notes.append(newNote)
            self.filteredNotes = self.notes
            self.tableView.reloadData()
            NotesLocalStore.saveNotes(self.notes)
            self.navigationController?.popViewController(animated: true)
        }
        self.navigationController?.pushViewController(addNoteVC, animated: true)
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredNotes.count : notes.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as? NoteTableViewCell else {
            return UITableViewCell()
        }
        
        let note = isSearching ? filteredNotes[indexPath.row] : notes[indexPath.row]
        cell.configure(with: note)
        cell.backgroundColor = .black
        cell.contentView.backgroundColor = .black
        
        cell.toggleStatusCallback = { [weak self, weak cell] toggledNote in
            guard let self = self, let cell = cell else { return }
            if let index = self.notes.firstIndex(where: { $0.id == toggledNote.id }) {
                self.notes[index] = toggledNote
            }
            if self.isSearching,
               let filteredIndex = self.filteredNotes.firstIndex(where: { $0.id == toggledNote.id }) {
                self.filteredNotes[filteredIndex] = toggledNote
            }
            self.tableView.reloadData()
            NotesLocalStore.saveNotes(self.notes)
        }
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailVC = NoteDetailViewController()
        detailVC.note = isSearching ? filteredNotes[indexPath.row] : notes[indexPath.row]
        detailVC.onUpdateNote = { updatedNote in
            if self.isSearching {
                if let index = self.notes.firstIndex(where: { $0.id == updatedNote.id }) {
                    self.notes[index] = updatedNote
                }
                self.filteredNotes[indexPath.row] = updatedNote
            } else {
                self.notes[indexPath.row] = updatedNote
            }
            self.tableView.reloadData()
            NotesLocalStore.saveNotes(self.notes)
        }
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredNotes = searchText.isEmpty ? notes : notes.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        tableView.reloadData()
    }
    
    // MARK: Контекстное меню
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: {
            let detailVC = NoteDetailViewController()
            detailVC.note = self.isSearching ? self.filteredNotes[indexPath.row] : self.notes[indexPath.row]
            detailVC.preferredContentSize = CGSize(width: self.view.frame.width, height: 300)
            return detailVC
        }, actionProvider: { suggestedActions in
            let editAction = UIAction(title: "Редактировать",
                                      image: UIImage(systemName: "pencil")) { _ in
                let detailVC = NoteDetailViewController()
                detailVC.note = self.isSearching ? self.filteredNotes[indexPath.row] : self.notes[indexPath.row]
                detailVC.onUpdateNote = { updatedNote in
                    if self.isSearching {
                        if let index = self.notes.firstIndex(where: { $0.id == updatedNote.id }) {
                            self.notes[index] = updatedNote
                        }
                        self.filteredNotes[indexPath.row] = updatedNote
                    } else {
                        self.notes[indexPath.row] = updatedNote
                    }
                    self.tableView.reloadData()
                    NotesLocalStore.saveNotes(self.notes)
                }
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
            
            let deleteAction = UIAction(title: "Удалить",
                                        image: UIImage(systemName: "trash"),
                                        attributes: .destructive) { _ in
                if self.isSearching {
                    if let index = self.notes.firstIndex(where: { $0.id == self.filteredNotes[indexPath.row].id }) {
                        self.notes.remove(at: index)
                    }
                    self.filteredNotes.remove(at: indexPath.row)
                } else {
                    self.notes.remove(at: indexPath.row)
                }
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                NotesLocalStore.saveNotes(self.notes)
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        })
    }
    
    func tableView(_ tableView: UITableView,
                   willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
                   animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            if let detailVC = animator.previewViewController {
                self.show(detailVC, sender: self)
            }
        }
    }
}

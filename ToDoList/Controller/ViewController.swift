import UIKit

class ViewController: UIViewController
{
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var models = [ToDoListItem]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "To Do List"
        view.addSubview(tableView)
        getAllItems()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
        navigationItem.rightBarButtonItem?.tintColor = .label
    }
    
    @objc private func didTapAddButton()
    {
        let alert = UIAlertController(title: "Add New Item", message: "Enter new To Do List item!", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Add Item", style: .default, handler: { [weak self] _ in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else {
                return
            }
            self?.createItem(name: text)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Core Data
    
    func getAllItems()
    {
        do {
            models = try context.fetch(ToDoListItem.fetchRequest())
            DispatchQueue.main.async
            {
                self.tableView.reloadData()
            }
        } catch {
            // Throws error
        }
    }
    
    func createItem(name: String)
    {
        let newItem = ToDoListItem(context: context)
        newItem.name = name
        
        do {
            try context.save()
            getAllItems()
        } catch {
            // Throws error
        }
    }
    
    func deleteItem(item: ToDoListItem)
    {
        context.delete(item)
        
        do {
            try context.save()
            getAllItems()
        } catch {
            // Throws error
        }
    }
    
    func updateItem(item: ToDoListItem, newName: String)
    {
        item.name = newName
        
        do {
            try context.save()
            getAllItems()
        } catch {
            // Throws error
        }
    }
}

// MARK: - Tableview Code

extension ViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = models[indexPath.row]
        
        let actionSheet = UIAlertController(title: "Action", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Update", style: .default, handler: { _ in
            
            let alert = UIAlertController(title: "Edit Item", message: "Edit your To Do List item!", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text = item.name
            alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: { [weak self] _ in
                guard let field = alert.textFields?.first, let newName = field.text, !newName.isEmpty else {
                    return
                }
                self?.updateItem(item: item, newName: newName)
            }))
            self.present(alert, animated: true, completion: nil)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteItem(item: item)
        }))
        present(actionSheet, animated: true, completion: nil)
    }
}

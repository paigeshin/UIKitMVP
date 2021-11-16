# Model

```swift
//
//  User.swift
//  SwiftMVP
//
//  Created by paige on 2021/11/16.
//

struct User: Codable {
    let name: String
    let email: String
    let username: String
}
```

# UserPresenter

```swift
//
//  Presenter.swift
//  SwiftMVP
//
//  Created by paige on 2021/11/16.
//

// https://jsonplaceholder.typicode.com/users

import UIKit

protocol UserPresenterDelegate: AnyObject {
    func presentUsers(users: [User])
    func presentAlert(title: String, message: String)

}

typealias PresenterDelegate = UserPresenterDelegate & UIViewController

class UserPresenter {
    
    private weak var delegate: PresenterDelegate?
    
    public func getUsers() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else { return }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            do {
                let users = try JSONDecoder().decode([User].self, from: data)
                self.delegate?.presentUsers(users: users)
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    public func setViewDelegate(delegate: PresenterDelegate?) {
        self.delegate = delegate
    }
    
    public func didTap(user: User) {
        self.delegate?.presentAlert(title: user.name, message: "\(user.name) has an email of \(user.email) & a username of \(user.username)")
    }
}
```

# UserViewController

```swift
//
//  ViewController.swift
//  SwiftMVP
//
//  Created by paige on 2021/11/16.
//

import UIKit

class UsersViewController: UIViewController, UserPresenterDelegate, UITableViewDelegate, UITableViewDataSource {

    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let presenter = UserPresenter()
    
    private var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Users"
        
        // Table
        view.addSubview(tableView)

        tableView.delegate = self
        tableView.dataSource = self
        
        // Presenter
        presenter.setViewDelegate(delegate: self)
        presenter.getUsers()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].name
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Ask presenter to handle the tap
        presenter.didTap(user: users[indexPath.row])
    }
    
    // Presenter Delegate
    
    func presentUsers(users: [User]) {
        self.users = users
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    

}
```

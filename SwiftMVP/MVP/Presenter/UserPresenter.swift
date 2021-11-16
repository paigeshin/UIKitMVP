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

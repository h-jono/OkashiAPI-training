//
//  ViewController.swift
//  SearchOkashi
//
//  Created by 城野 on 2021/01/31.
//

import UIKit
import SafariServices

final class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchText.delegate = self
        searchText.placeholder = "お菓子の名前を入力してください"
        
        okashiTableView.dataSource = self
        okashiTableView.delegate = self
        
    }

    @IBOutlet private weak var searchText: UISearchBar!
    @IBOutlet private weak var okashiTableView: UITableView!
    
    private var okashiList: [(name: String, maker:String, link:URL, image:URL)] = []
    
    private func searchOkashi(keyword: String){
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        guard let req_url = URL(string: "https://sysbird.jp/toriko/api/?apikey=guest&format=json&keyword=\(keyword_encode)&max=10&order=r") else {
            return
        }
        
        let req = URLRequest(url: req_url)
        
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        let task = session.dataTask(with: req, completionHandler: {
            (data, response, error) in
            
            session.finishTasksAndInvalidate()
            
            do {
                let decoder = JSONDecoder()
                
                let json = try decoder.decode(ResultJson.self, from: data!)
                
                if let items = json.item {
                    self.okashiList.removeAll()
                    for item in items {
                        if let name = item.name, let maker = item.maker, let link = item.url, let image = item.image {
                            let okashi = (name, maker, link, image)
                            self.okashiList.append(okashi)
                        }
                    }
                }
                
                self.okashiTableView.reloadData()
                
                if let okashidbg = self.okashiList.first {
                    print("---------------")
                    print("okashiList[0] = \(okashidbg)")
                }
                
            } catch {
                print("エラーが出ました")
            }
            
        })
        
        task.resume()
    }
    
    
}


extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        
        if let searchWord = searchBar.text {
            searchOkashi(keyword: searchWord)
        }
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return okashiList.count
    
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "okashiCell", for: indexPath)
        
        cell.textLabel?.text = okashiList[indexPath.row].name
        
        if let imageData = try? Data(contentsOf: okashiList[indexPath.row].image) {
            
            cell.imageView?.image = UIImage(data: imageData)
        }
        
        return cell
        
    }

}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let safariViewController = SFSafariViewController(url: okashiList[indexPath.row].link)
        
        safariViewController.delegate = self
        
        present(safariViewController, animated: true, completion: nil)
    }
    
}

extension ViewController: SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
}

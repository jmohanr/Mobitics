//
//  MainPageViewController.swift
//  Mobitics
//
//  Created by Jagan on 26/12/19.
//  Copyright © 2019 Jagan. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAuth
class MainPageViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    private let cellID = "VideoDescriptionCell"
    
    lazy var fetchedhResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Videos.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.sharedInstance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    @IBOutlet weak var tableView:UITableView!
    
    //MARK:- ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let VideoDescriptionCell = UINib(nibName: cellID, bundle: nil)
        self.tableView.register(VideoDescriptionCell, forCellReuseIdentifier: cellID)
        updateTableContent()
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = fetchedhResultController.sections?.first?.numberOfObjects {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! VideoDescriptionCell
        if let photo = fetchedhResultController.object(at: indexPath) as? Videos {
            cell.setPhotoCellWith(video: photo)
        }
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = tableView.indexPathForSelectedRow
        if let video = fetchedhResultController.object(at: index ?? indexPath) as? Videos {
            let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
            if let vc = storyBoard.instantiateViewController(identifier: "VideoDetailsViewController") as? VideoDetailsViewController {
                vc.selectedVideos = video
                vc.videoCurrentIndexPath = index ?? indexPath
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    //MARK:- Fetching and storing data from core data
    func updateTableContent() {
        do {
            try self.fetchedhResultController.performFetch()
            print("COUNT FETCHED FIRST: \(String(describing: self.fetchedhResultController.sections?[0].numberOfObjects))")
        } catch let error  {
            print("ERROR: \(error)")
        }
        let service = APIClient()
        service.getDataWith { (result) in
            switch result {
            case .Success(let data):
                self.saveInCoreDataWith(array: data)
            case .Error(let message):
                print("\(message)")
            }
        }
    }
    
    //MARK:- Method to Save data into coredata
    private func saveInCoreDataWith(array: [[String: AnyObject]]) {
        let _ = array.map{self.createPhotoEntityFrom(dictionary: $0)} 
        do {
            try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
            
        } catch let error {
            print(error)
        }
    }
    private func createPhotoEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObject? {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        let request: NSFetchRequest<Videos> = Videos.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", dictionary["id"] as? String ?? "")
        do {
            let videos = try context.fetch(request)
            if let _ = videos.first {
                
            } else {
               if let photoEntity = NSEntityDescription.insertNewObject(forEntityName: "Videos", into: context) as? Videos {
                   photoEntity.url = dictionary["url"] as? String
                   photoEntity.thumb = dictionary["thumb"] as? String
                   photoEntity.id = dictionary["id"] as? String
                   photoEntity.title = dictionary["title"] as? String
                   photoEntity.videoDescription = dictionary["description"] as? String
                   photoEntity.videoDuration = "0"
                   return photoEntity
               }
            }
        } catch {
            print("Failed to fetch video:", error)
        }

        return nil
    }
}
extension MainPageViewController: NSFetchedResultsControllerDelegate {
    //MARK:- Methods to help reload tableview data and it will the immediate action when user updated or deleted any data
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    @IBAction func logOutButtonAction(_ sender: UIButton){
        do {
             try Auth.auth().signOut()
            UserDefaults.standard.set(false, forKey: "isLogin")
            performSegue(withIdentifier: "logOut", sender: nil)
        }
        catch let error as NSError {
            print (error.localizedDescription)
        }
        
    }
}

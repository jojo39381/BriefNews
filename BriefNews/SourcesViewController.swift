//
//  SourcesViewController.swift
//  BriefNews
//
//  Created by Joseph Yeh on 3/31/18.
//  Copyright © 2018 Joseph Yeh. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import ChameleonFramework
import Kingfisher
import CoreData
class SourcesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    let url = "https://newsapi.org/v2/sources?apiKey=37549870075446d3aefbbe3117adbad7"
    var imageUrl = "https://logo.clearbit.com"
    var params = ["country":"us"]
    override func viewDidLoad() {

        super.viewDidLoad()

        menuTable.dataSource = self
        menuTable.delegate = self
        loadItems()
        imageUrl = "https://logo.clearbit.com/"


        fetchSources(url:url, parameters:params)

        // Do any additional setup after loading the view.
    }
    
let loadview = UIView()
    func fetchSources(url:String, parameters:[String: Any]) {

        loadview.backgroundColor = UIColor.flatBlue()
        loadview.frame = view.frame
        view.addSubview(loadview)

        ProgressHUD.show()
        Alamofire.request(url, method:.get, parameters: parameters).responseJSON{

            response in
            if response.result.isSuccess {

                ProgressHUD.dismiss()
                self.loadview.alpha = 0.0

                let sourcesData : JSON = JSON(response.result.value!)
                print(sourcesData)
                self.updateSourcesData(json: sourcesData)


            }
            else{
                print(response.error)
            }




        }
    }

    


    var sources = [Source]()
    func updateSourcesData(json:JSON) {
        sources = [Source]()
        if let jsonSources = json["sources"].array  {
            for sources in jsonSources {
                imageUrl = ""
                let source = Source()
                if let sourceName = sources["name"].string  {
                    source.source = sourceName
                    source.sourceDescription = sources["description"].stringValue
                    source.imgUrl = modifyString(oldString:sources["url"].stringValue)
                    source.sourceID = sources["id"].stringValue
                    source.sourceDomain = sources["url"].stringValue
                    
                }

                else {
                    print("error")
                }
                self.sources.append(source)
            }
        }


collectionView.reloadData()


    }

    func modifyString(oldString:String) -> URL {
let newString = oldString.replacingOccurrences(of: "go.", with: "")
        if let finalString = newString.slice(from: "http://www.", to: "/") {
            let modifiedString = URL(string:"https://logo.clearbit.com/\(String(describing: finalString))")
            return modifiedString!
        }
        else if let finalString = newString.slice(from: "https://", to: "/") {
            let modifiedString = URL(string:"https://logo.clearbit.com/\(String(describing: finalString))")
            return modifiedString!
        }
        else {let modifiedString = URL(string:"https://logo.clearbit.com/\(String(describing: newString))")
            return modifiedString!
        }

    }














    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sources.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sourcesCell", for: indexPath) as! SourcesCell




        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowRadius = 3
        cell.layer.shadowOpacity = 3
        cell.layer.shadowOffset = CGSize(width: 3, height: 3)
        cell.layer.masksToBounds = false
        cell.sourceName.backgroundColor = UIColor.init(randomFlatColorExcludingColorsIn: [UIColor.flatWhite()])
        cell.sourceName.textColor = UIColor.init(contrastingBlackOrWhiteColorOn: cell.sourceName.backgroundColor, isFlat: true)

        if let imageSource = sources[indexPath.row].imgUrl {

            cell.logoImg.kf.setImage(with:imageSource, placeholder: #imageLiteral(resourceName: "picture.png"), options:[.processor(DefaultImageProcessor.default)])



            
        }
         cell.selectedButton.image = nil
        cell.sourceName.text = sources[indexPath.row].source
        cell.sourceID = sources[indexPath.row].sourceID
        if sourcesArray.count == 0 {
            cell.selectedButton.image = nil
        }
        else {
            if sourcesArray[0].sourcesID?.range(of: sources[indexPath.row].sourceID) != nil{
                cell.selectedButton.image = #imageLiteral(resourceName: "checked-2.png")
            }
            else {
                cell.selectedButton.image = nil
            }
        }

        return cell
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let numberOfCell: CGFloat = CGFloat(sources.count)   //you need to give a type as CGFloat
        let cellWidth = UIScreen.main.bounds.size.width / numberOfCell
        return CGSize(width:cellWidth, height:cellWidth)
    }

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
loadItems()
        let navController = self.tabBarController?.viewControllers![0] as! UINavigationController
        let vc = navController.topViewController as! ViewController
         vc.changed = true
        let nav2Controller = self.tabBarController?.viewControllers![1] as! UINavigationController
        let vc2 = nav2Controller.topViewController as! StoriesViewController
        vc2.changed = true
        if sourcesArray.count == 0 {
        let newItem = Sources(context:context)
        newItem.sourcesID = sources[indexPath.row].sourceID
            saveItems()
        }
        else {
            if sourcesArray[0].sourcesID?.range(of:",\(sources[indexPath.row].sourceID)") != nil {

                 let newSource = sourcesArray[0].sourcesID?.replacingOccurrences(of: ",\(sources[indexPath.row].sourceID)", with: "")
                    sourcesArray[0].setValue(newSource, forKey: "sourcesID")

                saveItems()

            }
            else if sourcesArray[0].sourcesID?.range(of:"\(sources[indexPath.row].sourceID),") != nil{
                var newSource = sourcesArray[0].sourcesID?.replacingOccurrences(of: "\(sources[indexPath.row].sourceID),", with: "")
                sourcesArray[0].setValue(newSource, forKey: "sourcesID")
                saveItems()

            }
            else if sourcesArray[0].sourcesID == sources[indexPath.row].sourceID{
                var newSource = sourcesArray[0].sourcesID?.replacingOccurrences(of: sources[indexPath.row].sourceID, with: "")
                sourcesArray[0].setValue(newSource, forKey: "sourcesID")
                saveItems()
            }
            else {

                var newSource = sourcesArray[0].sourcesID! + ",\(sources[indexPath.row].sourceID)"
                if newSource.first == "," {
                    newSource.removeFirst()
                }
                if newSource.last == "," {
                    newSource.removeFirst()
                }

                sourcesArray[0].setValue(newSource, forKey: "sourcesID")
                saveItems()
            }
        }
        loadItems()
        print(sourcesArray[0].sourcesID)
        collectionView.reloadItems(at: [indexPath])
    }






    func saveItems() {
        do {
            try context.save()
        }
        catch {
            print("error:\(error)")
        }

    }
let menuTable = UITableView()
    let blackView = UIView()
    @IBAction func filterButton(_ sender: Any) {

        if let window = UIApplication.shared.keyWindow {

            blackView.frame = window.frame
            blackView.backgroundColor = UIColor.flatBlack()
            blackView.alpha = 0.5
            blackView.addGestureRecognizer(UITapGestureRecognizer(target:self,action:#selector(self.dismissMenu)))
        let height:CGFloat = 480
        let y = window.frame.height - height
       self.menuTable.frame = CGRect(x:0,y:window.frame.height,width:window.frame.width,height:height)
            window.addSubview(blackView)
            window.addSubview(menuTable)

        UIView.animate(withDuration: 1.0) {
            self.menuTable.frame.origin.y = y
            self.blackView.alpha = 0.5
            self.menuTable.backgroundColor = UIColor.flatRed()

        }
        }
    }
    @objc func dismissMenu() {
        UIView.animate(withDuration: 1.0) {
            self.blackView.alpha = 0.0
            if let window = UIApplication.shared.keyWindow {
self.menuTable.frame.origin.y = window.frame.height
            }
        }
    }
    let categories = ["All", "General", "Health", "Entertainment", "Science", "Sports", "Technology", "Business"]
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cellIdentifier")
        }
        cell.textLabel?.text = categories[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if categories[indexPath.row] == "All" {
            params["category"] = ""
            
        }
        else {
            params["category"] = categories[indexPath.row]}
        dismissMenu()

        fetchSources(url: url, parameters: params)
        collectionView.reloadData()
    }













    var sourcesArray = [Sources]()
     func loadItems() {
        let request:NSFetchRequest<Sources> = Sources.fetchRequest()
        do{sourcesArray = try context.fetch(request)

        }
        catch{print("error")}

    }

}

extension String {

    func slice(from: String, to: String) -> String? {

        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}

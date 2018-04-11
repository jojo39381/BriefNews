//
//  ViewController.swift
//  BriefNews
//
//  Created by Joseph Yeh on 3/30/18.
//  Copyright © 2018 Joseph Yeh. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ChameleonFramework
import ProgressHUD
import Kingfisher
import CoreData
import FBAudienceNetwork



class StoriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FBNativeAdDelegate,FBNativeAdsManagerDelegate{
    let rowStep = 5

    var ads2Manager: FBNativeAdsManager!

    var ads2CellProvider: FBNativeAdTableViewCellProvider!
    
    func nativeAdsLoaded() {
        
        ads2CellProvider = FBNativeAdTableViewCellProvider(manager: ads2Manager, for: FBNativeAdViewType.genericHeight300)
        ads2CellProvider.delegate = self
        
        if tableView != nil {
            tableView.reloadData()
        }
    }
    override func viewDidLayoutSubviews() {
        let cell = tableView.dequeueReusableCell(withIdentifier: "storiesCell") as! StoriesCell
        cell.title.sizeToFit()
       
    }
    
    func nativeAdsFailedToLoadWithError(_ error: Error) {
        print("Error:\(error)")
    }
    func nativeAdDidClick(_ nativeAd: FBNativeAd) {
        print("Ad tapped: \(String(describing: nativeAd.title))")
    }
    
    
    
    
    
    var changed = false
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let articlesUrl = "https://newsapi.org/v2/everything"
    var params = ["apiKey":"37549870075446d3aefbbe3117adbad7",  "pageSize":"50","domains":"nytimes.com", "sortBy":"popularity"]
    let headers = ""
    /// The ad unit ID from the AdMob UI.
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        
        
        
        
        
        
        
        loadItems()
        if sourcesArray.count > 0 {
            if sourcesArray[0].sourcesID == "" {
                
                params["domains"] = "nytimes.com"
                
                
            }
            else {
                var domainsName = ""
                for domains in sourcesArray {
                    domainsName += "\(domains.sourcesDomain!),"
                }
                params["domains"] = domainsName

                print("parameters:\(params)")
            }
        }
        
        
        fetchArticles(url: articlesUrl, parameters: params)
        configureAdManagerAndLoadAds()

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func configureAdManagerAndLoadAds() {
        if ads2Manager == nil {
            ads2Manager = FBNativeAdsManager(placementID: "189849765075086_189849888408407", forNumAdsRequested: 5)
            ads2Manager.delegate = self as? FBNativeAdsManagerDelegate
            ads2Manager.loadAds()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        print(params)

        if changed == true {
            
            loadItems()
            if sourcesArray.count > 0 {
                if sourcesArray[0].sourcesID == "" {

                    params["domains"] = "nytimes.com"


                }
                else {
                    var domainsName = ""
                    for domains in sourcesArray {
                        domainsName += "\(domains.sourcesDomain!),"
                    }
                    params["domains"] = domainsName

                    print("parameters:\(params)")
                }
            }
            fetchArticles(url: articlesUrl, parameters: params)

            
            
            changed = false
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if ads2CellProvider != nil && ads2CellProvider.isAdCell(at: indexPath, forStride: UInt(rowStep)) {

        }
        else {
        let summaryVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "summary") as! SummaryViewController
        self.navigationController!.pushViewController(summaryVC, animated: true)
        
        
        
        
        if   let imageUrl = self.articles[indexPath.row - Int(indexPath.row / rowStep)].urlToImage {
            summaryVC.imageUrl = imageUrl
        }
        else {
            
        }
        summaryVC.titleText = self.articles[indexPath.row - Int(indexPath.row / rowStep)].title
        summaryVC.url = self.articles[indexPath.row - Int(indexPath.row / rowStep)].url
        
        }
        
        
        
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ads2CellProvider != nil {
            return Int(ads2CellProvider.adjustCount(UInt(self.articles.count), forStride: UInt(rowStep)))
        }
        else {
            return articles.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if ads2CellProvider != nil && ads2CellProvider.isAdCell(at: indexPath, forStride: UInt(rowStep)) {
            return ads2CellProvider.tableView(tableView, cellForRowAt: indexPath)
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "storiesCell") as! StoriesCell
            
            
            cell.title.text = self.articles[indexPath.row - Int(indexPath.row / rowStep)].title
            
            
            cell.descn.text = self.articles[indexPath.row - Int(indexPath.row / rowStep)].description
            
            
            
            cell.author.text = self.articles[indexPath.row - Int(indexPath.row / rowStep)].author
            
            if let url = self.articles[indexPath.row - Int(indexPath.row / rowStep)].urlToImage {
                cell.img.kf.setImage(with:url)
            }
            else if cell.img.image == nil {
                
                cell.imageWidth.constant = 0
                
                cell.titleWidth.constant = 350
                cell.descriptionWidth.constant = 350
                self.view.layoutIfNeeded()
                
            }
            
            
            
            
            return cell
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if ads2CellProvider != nil && ads2CellProvider.isAdCell(at: indexPath, forStride: UInt(rowStep)) {
            return ads2CellProvider.tableView(tableView, heightForRowAt: indexPath)
        }
        else {
            return 200
        }
        
    }
    let button = UIButton()
    let loadview = UIView()
    func fetchArticles(url:String, parameters:[String: Any]) {
        ProgressHUD.show()
        loadview.backgroundColor = UIColor.white
        loadview.frame = view.frame
        view.addSubview(loadview)
        
        Alamofire.request(url, method:.get, parameters: parameters).responseJSON {
            
            response in
            if response.result.isSuccess {
                
                ProgressHUD.dismiss()
                self.loadview.alpha = 0.0
                
                let articlesData : JSON = JSON(response.result.value!)
                print(articlesData)
                self.updateArticlesData(json: articlesData)
                
            }
            else {
                
                
                self.button.alpha = 1.9
                let width:CGFloat = 100
                self.button.frame = CGRect(x:self.view.frame.midX-width/2, y:self.view.frame.midY, width:width, height:50)
                self.button.backgroundColor = UIColor.flatBlue()
                self.button.setTitle("Try Again", for: .normal)
                self.button.addTarget(self, action: #selector(self.tryAgain), for: .touchUpInside)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    ProgressHUD.dismiss()
                    self.view.addSubview(self.button)
                    
                }
                
                
                
            }
            
            
            
            
        }
        
        
    }
    @objc func tryAgain() {
        button.alpha = 0.0
        fetchArticles(url: articlesUrl, parameters: params)
        
    }
    var articles = [Article]()
    
    func updateArticlesData(json: JSON){
        articles = [Article]()
        if let jsonArticles = json["articles"].array  {
            for eachArticle in jsonArticles {
                let article = Article()
                if let title = eachArticle["title"].string  {
                    article.author = eachArticle["source"]["name"].stringValue
                    article.description = (eachArticle["description"].stringValue).html2String
                    article.title = title
                    article.url = eachArticle["url"].stringValue
                    article.urlToImage = eachArticle["urlToImage"].url
                    
                    
                }
                    
                else {
                    
                    print("error")
                }
                self.articles.append(article)
            }
        }
        print(articles.count)
        self.tableView.reloadData()
        
        
        
    }
    
    
    
    var sourcesArray = [Sources]()
    func loadItems() {
        let request:NSFetchRequest<Sources> = Sources.fetchRequest()
        do{sourcesArray = try context.fetch(request)}
        catch{print("error")}
        
}

}

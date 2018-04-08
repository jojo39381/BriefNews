//
//  SummaryViewController.swift
//  BriefNews
//
//  Created by Joseph Yeh on 3/31/18.
//  Copyright © 2018 Joseph Yeh. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

class SummaryViewController: UIViewController {
    @IBOutlet weak var titleline: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var summary: UILabel!
    var imageUrl:URL?
    var url = ""
    var apiUrl = "https://apiv2.indico.io/summarization"
    var titleText = ""
    var params = [String:Any]()
    override func viewDidLoad() {
        super.viewDidLoad()
        sourceLabel.text = "From: \(url)"
        titleline.text = titleText
        let number:Int = 20
         params = [  "data":url , "api_key": "0e7139ddb5dae0f8423aa50a11a7bc47", "cloud": "", "top_n": number, "threshold":"" ] as [String : Any]
        if let imgurl = imageUrl {
            img.kf.setImage(with: imgurl)}
        fetchSummary(url: apiUrl, parameters: params)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    let button = UIButton()
    let loadview = UIView()
    func fetchSummary(url:String, parameters:Parameters) {
ProgressHUD.show()
        loadview.backgroundColor = UIColor.flatBlue()
        loadview.frame = view.frame
        view.addSubview(loadview)
        Alamofire.request(url, method:.post, parameters: parameters, encoding: JSONEncoding.default).responseJSON {

            response in
            if response.result.isSuccess {
ProgressHUD.dismiss()
                        self.loadview.alpha = 0.0
                let articlesData : JSON = JSON(response.result.value!)
                print(articlesData)
                self.updateSummary(json: articlesData)

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
            fetchSummary(url: apiUrl, parameters: params)
            
        }
        
    func updateSummary(json:JSON) {
        if let summaries = json["results"].array {
            var sum = ""
            for eachSummary in summaries {
                let text = eachSummary.stringValue
                sum += text

            }
            summary.text = sum
           
        }


    }
    @IBOutlet weak var sourceLabel: UILabel!
    @IBAction func fullArticle(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: url)!)
    }
}
extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension String {
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

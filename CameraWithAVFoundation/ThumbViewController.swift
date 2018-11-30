//
//  ThumbViewController.swift
//  CameraWithAVFoundation
//
//  Created by Nishant Kumar on 30/11/18.
//  Copyright © 2018 Gabriel Alvarado. All rights reserved.
//


@objc class ThumbViewController: UIViewController {
    
    var thumbLists:Array<UIImage> = []
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (thumbLists.count > 0) {
            let thumbWidth = 40
            let thumbHeight = 40
            
            var counter = 0
            let padding = 20
            
            // iterate and add to view
            for thumb in thumbLists {
                let uiImage = thumb
                let bgImage: UIImageView!
                bgImage = UIImageView(image: uiImage)
                bgImage.frame = CGRect(x: 10 + (counter % 2) * thumbWidth , y: thumbHeight * (counter / 2) + padding , width: thumbWidth, height: thumbHeight)
                
                // add to parent view
                self.scrollView.addSubview(bgImage)
                
                counter += 1
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func HandleShareThumbClick(_ sender: Any) {
    }
    
    @IBAction func HandleBackButtonClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleImageData(image: UIImage) {
        self.thumbLists.append(image)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

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
            var thumbWidth = CGFloat(280)
            var thumbHeight = CGFloat(280)
            
            var counter = 0
            let padding = CGFloat(20.0)
            
            // iterate and add to view
            for thumb in thumbLists {
                let uiImage = thumb
                let bgImage: UIImageView!
                bgImage = UIImageView(image: uiImage)
                bgImage.transform = CGAffineTransform(scaleX: -1, y: 1)
                if(uiImage.size.width > uiImage.size.height) {
                    thumbHeight = thumbWidth * (uiImage.size.height / uiImage.size.width)
                } else {
                    thumbWidth = thumbHeight * (uiImage.size.width / uiImage.size.height)
                }
                var leftPad = CGFloat(0.0)
                if(counter % 2 == 1) {
                    leftPad = 1.0
                }
                let divider = CGFloat(2.0)
                let xPos = CGFloat(padding + leftPad * thumbWidth)
                let rowNum = CGFloat(counter)
                let yPos = CGFloat(padding + thumbHeight * (rowNum / divider))
                bgImage.frame = CGRect(x:  xPos, y:  yPos, width: thumbWidth, height: thumbHeight)
                
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

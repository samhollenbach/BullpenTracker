import UIKit

@IBDesignable
class CINavigationBar: UINavigationBar {

    //set NavigationBar's height
    @IBInspectable var customHeight : CGFloat = 66

    @IBInspectable var tableSubview : Bool = false

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        return CGSize(width: UIScreen.main.bounds.width, height: customHeight)
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        //print("It called")
        
        for subview in self.subviews {
            var stringFromClass = NSStringFromClass(subview.classForCoder)
            if stringFromClass.contains("UIBarBackground") {
                if tableSubview{
                    subview.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: customHeight)
                }else{
                    subview.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: customHeight)
                }
                //subview.backgroundColor = .green
                subview.sizeToFit()
            }
            
            stringFromClass = NSStringFromClass(subview.classForCoder)
            
            //Can't set height of the UINavigationBarContentView
            if stringFromClass.contains("UINavigationBarContentView") {
                
                //Set Center Y
                //let centerY = (customHeight - subview.frame.height) / 2.0
                var centerY = (customHeight - subview.frame.height)
                if tableSubview{
                    centerY += 20
                }
                subview.frame = CGRect(x: 0, y: centerY, width: self.frame.width, height: subview.frame.height)
                subview.sizeToFit()
                
            }
        }
    }
}
   

   

/**
 This file is part of the SFFocusViewLayout package.
 (c) Sergio Fernández <fdz.sergio@gmail.com>

 For the full copyright and license information, please view the LICENSE
 file that was distributed with this source code.
 */

import UIKit
import SCLAlertView
import FirebaseDatabase

//protocol CollectionViewCellRender {
//
//    func setTitle(title: String)
//    func setDescription(description: String)
//    func setBackgroundImage(image: UIImage)
//}

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var offererBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    var parent:QuestionView!
    var offerer:UserModel?
    var indexPath:IndexPath!
    
    func setup(parent:QuestionView, option:OptionModel, indexPath:IndexPath){
        self.parent = parent
        self.option = option
        self.indexPath = indexPath
        likeBtn.setImage(img: #imageLiteral(resourceName: "like"), color: pinkColor)
    }
    
    var option:OptionModel!{
        didSet{
            descriptionTextView.text = option.oDescription
            setNumLikes(num: option.oVal)
            backgroundImageView.backgroundColor = getRandomColor()
            if let uid = option.oOfferBy{
                offerer = UserModel.getUser(uid: uid, getProfile: true)
                setProfile()
            }
            option.oRef.child("val").observe(.value, with: { (snapshot) in
                DispatchQueue.main.async {
                    if let num = snapshot.value as? Int{
                        self.setNumLikes(num: num)
                    }
                }
            })
        }
    }
    
    @IBAction func showAsker(_ sender: AnyObject) {
        offerer?.loadWallImg()
        parent.showUser(user: offerer)
    }
    
    func concludeQuestion(){
        print("conclude question")
    }
    
    @IBAction func likeAction(_ sender: AnyObject) {
        itemLiked()
    }
    
    func setNumLikes(num:Int){
        titleLabel.text = "Like: \(num)"
    }
    
    func itemLiked() {
        if let vc = self.parent.parent as? QuestionVC{
            likeBtn.setImage(img: #imageLiteral(resourceName: "like_filled"), color: pinkColor)
            parent.collectionView.isUserInteractionEnabled = false
            let optRef = option.oRef
            parent.currQuestion?.choose(val: optRef!.ref.key)
            optRef?.child("val").runTransactionBlock({ (data) -> FIRTransactionResult in
                if let num = data.value as? Int{
                    data.value = num + 1
                }
                return FIRTransactionResult.success(withValue: data)
            })
            vc.nextContent()
        }
        else if let vc = self.parent.parent as? InProgressVC{
            likeBtn.setImage(img: #imageLiteral(resourceName: "like_filled"), color: pinkColor)
            vc.conclude(OID: self.option.oRef.key, cell: self)
        }
        else if self.parent.parent is InCollectionVC{
            _ = SCLAlertView().showWarning("Warning", subTitle: "You cannot modify the question in collection")
        }
    }
    
    private func nextQuestion(){
        (self.parent.parent as! QuestionVC).nextContent()
    }
    
    func setProfile(){
        offererBtn.tintColor = .clear
        if let img = offerer?.profileImg{
            offererBtn.setImage(img, for: [])
            offererBtn.imageView?.contentMode = .scaleAspectFill
        }
        else if let uid = offerer?.uid{
            NotificationCenter.default.addObserver(self, selector: #selector(setProfile), name: NSNotification.Name(uid + "profile"), object: nil)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        offererBtn.board(radius: 18, width: 0, color: .white)
        board(radius: 3, width: 1, color: themeColor)
        likeBtn.setImage(img: #imageLiteral(resourceName: "like"), color: pinkColor)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        addGestureRecognizer(tap)
        descriptionTextView.isUserInteractionEnabled = false
    }
    
    func doubleTapped(){
        if parent.collectionView.visibleCells.first == self{
            itemLiked()
        }
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)

//        let featuredHeight: CGFloat = Constant.featuredHeight
//        let standardHeight: CGFloat = Constant.standardHegiht
//
//        let delta = 1 - (featuredHeight - frame.height) / (featuredHeight - standardHeight)
//
//        let minAlpha: CGFloat = Constant.minAlpha
//        let maxAlpha: CGFloat = Constant.maxAlpha
//
//        let alpha = maxAlpha - (delta * (maxAlpha - minAlpha))
//        overlayView.alpha = alpha
//
//        let scale = max(delta, 0.5)
//        titleLabel.transform = CGAffineTransform(scaleX: scale, y: scale)
//
//        descriptionTextView.alpha = delta
        
    }
}

//extension CollectionViewCell: CollectionViewCellRender {
//
//    func setTitle(title: String) {
//        self.titleLabel.text = title
//    }
//
//    func setDescription(description: String) {
//        self.descriptionTextView.text = description
//    }
//
//    func setBackgroundImage(image: UIImage) {
//        self.backgroundImageView.image = image
//    }
//
//}

extension CollectionViewCell {
    struct Constant {
        static let featuredHeight: CGFloat = 172
        static let standardHegiht: CGFloat = 52

        static let minAlpha: CGFloat = 0.3
        static let maxAlpha: CGFloat = 0.75
    }
}

extension CollectionViewCell : NibLoadableView { }

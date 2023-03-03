//
//  PageControllerImage.swift
//  AppliMeteo
//
//  Created by tplocal on 28/02/2023.
//

import UIKit

class PageControllerImage: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var pageControl = UIPageControl()
    var ville : String = ""
    var pages : [UIViewController] = []
    var currentIndex = 0
    let leContexte = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        self.pages.append(ViewControllerImage.getInstanceMessage(message : "Pas d'internet"))
        findPhotos(query: ville) { result in
            switch result{
            case .success(let photos):
                DispatchQueue.main.async {
                    if(photos.count == 0){
                        self.pages.remove(at: 0)
                        self.pages.append(ViewControllerImage.getInstanceMessage(message : "Pas de photos"))
                    }
                    else{
                        self.pages.remove(at: 0)
                        for photo in photos{
                            let image = UIImageView()
                            let url = URL(string: photo)
                            image.load(url: url!)
                            image.contentMode = .scaleAspectFit
                            self.pages.append(ViewControllerImage.getInstance(imageView: image))
                        }
                    }
                    self.setViewControllers([self.pages[0]], direction: .forward, animated: true, completion: nil)
                }
                break
            case .failure(let error):
                print(error)
            }
        }
        self.setViewControllers([self.pages[0]], direction: .forward, animated: true, completion: nil)
        // Do any additional setup after loading the view.
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        guard pages.count > previousIndex else {
            return nil
        }
        return pages[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < pages.count else {
            return nil
        }
        guard pages.count > nextIndex else {
            return nil
        }
        return pages[nextIndex]
    }

//    func presentationCount(for pageViewController: UIPageViewController) -> Int {
//        return pages.count
//    }
//
//    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
//        return 0
//    }

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let viewControllerIndex = pages.firstIndex(of: pendingViewControllers[0]) else {
            return
        }
        currentIndex = viewControllerIndex
        pageControl.currentPage = viewControllerIndex
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

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

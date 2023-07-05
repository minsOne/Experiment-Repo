//
//  ViewController.swift
//  Application
//
//  Created by minsOne on 2023/04/17.
//

import AppResources
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        NSDataAsset(name: "cross")
        let image = UIImage(named: "cross")
        let imgView = UIImageView(image: image)
        imgView.layer
        imgView.tintColor = .systemRed
        imgView.contentMode = .scaleAspectFit
        imgView.frame.size = .init(width: view.bounds.width, height: view.bounds.width)
//        print(imgView)
        view.addSubview(imgView)
        
        UIImage(data: <#T##Data#>)
        
        String(data: <#T##Data#>, encoding: .utf8)

        
//        let button = UIButton()
//        button.setTitle("Present", for: .normal)
//        button.titleLabel?.font = .systemFont(ofSize: 40)
//        button.setTitleColor(.white, for: .normal)
//        button.sizeToFit()
//        button.frame.origin = .init(x: 120, y: 200)
//        button.backgroundColor = .systemRed
//        view.addSubview(button)
//        view.backgroundColor = .systemBlue
//
//        button.addAction(.init(handler: { [weak self] _ in
//            guard let self else { return }
//            let vc = R.Storyboard.BViewController.instantiateViewController(withIdentifier: "BViewController") as? BViewController
//            vc.map { self.present($0, animated: true) }
//        }), for: .touchUpInside)
    }

}


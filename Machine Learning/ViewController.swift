//
//  ViewController.swift
//  Machine Learning
//
//  Created by skander bahri on 15/12/2019.
//  Copyright © 2019 skander bahri. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{

    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageView.image = userPickedImage
            guard let ciImage = CIImage(image: userPickedImage) else
            {
                fatalError("Could't convet the selected image into CIImage")
            }
            detect(image: ciImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage)
    {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else
        {
             fatalError("Loading Core ML model Failed. ")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else
            {
                fatalError("Casting result as VNClassificationObservation has been broken")
            }
            if let firstResult =  results.first
            {
                //self.navigationController?.navigationBar.barTintColor = UIColor.green
                var confienceValue = firstResult.confidence
                confienceValue = confienceValue * 100
                let percentage = Int(confienceValue)
                self.navigationItem.title = String(percentage) + "% " + firstResult.identifier
                if ( percentage > 60 )  {
                    self.navigationController?.navigationBar.barTintColor = UIColor.green
                }else if ( percentage < 60 ) && ( percentage > 45 ) {
                    self.navigationController?.navigationBar.barTintColor = UIColor.yellow
                }else{
                    self.navigationController?.navigationBar.barTintColor = UIColor.red
                }
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch  {
            print(error)
        }
    }
    
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem)
    {
        present(imagePicker, animated: true, completion: nil)
    }
}


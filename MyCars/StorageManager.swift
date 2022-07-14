

import Foundation
import CoreData
import UIKit

class StorageManager {
   
    private let context = SceneDelegate().appDelegate.persistentContainer.viewContext
    static let shared = StorageManager()

    func deleteInfo() {
        let fetchRequest = Trip.fetchRequest()
        guard let trips = try? context.fetch(fetchRequest) else { return }
        for trip in trips {
            context.delete(trip)
        }
        
        let fetchRequestCar = Car.fetchRequest()
        guard let cars = try? context.fetch(fetchRequestCar) else { return }
        for car in cars {
            car.timesDriven = 0
            car.rating = 0
        }
        guard ((try? context.save()) != nil) else { return }
    }
    
    func saveRate(_ car: Car) {
        if car.rating == 5 {
            car.rating = 0
        } else {
            car.rating += 1
        }
        guard ((try? context.save()) != nil) else { return }
    }
    
    func newTrip(_ car: Car) {
        car.timesDriven += 1
        car.lastStarted = Date()
        guard ((try? context.save()) != nil) else { return }
    }
    
    func saveDetailOfTrip(_ time: String, car: String, complition: (Trip) -> Void) {
        let object = Trip(context: context)
        object.timeUse = time
        object.car = car
        guard ((try? context.save()) != nil) else { return }
        complition(object)
    }
    
    func fetchRequestTrips(complition: (([Trip]?) -> Void)) {
        var trips = [Trip]()
        let fetchRequest = Trip.fetchRequest()
        let sort = NSSortDescriptor(key: "timeUse", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        do {
            trips = try context.fetch(fetchRequest)
            complition(trips)
        } catch let error as NSError {
            print(error.localizedDescription)
            complition(nil)
        }
    }
    
    func fetchRequestCar(complition: ([Car]?) -> Void) {
        let fetchRequest = Car.fetchRequest()
        do {
            let cars = try context.fetch(fetchRequest)
            complition(cars)
        } catch let error as NSError {
            print(error.localizedDescription)
            complition(nil)
        }
    }
    
    func saveContex() {
        guard ((try? context.save()) != nil) else { return }
    }
    
    func getDataFromFile(complition: ([Car]) -> Void) {
        var cars = [Car]()
        guard let pathToFile = Bundle.main.path(forResource: "data", ofType: "plist"),
              let dataArray = NSArray(contentsOfFile: pathToFile) else { return }
        
        for dictionary in dataArray {
            let car = Car(context: context)
            let carDictionary = dictionary as! [String : Any]
            car.mark = carDictionary["mark"] as? String
            car.model = carDictionary["model"] as? String
            car.rating = carDictionary["rating"] as! Double
            car.lastStarted = carDictionary["lastStarted"] as? Date
            car.timesDriven = carDictionary["timesDriven"] as! Int16
            car.myChoice = carDictionary["myChoice"] as! Bool
            
            let imageName = carDictionary["imageName"] as! String
            let image = UIImage(named: imageName)
            let imageData = image?.pngData()
            car.imageData = imageData
            
            if let colorDictionary = carDictionary["tintColor"] as? [String : Float] {
                car.tintColor = UIColor.getColor(colorDictionary: colorDictionary)
            }
            cars.append(car)
            StorageManager.shared.saveContex()
            complition(cars)
        }
    }
    
}

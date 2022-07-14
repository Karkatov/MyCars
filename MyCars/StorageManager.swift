

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
}

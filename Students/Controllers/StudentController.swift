//
//  StudentController.swift
//  Students
//
//  Created by Ben Gohlke on 6/17/19.
//  Copyright © 2019 Lambda Inc. All rights reserved.
//

import Foundation

enum TrackType: Int {
    case none
    case iOS
    case Web
    case UX
}

enum SortOptions: Int {
    case firstName
    case lastName
}

class StudentController {
    
    // MARK: - Properties
    
    private var students: [Student] = []
    
    private var persistentFileURL: URL? {
        guard let filePath = Bundle.main.path(forResource: "students", ofType: "json") else { return nil }
        return URL(fileURLWithPath: filePath)
    }
    
    func loadFromPersistentStore(completion: @escaping ([Student]?, Error?) -> Void) {
        
        let bgQeue = DispatchQueue(label: "studentQeue", attributes: .concurrent)
        bgQeue.async {
            // find students.json file path
            guard let url = self.persistentFileURL else {
                completion(nil, NSError())
                return }
            // read data from file into memory
            do {
                let data = try Data(contentsOf: url)
                // convert JSON data into Swift objects
                let decoder = JSONDecoder()
                let students = try decoder.decode([Student].self, from: data)
                // deliver the Swift objects to students array
                self.students = students
                completion(students, nil)
            } catch {
                NSLog("Error loading student data: \(error)")
                completion(nil, error)
            }
        }
        
        // signal the view controller that it should reload it's table
        
    }
    
    func filter(with trackType: TrackType, sortedBy sorter: SortOptions, completion: @escaping ([Student]) -> Void) {
        var updatedStudents: [Student]
        
        switch trackType {
        case .iOS:
            updatedStudents = students.filter { $0.course == "iOS" }
        case .Web:
            updatedStudents = students.filter { $0.course == "Web" }
        case .UX:
            updatedStudents = students.filter { $0.course == "UX" }
        default:
            updatedStudents = students
        }
        
        if sorter == .firstName {
            updatedStudents = updatedStudents.sorted { $0.firstName < $1.firstName }
        } else {
            updatedStudents = updatedStudents.sorted { $0.lastName < $1.lastName}
        }
        
        completion(updatedStudents)
    }
}

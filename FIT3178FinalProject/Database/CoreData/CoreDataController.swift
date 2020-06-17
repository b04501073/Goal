//
//  CoreDateController.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/6/7.
//  Copyright © 2020 李利元. All rights reserved.
//

import CoreData
import Foundation

class CoreDataController: NSObject, NSFetchedResultsControllerDelegate, CoreDataProtocol{
    
    var listeners = MulticastDelegate<CoreDataListener>()
    
    var persistantContainer: NSPersistentContainer
    
    var privateChildContext: NSManagedObjectContext!
    
    var allTodosFetchedResultsController: NSFetchedResultsController<Todo>?
    
    override init() {
        persistantContainer = NSPersistentContainer(name: "TodoDataModel")
        persistantContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data Stack: \(error)")
            }
        }
        
        super.init()
        
        
        let mainQueueContext = persistantContainer.viewContext
        privateChildContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateChildContext.parent = mainQueueContext
    }
    
    func addTodoItem(title: String) -> Todo{
        
        var todoitem: Todo!
        
        todoitem = Todo(context: persistantContainer.viewContext)
        todoitem?.title = title
        
        return todoitem
    }
    
    func deleteTodoItem(item: Todo){
        persistantContainer.viewContext.delete(item)
    }
    
    func addListener(listener: CoreDataListener) {
        listeners.addDelegate(listener)
        listener.onTodoListChange(todos: fetchAllTodos())
    }
    
    func removeListener(listener: CoreDataListener) {
        listeners.removeDelegate(listener)
    }
    
    func fetchAllTodos() -> [Todo] {
        if allTodosFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Todo> = Todo.fetchRequest()
//            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = []
            allTodosFetchedResultsController =
                NSFetchedResultsController<Todo>(fetchRequest: fetchRequest,
                                                 managedObjectContext: persistantContainer.viewContext,
                                                     sectionNameKeyPath: nil, cacheName: nil)
            allTodosFetchedResultsController?.delegate = self
            
            do {
                try allTodosFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request failed: \(error)")
            }
        }
        
        var todos = [Todo]()
        if allTodosFetchedResultsController?.fetchedObjects != nil {
            todos = (allTodosFetchedResultsController?.fetchedObjects)!
        }
        return todos
    }
    
    func cleanup() {
        if persistantContainer.viewContext.hasChanges {
            do {
                try persistantContainer.viewContext.save()
            } catch {
                fatalError("Failed to save data to Core Data: \(error)")
            }
        }
    }
    
    // MARK: - Fetched Results Delegate
    func controllerDidChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {
        listeners.invoke { (listener) in
            listener.onTodoListChange(todos: fetchAllTodos())
        }
    }
    
}

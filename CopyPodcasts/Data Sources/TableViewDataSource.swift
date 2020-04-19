//
//  TableViewDataSource.swift
//  HeadlinesApp
//
//  Created by Goodnews on 2018. 7. 10..
//  Copyright © 2018년 Mohammad Azam. All rights reserved.
//

import UIKit

final class TableViewDataSource<Cell: UITableViewCell, ViewModel>: NSObject, UITableViewDataSource {

    private var cellID: String!
    private var items: [ViewModel]!
    var configureCell: (Cell, ViewModel) -> ()

    init(cellID: String, items: [ViewModel], configureCell: @escaping (Cell, ViewModel) -> ()) {
        self.cellID = cellID
        self.items = items
        self.configureCell = configureCell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellID, for: indexPath) as! Cell
        let item = self.items[indexPath.row]
        self.configureCell(cell,item)
        return cell
    }


}


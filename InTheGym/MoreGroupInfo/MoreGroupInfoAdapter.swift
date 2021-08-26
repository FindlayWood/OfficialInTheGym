//
//  MoreGroupInfoAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class MoreGroupInfoAdapter: NSObject {
    var delegate: MoreGroupInfoProtocol!
    init(delegate: MoreGroupInfoProtocol) {
        self.delegate = delegate
    }
}
extension MoreGroupInfoAdapter: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            if delegate.membersLoaded() {
                return delegate.numberOfMembers()
            } else {
                return 1
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if delegate.isLeaderLoaded() {
                let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.cellID, for: indexPath) as! UserTableViewCell
                let leader = delegate.returnLeader()!
                cell.configureCell(with: leader)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: LoadingTableViewCell.cellID, for: indexPath) as! LoadingTableViewCell
                return cell
            }

        } else {
            if delegate.membersLoaded() {
                let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.cellID, for: indexPath) as! UserTableViewCell
                let member = delegate.getMember(at: indexPath)
                cell.configureCell(with: member)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: LoadingTableViewCell.cellID, for: indexPath) as! LoadingTableViewCell
                return cell
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if delegate.isLeaderLoaded() {
                return 80
            } else {
                return 60
            }
        } else {
            if delegate.membersLoaded() {
                return 80
            } else {
                return 60
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 20
        case 1:
            return 20
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0 :
            let label = UILabel()
            label.text = "Created By"
            label.font = .systemFont(ofSize: 10)
            label.backgroundColor = .offWhiteColour
            label.textAlignment = .center
            label.textColor = .darkGray
            return label
        case 1:
            let label = UILabel()
            label.text = "Members"
            label.font = .systemFont(ofSize: 10)
            label.backgroundColor = .offWhiteColour
            label.textAlignment = .center
            label.textColor = .darkGray
            return label
        default:
            return UIView()
        }
    }
}

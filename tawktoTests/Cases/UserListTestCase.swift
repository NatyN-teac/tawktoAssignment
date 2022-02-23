//
//  UserListTestCase.swift
//  tawktoTests
//
//  Created by mac on 08/02/2022.
//

import XCTest
@testable import tawkto

class UserListTestCase: XCTestCase {

    var sut: UserListViewModel!
    var users:[User]!
    
    override func setUp() {
        super.setUp()
        let dbService = MockDbService(helper: MockDbHelper())
        let networkManager = MockNetworkManager()
        let mockApiService = MockServiceManager()
        sut = UserListViewModel(serviceManager: mockApiService, networkMonitor: networkManager, dbService: dbService)
        users = [
            User(username: "john", id: 0, profileDetail: "detail profile", profileImageUrl: "www.google/image.png"),
            User(username: "Doe", id: 1, profileDetail: "detail profile", profileImageUrl: "www.google/image.png")
]
        
    }
    
    func test_dbIsInitialized(){
        XCTAssertNotNil(sut.dbServiceManager.dbHelper)
    }
    
    func test_networkCallToRemoteIsResponding(){
        XCTAssertEqual(sut.isLoading.value, false)
        sut.retrieveData(since: 0, size: 0)
        
        XCTAssertEqual(sut.usersList.value.count,0)
    }
    
    func test_userMapToMapperUser(){
        let user = users[0]
        let mappedUser = sut.mapUserToMappedUser(user: user, hasNote: false)
        let exactUser = MapperUserModel(id: user.id, username: user.username, profileURL: user.profileImageUrl, detail: user.profileDetail, hasNote: false)
        
        XCTAssertEqual(exactUser, mappedUser)
        
    }
    
    func test_mapMyData_resultInListOfTableviewProtocolData(){
        let mappedData = users.map { user in
            sut.mapUserToMappedUser(user: user, hasNote: true)
        }
        let result = sut.mapMyData(data: mappedData)
        XCTAssertEqual(result.count, 2)
        
        
    }

}

class MockDbHelper: DBHelper {
    
    
}

class MockDbService: DbService {
    var helper: DBHelper!
    override init(helper: DBHelper) {
        super.init(helper: helper)
        self.helper = helper
    }
}

class MockServiceManager: NetworkApiService {
    var mockData = User(username: "john", id: 1, profileDetail: "John is good developer", profileImageUrl: "www.google.com/png")
    
    override func fetchUserDataFromApi(since: Int, pageSize: Int?, isPagingEnabled: Bool? = false, completion: @escaping (Result<[User], NetworkError>) -> Void) {
        completion(.success([mockData]))
        
        }
}
    
class MockNetworkManager: NetworkMonitorVM {
        
    }



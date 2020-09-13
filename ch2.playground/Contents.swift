import UIKit

// MARK: code 2.1
protocol Logger {
    func log(_ message: String) -> Void
}

protocol Formatter {
    func format(_ message: String) -> String
}

class DefaultFormatter: Formatter {
    func format(_ message: String) -> String {
        // do something
        return message
    }
}

final class FileLogger1: Logger {
    
    private let formatter: Formatter
    
    init(_ formatter: Formatter) {
        self.formatter = formatter
    }
    
    func log(_ message: String) {
        let formattedMessage = self.formatter.format(message)
        print(formattedMessage)
    }
}

let logger = FileLogger1(DefaultFormatter())
logger.log("a message")


// MARK: code 2.2
final class FileLogger: Logger {
    
    private let formatter: Formatter
    private let logFilePath: String
    
    convenience init() {
        self.init(DefaultFormatter(), "")
    }
    
    required init(_ formatter: Formatter, _ logFilePath: String) {
        self.formatter = formatter
        self.logFilePath = logFilePath
    }
    
    func log(_ message: String) {
        let formattedMessage = self.formatter.format(message)
        file_put_contents(self.logFilePath, formattedMessage, FILE_APPEND)
    }
    
    private let FILE_APPEND: Int = 0
    private func file_put_contents(_ logFilePath: String, _ message: String, _ mode: Int) {
        
    }
}

// MARK: problem 3
class AppConfig {
    func get(_ name: String) -> String {
        return ""
    }
}

protocol Cache {
    func get(_ cacheKey: String) -> String
}

final class FileCache: Cache {
    private let directory: String

    // AppConfig 를 전달하는 대신 내부에서 사용하는 directory 정보만 전달한다.
    init(_ directory: String) {
        self.directory = directory
    }
    
    func get(_ cacheKey: String) -> String {
        //
        return ""
    }
}

let cache = FileCache(AppConfig().get("cache.directory"))

// MARK: code 2.3
final class ApiClient1 {
    private let username: String
    private let password: String
    
    init(_ username: String, _ password: String) {
        self.username = username
        self.password = password
    }
}

// MARK: code 2.4
final class Credentials {
    let username: String
    let password: String
    
    init(_ username: String, _ password: String) {
        self.username = username
        self.password = password
    }
}

final class ApiClient {
    private let credentials: Credentials
    
    init(_ credentials: Credentials) {
        self.credentials = credentials
    }
}

// MARK: problem 4
//final class TableInfo {
//    let host: String
//    let port: Int
//    let username: String
//    let password: String
//    let database: String
//    let table: String
//
//    init(host: String, port: Int, username: String, password: String, database: String, table: String) {
//        self.host = host
//        self.port = port
//        self.username = username
//        self.password = password
//        self.database = database
//        self.table = table
//    }
//}

struct TableInfo {
    let host: String
    let port: Int
    let username: String
    let password: String
    let database: String
    let table: String
}

final class MySQLTableGateway {
    private let tableInfo: TableInfo
    
    init(_ tableInfo: TableInfo) {
        self.tableInfo = tableInfo
    }
}

// MARK: code 2.5
final class ServiceLocator {
    private let services: [String: Any]
    
    init() {
        self.services = [
            "logger": FileLogger()
        ]
    }
    
    func get(_ identifier: String) throws -> Any {
        guard let service = self.services[identifier] else {
            throw LogicException("Unknown service", identifier)
        }
        
        return service
    }
}

class LogicException: Error {
    init(_ name: String, _ desc: String) {
    }
}


final class Request {
    func get(_ id: String) -> String {
        return ""
    }
}

final class Response {
    
}

final class EntityManager {
    func getRepository(_ user: String) -> UserRepository {
        return UserRepository()
    }
}

final class UserRepository {
    func getById(_ id: String) -> User {
        return User()
    }
}

final class User {
    
}

final class ResponseFactory {
    func create() -> Self {
        return self
    }
    
    func withContent(_ content: String, _ type: String) -> Response {
        return Response()
    }
}

final class TemplateRenderer {
    func render(_ name: String, _ dict: [String: User]) -> String {
        return ""
    }
}

// MARK: code 2.6
final class HomepageController1 {
    private let locator: ServiceLocator
    
    init(_ locator: ServiceLocator) {
        self.locator = locator
    }
    
    func execute(_ request: Request) throws -> Response {
        let entityManager = try (self.locator.get(String(describing: EntityManager.self)) as! EntityManager)
        let user = entityManager
            .getRepository(String(describing: User.self))
            .getById(request.get("userId"))

        let responseFactory = try (self.locator.get(String(describing: ResponseFactory.self)) as! ResponseFactory)
        let templateRenderer = try (self.locator.get(String(describing: TemplateRenderer.self)) as! TemplateRenderer)
        
        return responseFactory
            .create()
            .withContent(
                templateRenderer
                .render(
                    "homepage.html.twig",
                    ["user": user]
                ),
                "text/html"
        )
    }
}

// MARK: code 2.7
final class HomepageController2 {
    private let entityManager: EntityManager
    private let responseFactory: ResponseFactory
    private let templateRenderer: TemplateRenderer
    
    init(_ entityManager: EntityManager, _ responseFactory: ResponseFactory, _ templateRenderer: TemplateRenderer) {
        self.entityManager = entityManager
        self.responseFactory = responseFactory
        self.templateRenderer = templateRenderer
    }
    
    func execute(_ request: Request) -> Response {
        let user = self.entityManager
            .getRepository(String(describing: User.self))
            .getById(request.get("userId"))
        
        return self.responseFactory
            .create()
            .withContent(
                self.templateRenderer.render(
                    "homepage.html.twig",
                    ["user": user]
                ),
                "text/html"
        )
    }
}

// MARK: code 2.8
final class HomepageController {
    private let userRepository: UserRepository
    private let responseFactory: ResponseFactory
    private let templateRenderer: TemplateRenderer
    
    init(_ userRepository: UserRepository, _ responseFactory: ResponseFactory, _ templateRenderer: TemplateRenderer) {
        self.userRepository = userRepository
        self.responseFactory = responseFactory
        self.templateRenderer = templateRenderer
    }
    
    func execute(_ request: Request) -> Response {
        let user = self.userRepository.getById(request.get("userId"))
        
        return self.responseFactory
            .create()
            .withContent(
                self.templateRenderer.render(
                    "homepage.html.twig",
                    ["user": user]
                ),
                "text/html"
        )
    }
}

// MARK: code 2.9
final class BankStatementImporter {
    private let logger: Logger?
    
    init(_ logger: Logger? = nil) {
        self.logger = logger
    }
    
    func `import`(_ bankStatementFilePath: String) {
        // 입출금 내역서 파일을 가져온다.
        // 때때로 디버깅을 위해 로그를 남긴다
        
//        if let logger = self.logger {
//            logger.log("A message")
//        }
        // swift 에서는
        self.logger?.log("A message")
    }
}

let importer = BankStatementImporter()

// MARK: code 2.10
final class FileLogger10: Logger {
    init(_ logFilePath: String? = "/tmp/app.log") {
        
    }
    
    func log(_ message: String) {
        //
    }
}

let logger10 = FileLogger10()

// MARK: code 2.11
final class FileLogger11: Logger {
    private let logFilePath: String?
    
    init(_ logFilePath: String? = nil) {
        self.logFilePath = logFilePath
    }
    
    func log(_ message: String) {
        file_put_contents(
            self.logFilePath != nil ? self.logFilePath! : "/tmp/app.log",
            message,
            FILE_APPEND)
    }
    
    private let FILE_APPEND: Int = 0
    private func file_put_contents(_ logFilePath: String, _ message: String, _ mode: Int) {
        
    }
}

// MARK: code 2.12
final class BankStatementImporter12 {
    
    private var logger: Logger?
    
    init() {
        
    }
    
    func setLogger(_ logger: Logger) {
        self.logger = logger
    }
}

let importer12 = BankStatementImporter12()
importer12.setLogger(FileLogger())

// MARK: code 2.13
final class NullLogger: Logger {
    func log(_ message: String) {
        // 아무것도 하지 않는다.
    }
}

let importer13 = BankStatementImporter(NullLogger())

// MARK: code 2.14
final class Configuration {
    static func createDefault() -> Configuration {
        return Configuration()
    }
}

final class MetadataFactory {
    init(_ configuration: Configuration) {
        
    }
}

let metadataFactory = MetadataFactory(Configuration.createDefault())


// MARK: problem 6
protocol EventDispatcher {
    func dispatch(_ eventName: String) -> Void
}

final class CsvImporter {
    private let dispatcher: EventDispatcher

    init(_ dispatcher: EventDispatcher) {
        self.dispatcher = dispatcher
    }
}

// MARK: 2.15
class Cache15 {
    static func has(_ key: String) -> Bool {
        return true
    }
    
    static func get(_ key: String) -> [String] {
        return []
    }
}

final class DashboardController1 {
    func execute() -> Response {
        var recentPorts: [String] = []
        
        if Cache15.has("recent_ports") {
            recentPorts = Cache15.get("recent_ports")
        }
        
        return Response()
    }
}

protocol CacheProtocol {
    func has(_ key: String) -> Bool
    func get(_ key: String) -> [String]
}

final class DashboardController {
    private let cache: CacheProtocol
    
    init(_ cache: CacheProtocol) {
        self.cache = cache
    }
    
    func execute() -> Response {
        var recentPorts: [String] = []
        
        if self.cache.has("recent_ports") {
            recentPorts = self.cache.get("recent_ports")
        }
        
        return Response()
    }
}

// MARK: code 2.16
final class ResponseFactory16 {
    
}

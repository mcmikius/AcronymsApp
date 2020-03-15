import FluentPostgreSQL
import Vapor
import Leaf
import Authentication
import SendGrid
import Redis

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentPostgreSQLProvider())
    try services.register(LeafProvider())
    try services.register(AuthenticationProvider())
    try services.register(RedisProvider())
    try services.register(SendGridProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(SessionsMiddleware.self)
    services.register(middlewares)

    // Configure a SQLite database
//    let sqlite = try SQLiteDatabase(storage: .memory)

    // Register the configured PostgreSQL database to the database config.
    var databases = DatabasesConfig()
//    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
//    let username = Environment.get("DATABASE_USER") ?? "vapor"
//    let password = Environment.get("DATABASE_PASSWORD") ?? "password"
//    let databaseName: String
//    let databasePort: Int
//    if (env == .testing) {
//        databaseName = "vapor-test"
//        if let testPort = Environment.get("DATABASE_PORT") {
//            databasePort = Int(testPort) ?? 5433
//        } else {
//            databasePort = 5433
//        }
//    } else {
//        databaseName = Environment.get("DATABASE_DB") ?? "vapor"
//        databasePort = 5432
//    }
//
//    let databaseConfig = PostgreSQLDatabaseConfig(hostname: hostname, port: databasePort, username: username, database: databaseName, password: password)
    let databaseConfig: PostgreSQLDatabaseConfig
    if let url = Environment.get("DATABASE_URL") {
      databaseConfig = PostgreSQLDatabaseConfig(url: url)!
    } else {
      let hostname =
        Environment.get("DATABASE_HOSTNAME") ?? "localhost"
      let databaseName: String
      let databasePort: Int
      if env == .testing {
        databaseName = "vapor-test"
        if let testPort = Environment.get("DATABASE_PORT") {
          databasePort = Int(testPort) ?? 5433
        } else {
          databasePort = 5433
        }
      } else {
        databaseName = "vapor"
        databasePort = 5432
      }
        
      databaseConfig = PostgreSQLDatabaseConfig(hostname: hostname, port: databasePort, username: "vapor", database: databaseName, password: "password")
    }
    let database = PostgreSQLDatabase(config: databaseConfig)
    databases.add(database: database, as: .psql)
    var redisConfig = RedisClientConfig()
    if let redisHostname = Environment.get("REDIS_HOSTNAME") {
        redisConfig.hostname = redisHostname
    }
    let redis = try RedisDatabase(config: redisConfig)
    databases.add(database: redis, as: .redis)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(migration: UserType.self, database: .psql)
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Acronym.self, database: .psql)
    migrations.add(model: Category.self, database: .psql)
    migrations.add(model: AcronymCategoryPivot.self, database: .psql)
    migrations.add(model: Token.self, database: .psql)
    switch env {
    case .development, .testing:
        migrations.add(migration: AdminUser.self, database: .psql)
    default:
        break
    }
    migrations.add(model: ResetPasswordToken.self, database: .psql)
    migrations.add(migration: AddTwitterURLToUser.self, database: .psql)
    migrations.add(migration: MakeCategoriesUnique.self, database: .psql)
    services.register(migrations)

    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)
    
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
    config.prefer(RedisCache.self, for: KeyedCache.self)
    
    // Configure SendGrid
    guard let sendGridAPIKey = Environment.get("SENDGRID_API_KEY") else {
      fatalError("No Send Grid API Key specified")
    }
    let sendGridConfig = SendGridConfig(apiKey: sendGridAPIKey)
    services.register(sendGridConfig)
}

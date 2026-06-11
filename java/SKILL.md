---
name: java-claude-abliterated
description: Java dev stack with JDK 21, Maven, Gradle, Google Java Format, SpotBugs, PMD, Checkstyle, and JDT Language Server for Claude-driven Java development
---

# Java Dev Stack (claude-abliterated)

A complete Java development environment on top of claude-abliterated:rocky10 with 10 tools and recommended configs.

## Tool Index

| Tool | Package | Role |
|------|---------|------|
| **java** | JDK 21.0.5 | Core runtime (JVM, JIT, class loading) |
| **javac** | JDK 21.0.5 | Compiler (semantic analysis, type checking) |
| **mvn** | Maven 3.9.9 | Build tool & dependency manager (build, test, deploy) |
| **gradle** | Gradle 8.12 | Build tool & dependency manager (incremental builds) |
| **google-java-format** | 1.22.0 | Auto-formatter (consistent code layout, Google style) |
| **spotbugs** | SpotBugs 4.8.6 | Bug detector (static analysis, 200+ bug patterns) |
| **pmd** | PMD 7.5.0 | Static code analyzer (correctness, design, performance) |
| **checkstyle** | Checkstyle 10.20.1 | Code style linter (naming, imports, Javadoc, formatting) |
| **jdtls** | JDT Language Server 1.41.0 | Language server (intelli-sense, diagnostics, navigation) |
| **jdb** | JDK 21.0.5 | Debugger (breakpoints, step, inspect) |
| **spring** | Spring Boot 3.3.5 CLI | Spring Boot CLI (init, run, test, jar, war) |

---

## Core Toolchain

### java + javac (JDK 21.0.5)

```bash
# Compile and run
javac *.java                # compile all Java files
javac -d out *.java         # compile to output directory
java Main                   # run compiled class
java -cp out Main           # run with classpath

# Compilation options
javac -Xlint                # enable all warnings
javac -Xlint:unchecked      # unchecked type warnings
javac -Xlint:deprecation    # deprecated API warnings
javac --release 21           # cross-compile for Java 21
javac -sourcepath src        # set source path

# Module support
javac --module-path mod --modules myapp   # compile modules
java --module-path mod --module myapp     # run modules
```

### maven (3.9.9)

```bash
# Build and test
mvn compile                   # compile sources
mvn test                      # run all tests
mvn package                   # package JAR/WAR
mvn package -DskipTests       # package without tests
mvn install                   # install to local repo (~/.m2)
mvn clean                     # remove build artifacts

# Run specific goals
mvn clean compile test package   # full build cycle
mvn dependency:tree              # show dependency tree
mvn dependency:resolve           # resolve dependencies
mvn enforcer:enforce             # enforce build requirements

# Code quality
mvn checkstyle:check             # run checkstyle
mvn spotbugs:check               # run SpotBugs
mvn pmd:check                    # run PMD
mvn javadoc:javadoc              # generate Javadoc
mvn site                         # generate project site

# Generate project
mvn archetype:generate           # create new project
mvn archetype:generate -DgroupId=com.example -DartifactId=myapp
mvn archetype:generate -DarchetypeArtifactId=maven-archetype-quickstart
```

### gradle (8.12)

```bash
# Build and test
gradle build                    # compile, test, package
gradle test                     # run all tests
gradle clean                    # remove build artifacts
gradle clean build              # clean then build
gradle compileJava              # compile sources only
gradle compileTestJava           # compile test sources

# Incremental builds (Gradle's strength)
gradle build --parallel         # parallel tasks
gradle build --rerun-tasks      # ignore cache
gradle :module:build            # build specific module
gradle projects                 # list all modules

# Code quality
gradle checkstyleMain           # checkstyle on main sources
gradle spotbugsMain             # SpotBugs on main sources
gradle pmdMain                  # PMD on main sources
gradle javadoc                  # generate Javadoc

# Dependency management
gradle dependencies             # show dependencies
gradle dependencies --configuration runtimeClasspath
gradle buildScan:publish        # publish build scan
```

---

## Linting & Code Quality

### google-java-format (RECOMMENDED — use for all Java code)

The definitive Google Java code formatter. Zero-config, consistent output.

```bash
# Format all Java files in place
google-java-format -i **/*.java

# Check without modifying (dry-run)
google-java-format --dry-run --set-exit-if-changed **/*.java

# Format to stdout
google-java-format **/*.java > formatted.java

# Format specific files
google-java-format -i Main.java

# Use with import sorting
google-java-format --sort-imports **/*.java
```

#### google-java-format Rules

| Rule | Default | Purpose |
|------|---------|-------|
| **Column limit** | 100 chars | Line width |
| **Indent** | 2 spaces | Consistent indentation |
| **Braces** | K&R style | Kernighan & Ritchie |
| **Wrapping** | Google style | Smart line wrapping |

### checkstyle (code style linter)

```bash
# Run with recommended config
checkstyle -c /home/claudeuser/checkstyle.xml **/*.java

# Check and show all violations
checkstyle -c /home/claudeuser/checkstyle.xml -f xml **/*.java > checkstyle.xml

# Fail on errors
checkstyle -c /home/claudeuser/checkstyle.xml --failure-property "exitCode=1" **/*.java

# Custom config
checkstyle -c custom-checkstyle.xml src/main/java/

# Checkstyle XML output (CI-friendly)
checkstyle -f xml -c /home/claudeuser/checkstyle.xml **/*.java
```

#### checkstyle Rules (from checkstyle.xml)

| Rule | Severity | Purpose |
|------|----------|-------|
| **UpperCamelCase** | Warning | Class names |
| **lowerCamelCase** | Warning | Variable/method names |
| **UPPER_SNAKE_CASE** | Warning | Constants |
| **JavadocPackage** | Warning | Package-info.java required |
| **JavadocMethod** | Warning | Method Javadoc required |
| **JavadocType** | Warning | Type Javadoc required |
| **MemberName** | Warning | Field naming |
| **StaticVariableName** | Warning | Static field naming |
| **ImportOrder** | Warning | Import ordering |
| **EmptyLine** | Warning | Empty line rules |
| **LineLength** | Warning | Max 120 chars per line |
| **ArrayTypeStyle** | Warning | Array bracket style |

### spotbugs (bug detection)

```bash
# Run SpotBugs on compiled classes
spotbugs -textui -effort:max -xml **/*.class > spotbugs.xml

# Find bugs with high priority
spotbugs -textui -high -xml src/ > spotbugs-high.xml

# Check for specific bug categories
spotbugs -textui -exclude spotbugs-exclude.xml src/

# Generate HTML report
spotbugs -textui -html -output spotbugs.html src/
```

### PMD (static analysis)

```bash
# Run PMD on Java sources
pmd java -f text -R /home/claudeuser/pmd rulesets/java/quickstart.xml **/*.java

# Generate HTML report
pmd java -f html -R rulesets/java/quickstart.xml -d src/ > pmd-report.html

# Check for violations
pmd java -f text -R rulesets/java/bestpractices.xml -d src/
```

---

## Formatting & Style

### google-java-format (RECOMMENDED — use for all Java code)

```bash
# Format all files in place
google-java-format -i **/*.java

# Check mode (exit code 1 if changes needed)
google-java-format --dry-run --set-exit-if-changed **/*.java

# Format specific file
google-java-format -i Main.java

# Style output
google-java-format **/*.java
```

### Code Style Workflow

```bash
# Recommended: Google Java Format for formatting
google-java-format -i **/*.java

# Checkstyle for style rules
checkstyle -c /home/claudeuser/checkstyle.xml **/*.java

# SpotBugs for bug detection
spotbugs -textui -effort:max **/*.class

# Combined check
google-java-format --dry-run --set-exit-if-changed **/*.java && \
checkstyle -c /home/claudeuser/checkstyle.xml **/*.java && \
spotbugs -textui -high **/*.class
```

---

## Linting Philosophy — No Silent File-Touching

### Pre-loaded configs
All linting configs are pre-loaded in the container with best-practice rules.
They guide behavior but do NOT auto-run. Rules are documented in SKILL.md.

### What Claude should do:

**NEW files Claude writes:**
- Auto-lint with the project's primary linter before presenting to the user.
- Auto-fix is always safe here — these are Claude's own files.
- Use the project's config (`checkstyle.xml`, `google-java-format.jar`, etc.) — no need to ask.

**EXISTING code:**
- Do NOT touch unless Claude is explicitly tasked with it.
- If Claude notices linting issues while doing a task, report them and ask:
  "Found some linting issues in file.java, lint it?"
- Only apply linting/auto-fix when the user confirms (yes/no).
- Run lint read-only (check-only) first if the user is unsure.

### Key rules:
1. **Don't assume the user wants linting** — offer it, let them decide.
2. **Don't auto-lint on startup** — only report tool versions. Real linting
   happens when Claude is tasked with code quality work.
3. **Don't silently modify files** — ask before touching existing code.
   A file you didn't write is not yours to change without permission.
4. **Auto-lint what you write** — new files get auto-linted before presenting.

### Tool status:
```bash
# Linting tools are available and versions are reported on startup.
# They will NOT run automatically — they wait for Claude to be tasked.

google-java-format  → auto-lint NEW files before presenting
checkstyle          → pre-loaded config at /home/claudeuser/checkstyle.xml
spotbugs            → bug detection (run on demand)
pmd                 → static analysis (run on demand)
```

### Lint action decision matrix:

| Scenario | Action |
|------|-----|
| **Writing new code** | Auto-lint before presenting |
| **Fixing a bug in existing code** | Lint the file you're touching; report other issues |
| **Tasked with "clean up" / "lint"** | Run full lint on existing code (report first) |
| **User says "yes"** | Apply auto-fix to existing code |
| **User says "check first"** | Run check-only (read-only), present results |
| **Startup hook runs** | Report versions only — do NOT touch any files |

### Example interaction:

```
Claude notices: "checkstyle found 3 style issues in UserService.java"
Claude asks:    "Found some linting issues in UserService.java — lint it?"
User:           "yes"
Claude applies: google-java-format -i UserService.java
                checkstyle -c checkstyle.xml -f xml UserService.java

Claude notices: "2 potential null-pointer issues in UserRepository.java"
Claude asks:    "SpotBugs found potential null-pointer issues in UserRepository.java — run SpotBugs?"
User:           "check first"
Claude runs:    spotbugs -textui -high UserRepository.java (read-only, no modifications)
Claude presents: "2 SpotBugs issues found, no files modified. Apply fixes?"
```

---

## Debugging & Inspection

### jdb (Java Debugger)

```bash
# Interactive debugging
jdb Main                      # debug main class
jdb -classpath out Main       # debug with classpath
jdb -classpath out:lib/     # debug with external libraries

# Start jdb in debug mode
jdb -sourcepath src           # debug with source
jdb -J-Xdebug -J-Xrunjdpp:server=y,suspend=n,port=5005

# Debug commands
jdb> stop at Main.main        # set breakpoint
jdb> list                     # show current source
jdb> print variable           # print variable value
jdb> step                     # step into
jdb> next                     # step over
jdb> continue                 # continue to next breakpoint
jdb> where                    # show stack trace
jdb> threads                  # list all threads
jdb> clear Main.java:42       # clear specific breakpoint
```

### jdtls (JDT Language Server)

```bash
# Run standalone LSP
jdtls

# Check version
java -jar /home/claudeuser/java/jdtls/bin/jdtls --version

# Generate documentation
jdtls doc --index 0
```

---

## Testing

### JUnit 5 (with Maven/Gradle)

```bash
# Run all tests
mvn test
gradle test

# Run specific test class
mvn test -Dtest=MainTest
gradle test --tests "com.example.MainTest"

# Run with verbose output
mvn test -Dtest=MainTest -X
gradle test --info

# Coverage (with JaCoCo)
mvn test jacoco:report
gradle jacocoTestReport
```

### Writing Java tests

```java
// src/test/java/com/example/MainTest.java
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class MainTest {
    @Test
    void addsTwoNumbers() {
        assertEquals(5, add(2, 3));
    }

    @Test
    void handlesNegativeNumbers() {
        assertEquals(-1, add(-1, 0));
    }

    @Test
    void handlesZeros() {
        assertEquals(0, add(0, 0));
    }
}
```

---

## Code Generation & Project Setup

### Maven Archetype (project generation)

```bash
# Generate from archetype
mvn archetype:generate \
    -DgroupId=com.example \
    -DartifactId=myapp \
    -DarchetypeArtifactId=maven-archetype-quickstart \
    -DinteractiveMode=false

# Add dependencies
mvn dependency:add -Dartifact=com.google.guava:guava:33.0.0-jre
mvn dependency:remove -Dartifact=junit:junit

# Upgrade dependencies
mvn versions:display-dependency-updates
mvn versions:display-plugin-updates
```

### Gradle Dependencies

```bash
# Add dependencies to build.gradle
# implementation 'com.google.guava:guava:33.0.0-jre'
# testImplementation 'org.junit.jupiter:junit-jupiter:5.10.0'

# Show dependency tree
gradle dependencies

# Apply plugins
gradle plugin:apply -Dplugin=java-library

# Generate wrapper
gradle wrapper
```

---

## Code Coverage

### JaCoCo (with Maven/Gradle)

```bash
# Maven + JaCoCo
mvn test jacoco:report          # generate coverage
mvn jacoco:check                # check coverage thresholds
mvn jacoco:check -Djacoco.minCoverage=0.8  # min 80%

# Gradle + JaCoCo
gradle jacocoTestReport         # generate HTML/XML coverage
gradle jacocoTestCoverage       # print coverage to console
gradle jacocoCheck              # fail if below threshold
```

---

## Spring Boot

### Spring Boot CLI (`spring`)

The Spring Boot CLI provides commands for creating, running, and packaging Spring Boot applications.

```bash
# Create a new Spring Boot project
spring init --build=maven --java-version=21 --dependencies=web,actuator,validation myapp

spring init --build=gradle --java-version=21 \
    --dependencies=web,data-jpa,security,actuator,test,validation \
    --groupId=com.example --artifactId=myapp

# Run a Spring Boot application (from JAR or sources)
spring run myapp.jar
spring run src/main/java/com/example/Application.java
spring run .                          # run from current directory

# Package application
spring jar myapp.jar com.example.Application
spring boot myapp.jar                 # build Spring Boot JAR

# Inspect application
spring status                         # check running applications
spring help                           # list all commands
spring help run                       # help for run command
```

### Spring Boot Starters (Common Modules)

| Starter | Dependency | Purpose |
|-------|-----|--|
| **spring-boot-starter-web** | `org.springframework.boot:spring-boot-starter-web` | Web/REST applications (Spring MVC, Tomcat) |
| **spring-boot-starter-data-jpa** | `org.springframework.boot:spring-boot-starter-data-jpa` | JPA with Hibernate |
| **spring-boot-starter-security** | `org.springframework.boot:spring-boot-starter-security` | Authentication & authorization |
| **spring-boot-starter-test** | `org.springframework.boot:spring-boot-starter-test` | JUnit, Mockito, Hamcrest, Testcontainers |
| **spring-boot-starter-validation** | `org.springframework.boot:spring-boot-starter-validation` | Bean Validation (Jakarta Validation) |
| **spring-boot-starter-actuator** | `org.springframework.boot:spring-boot-starter-actuator` | Production monitoring (health, metrics) |
| **spring-boot-starter-cache** | `org.springframework.boot:spring-boot-starter-cache` | Spring caching abstraction |
| **spring-boot-starter-data-redis** | `org.springframework.boot:spring-boot-starter-data-redis` | Redis connectivity |
| **spring-boot-starter-mail** | `org.springframework.boot:spring-boot-starter-mail` | Email support (Jakarta Mail) |
| **spring-boot-starter-aop** | `org.springframework.boot:spring-boot-starter-aop` | Aspect-Oriented Programming |
| **spring-boot-starter-data-mongodb** | `org.springframework.boot:spring-boot-starter-data-mongodb` | MongoDB persistence |
| **spring-boot-starter-webflux** | `org.springframework.boot:spring-boot-starter-webflux` | Reactive web (WebFlux, Netty) |

### Spring Boot Annotations Reference

| Annotation | Purpose | Location |
|------|-----|-----|
| **@SpringBootApplication** | Marks the main application class | Class level |
| **@RestController** | REST controller (combines @Controller + @ResponseBody) | Class level |
| **@Controller** | MVC controller | Class level |
| **@Service** | Business logic layer | Class level |
| **@Repository** | Data access layer (adds exception translation) | Class/Interface level |
| **@Autowired** | Dependency injection (constructor, field, method) | Field/Constructor/Method |
| **@Component** | Generic Spring-managed bean | Class level |
| **@Entity** | JPA entity | Class level |
| **@Configuration** | Bean configuration class | Class level |
| **@Bean** | Declares a bean in a @Configuration class | Method level |
| **@Value** | Injects property values (supports SpEL) | Field/Parameter |
| **@PostMapping** | HTTP POST handler | Method level |
| **@GetMapping** | HTTP GET handler | Method level |
| **@PutMapping** | HTTP PUT handler | Method level |
| **@DeleteMapping** | HTTP DELETE handler | Method level |
| **@PatchMapping** | HTTP PATCH handler | Method level |
| **@RequestBody** | Deserialize request body to object | Method parameter |
| **@ResponseBody** | Serialize return value to response | Method return |
| **@PathVariable** | Extract URL path variable | Method parameter |
| **@RequestParam** | Extract query parameter | Method parameter |
| **@RequestHeader** | Extract HTTP header | Method parameter |
| **@ModelAttribute** | Bind form data to object | Method parameter |
| **@Valid** / **@Validated** | Trigger validation | Method parameter |
| **@Transactional** | Transaction management | Method/Class level |
| **@Primary** | Primary bean when multiple implementations | Bean declaration |
| **@Profile** | Activate bean only for specific profile | Bean declaration |
| **@ComponentScan** | Auto-scan for components | Configuration class |
| **@EnableJpaRepositories** | Enable Spring Data JPA | Configuration class |
| **@EntityListeners** | Add JPA lifecycle listeners | Entity class |
| **@ManyToOne** / **@OneToMany** | JPA relationships | Field level |
| **@JoinColumn** | Define join column | Field level |
| **@Column** | Define column mapping | Field level |
| **@Id** | Primary key | Field level |
| **@GeneratedValue** | Auto-generated ID | Field level |
| **@JsonIgnore** / **@JsonProperty** | JSON serialization control | Field level |
| **@Scheduled** | Scheduled task execution | Method level |

### Spring Boot REST Controller Patterns

```java
// src/main/java/com/example/controller/UserController.java
@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserService userService;

    // GET /api/users
    @GetMapping
    public List<User> getAll() {
        return userService.findAll();
    }

    // GET /api/users/{id}
    @GetMapping("/{id}")
    public ResponseEntity<User> getById(@PathVariable Long id) {
        User user = userService.findById(id);
        return ResponseEntity.ok(user);
    }

    // POST /api/users
    @PostMapping
    public ResponseEntity<User> create(@Valid @RequestBody UserRequest request) {
        User user = userService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(user);
    }

    // PUT /api/users/{id}
    @PutMapping("/{id}")
    public ResponseEntity<User> update(@PathVariable Long id,
                                        @Valid @RequestBody UserRequest request) {
        User user = userService.update(id, request);
        return ResponseEntity.ok(user);
    }

    // DELETE /api/users/{id}
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        userService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
```

### Spring Boot Service Layer

```java
// src/main/java/com/example/service/UserService.java
@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ModelMapper modelMapper;

    public List<User> findAll() {
        return userRepository.findAll();
    }

    public User findById(Long id) {
        return userRepository.findById(id)
            .orElseThrow(() -> new NotFoundException("User not found: " + id));
    }

    @Transactional
    public User create(UserRequest request) {
        User user = modelMapper.map(request, User.class);
        // Business logic
        user.setActive(true);
        return userRepository.save(user);
    }

    @Transactional
    public User update(Long id, UserRequest request) {
        User user = findById(id);
        modelMapper.map(request, user);
        return userRepository.save(user);
    }

    @Transactional
    public void delete(Long id) {
        userRepository.deleteById(id);
    }
}
```

### Spring Boot Repository Layer

```java
// src/main/java/com/example/repository/UserRepository.java
public interface UserRepository extends JpaRepository<User, Long> {

    // Derived queries
    List<User> findByLastName(String lastName);
    List<User> findByActiveTrue();
    Optional<User> findByEmail(String email);

    // Custom query
    @Query("SELECT u FROM User u WHERE u.email = :email")
    User findByEmailCustom(@Param("email") String email);

    // Custom query with JPQL
    @Modifying
    @Query("UPDATE User u SET u.active = false WHERE u.lastLogin < :date")
    int deactivateOldUsers(@Param("date") LocalDateTime date);

    // Count queries
    long countByActiveTrue();

    // Exists queries
    boolean existsByEmail(String email);

    // Sorting and pagination
    Page<User> findByActiveTrue(Pageable pageable);
}
```

### Spring Boot Application Configuration

```yaml
# src/main/resources/application.yml
server:
  port: 8080
  servlet:
    context-path: /api

spring:
  application:
    name: myapp
  datasource:
    url: jdbc:postgresql://localhost:5432/mydb
    username: ${DB_USER}
    password: ${DB_PASSWORD}
    driver-class-name: org.postgresql.Driver
    hikari:
      maximum-pool-size: 10
      minimum-idle: 5

  jpa:
    hibernate:
      ddl-auto: update          # validate, update, create, create-drop
    show-sql: false
    properties:
      hibernate:
        format_sql: true
        dialect: org.hibernate.dialect.PostgreSQLDialect

  data:
    redis:
      host: localhost
      port: 6379

  jackson:
    serialization:
      write-dates-as-timestamps: false
    default-property-inclusion: non_null

logging:
  level:
    com.example: DEBUG
    org.springframework: INFO
    org.hibernate: WARN

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  endpoint:
    health:
      show-details: when_authorized
```

### Spring Boot Profiles

```yaml
# src/main/resources/application-dev.yml (development)
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/mydb_dev
  jpa:
    hibernate:
      ddl-auto: create
  sql:
    init:
      mode: always

# src/main/resources/application-prod.yml (production)
spring:
  datasource:
    url: jdbc:postgresql://prod-host:5432/mydb
  jpa:
    hibernate:
      ddl-auto: validate

# src/main/resources/application-test.yml (testing)
spring:
  datasource:
    url: jdbc:h2:mem:testdb
  jpa:
    hibernate:
      ddl-auto: create-drop
```

```java
// Activate profiles
@SpringBootApplication
@Profile("dev")   // or @Profile("prod") or @Profile("test")
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

### Spring Boot Actuator (Production Monitoring)

```java
// Actuator endpoints available at /actuator/*
// GET  /actuator/health       — Application health
// GET  /actuator/info         — Application info
// GET  /actuator/metrics      — Metrics
// GET  /actuator/metrics/jvm.memory.used  — Specific metric
// POST /actuator/refresh      — Refresh context
// POST /actuator/loggers      — Manage log levels
// GET  /actuator/prometheus   — Prometheus metrics
```

```yaml
# Configure actuator in application.yml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus,loggers,shutdown
  endpoint:
    health:
      show-components: always
      show-details: always
    shutdown:
      enabled: true   # enable /actuator/shutdown POST
```

### Spring Boot Validation

```java
// Request DTO with validation
public class UserRequest {
    @NotBlank(message = "Name is required")
    @Size(min = 2, max = 100)
    private String name;

    @NotBlank(message = "Email is required")
    @Email(message = "Email must be valid")
    private String email;

    @Min(value = 18, message = "Must be at least 18")
    @Max(value = 120, message = "Must be at most 120")
    private Integer age;

    @NotNull(message = "Role is required")
    private String role;
}

// Controller with @Valid
@PostMapping
public ResponseEntity<User> create(@Valid @RequestBody UserRequest request) {
    // Spring validates and throws MethodArgumentNotValidException on failure
    User user = userService.create(request);
    return ResponseEntity.status(HttpStatus.CREATED).body(user);
}
```

### Spring Boot Test Patterns

```java
// src/test/java/com/example/controller/UserControllerTest.java
@WebMvcTest(UserController.class)
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    @Test
    void shouldReturnAllUsers() throws Exception {
        List<User> users = Arrays.asList(new User(1L, "Alice"), new User(2L, "Bob"));
        when(userService.findAll()).thenReturn(users);

        mockMvc.perform(get("/api/users"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$").isArray())
            .andExpect(jsonPath("$[0].name").value("Alice"));
    }

    @Test
    void shouldCreateUser() throws Exception {
        UserRequest request = new UserRequest();
        request.setName("Alice");
        request.setEmail("alice@example.com");

        when(userService.create(any())).thenReturn(new User(1L, "Alice"));

        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectToJson(request)))
            .andExpect(status().isCreated());
    }

    @Test
    void shouldRejectInvalidEmail() throws Exception {
        UserRequest request = new UserRequest();
        request.setName("Alice");
        request.setEmail("invalid-email");

        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectToJson(request)))
            .andExpect(status().isBadRequest());
    }
}

// Integration test with TestContainers
@SpringBootTest
@Testcontainers
class UserServiceIntegrationTest {

    @Testcontainers
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16");

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UserService userService;

    @Test
    void shouldCreateAndFindUser() {
        User user = new User(null, "Alice");
        userRepository.save(user);

        Optional<User> found = userRepository.findById(user.getId());
        assertThat(found).isPresent();
        assertThat(found.get().getName()).isEqualTo("Alice");
    }
}
```

### Spring Boot Common Error Handling

```java
// Global exception handler
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(NotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(NotFoundException ex) {
        ErrorResponse error = new ErrorResponse("NOT_FOUND", ex.getMessage());
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ValidationErrorResponse> handleValidation(
            MethodArgumentNotValidException ex) {
        List<String> errors = ex.getBindingResult()
            .getFieldErrors()
            .stream()
            .map(FieldError::getDefaultMessage)
            .toList();
        return ResponseEntity.badRequest()
            .body(new ValidationErrorResponse(errors));
    }

    @ExceptionHandler(DataAccessException.class)
    public ResponseEntity<ErrorResponse> handleDataAccess(DataAccessException ex) {
        ErrorResponse error = new ErrorResponse("DATABASE_ERROR", "Database operation failed");
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
    }
}
```

### Spring Boot Application Structure (Recommended)

```
src/main/java/com/example/
├── Application.java                  # @SpringBootApplication
├── config/                           # Configuration classes
│   ├── SwaggerConfig.java
│   ├── SecurityConfig.java
│   └── CacheConfig.java
├── controller/                       # REST controllers
│   ├── UserController.java
│   └── HealthController.java
├── service/                          # Business logic
│   ├── UserService.java
│   ├── UserServiceImpl.java
│   └── NotificationService.java
├── repository/                       # Data access
│   ├── UserRepository.java
│   └── AuditRepository.java
├── model/                            # Entity classes
│   ├── User.java
│   └── AuditLog.java
├── dto/                              # Data transfer objects
│   ├── UserRequest.java
│   ├── UserResponse.java
│   └── ApiResponse.java
├── exception/                        # Custom exceptions
│   ├── NotFoundException.java
│   └── GlobalExceptionHandler.java
└── util/                             # Utility classes
    ├── DateUtils.java
    └── ValidationUtils.java

src/main/resources/
├── application.yml                   # Main config
├── application-dev.yml               # Development profile
├── application-prod.yml              # Production profile
├── application-test.yml              # Testing profile
└── db/
    └── migration/                    # Flyway/Liquibase migrations

src/test/java/com/example/
├── controller/
├── service/
└── repository/
```

---

## Development Workflow

### Recommended Workflow for Claude-Driven Java Development

```bash
# 1. Code: javac provides fast compilation feedback
javac -Xlint *.java             # compile with warnings

# 2. Before committing: run full lint stack
google-java-format -i **/*.java # format code
checkstyle -c /home/claudeuser/checkstyle.xml **/*.java  # check style
spotbugs -textui -high **/*.class                           # detect bugs

# 3. Test
mvn test                        # run tests
gradle test                     # run tests (incremental)

# 4. Generate documentation
mvn javadoc:javadoc             # generate Javadoc
gradle javadoc                  # generate Javadoc

# 5. Full CI-like check
mvn clean compile test checkstyle:check spotbugs:check pmd:check
```

### Quick Reference

```bash
# === Compilation ===
javac *.java                   # compile
javac -Xlint *.java            # compile with warnings
java Main                      # run
jdb Main                       # debug

# === Linting ===
google-java-format -i **/*.java   # format (RECOMMENDED)
google-java-format --dry-run **/*.java  # check
checkstyle -c /home/claudeuser/checkstyle.xml **/*.java  # style
spotbugs -textui -high **/*.class       # bugs
pmd java -R rulesets/java/quickstart.xml **/*.java  # analysis

# === Building ===
mvn clean compile test package   # full Maven build
gradle clean build               # full Gradle build
mvn dependency:tree              # dependency tree

# === Code Generation ===
google-java-format -i *.java     # format file
google-java-format --sort-imports *.java  # sort imports
checkstyle -f xml **/*.java      # XML output
mvn archetype:generate           # new project

# === Testing ===
mvn test                         # all tests
gradle test                      # all tests
mvn test -Dtest=FooTest          # specific test

# === Documentation ===
mvn javadoc:javadoc              # Javadoc
gradle javadoc                   # Javadoc
javadoc -d docs *.java           # generate docs
```

---

## Anti-Patterns

- **Line length > 120** — should be wrapped
- **Magic numbers** — extract named constants
- **Long methods (>50 lines)** — extract helper methods
- **Cyclomatic complexity > 10** — too many branches
- **Missing Javadoc on public APIs** — document public classes and methods
- **Raw types** — use generics (`List<String>` not `List`)
- **Unchecked warnings** — handle generic type warnings
- **Deep nesting** — extract inner logic to helper methods
- **Missing constants** — use UPPER_SNAKE_CASE for true constants
- **Inconsistent naming** — follow Google Java naming conventions
- **Unused imports** — run `google-java-format --sort-imports` to fix
- **Missing checkstyle lints** — run `checkstyle` before committing

# Knowledge Forge Project Rules

## Language Policy
- **Chat Conversations**: Always conduct chat, questions, and project status updates in Spanish.
- **Code & Comments**: All code, docstrings, variable names, classes, functions, and inline comments must be written in English.
- **Technical & Project Documentation**: All documentation files (such as `REQUIREMENTS.md`, `README.md`, designs, API specs, etc.) must be written in English.
- **Implementation Plan / Tracking artifacts**: The `implementation_plan.md` and walkthroughs will be tracked in Spanish as part of chat/tracking, while technical files in the workspace stay in English.

## Git Commit Style
- **Commit Messages**: Always write Git commit messages in English.
- **Git Commit Command Format**: Since Windows Git Bash is used, always write multi-line git commits using multiple `-m` flags, separated by a backslash `\` for line continuation.
  Example:
  ```bash
  git commit -m "feat: initial structure of backend" \
             -m "Add core configurations and API routes skeleton" \
             -m "Setup database model definition templates"
  ```

## Git Workflow after Core Features
- **Git Sequence Generation**: After designing and developing each core or relevant functionality/module/feature/component (both front-end and back-end), always generate the exact sequence of Git commands (`git add`, `git commit` using the multiple `-m` format with `\`, and `git push`) so the user can easily record changes locally and push to the remote GitHub repository.
- **Granular Commit Sequences**: When generating Git command sequences, always break down the changes into multiple, logical, and independent commits (grouped by relevant modules, components, or files) instead of combining everything into one single commit. This ensures optimal repository traceability and allows easy rollbacks or reviews for both Front-End and Back-End developments in the future.
- **Git Workspace Hygiene**: Local database instances, runtime execution logs, temporary mock upload directories, IDE caches, build outputs, and transient assets generated during development or testing must never be staged, committed, or pushed to the Git repository. The `.gitignore` file must be kept updated to enforce these exclusions and prevent repository bloat.

## Project Startup & Structural Documentation
- **Architecture & File System Files**: Always generate the files `project_architecture.txt` (representing the global E2E system architecture) and `project_file_system.txt` (representing the project folder and file layout) when starting a new project from scratch. Both files must be documented in English and kept up to date.
- **Continuous Documentation Maintenance**: Every time a new feature, component, module, library, framework, tool, or database integration is designed, developed, modified, or added to either the Front-End or Back-End of the project, all three technical documentation files (`README.md`, `project_architecture.txt`, and `project_file_system.txt`) must be updated to accurately reflect the latest project state. If any of these three documentation files do not exist at the time of review, they must be created immediately with the most up-to-date and complete project information.

## Git Branching & CI/CD Validation Strategy
- **Foundational Branching Model**: Repositories use a three-tier foundational branch model:
  - `master` or `main`: Production environment.
  - `staging`: Testing / pre-production environment.
  - `develop`: Sandbox development environment.
- **Ad-Hoc Branch Conventions**: All other branches are created ad-hoc off `develop` (or `staging` for hotfixes) following strict standard naming conventions:
  - `feat/` or `feature/`: Core new features.
  - `bug/` or `bugfix/`: Non-critical defect fixes.
  - `exp/` or `experimental/`: Temporal, unstable sandboxes.
  - `chore/`: Technical debt, quick fixes, or dependency updates.
  - `hotfix/`: Production bugs resolved in-place without compilation or server restarts.
  - `fix/`: Cold-fix bug resolutions requiring system downtime or maintenance modes.
  - `temp/`: Temporary files or experiments.
  - `automation/`: Process automation scripts.
  - `refactor/`: Code structure refactorings without logic changes.
- **CI Environment Verification Policy**: The Continuous Integration (CI) pipeline must enforce distinct validation rigor based on target branches:
  - **Comprehensive Heavy Checks**: Runs exclusively on `master` and `staging`. Includes complex service container instantiation (databases, vector engines, Redis caches), static type analysis checking, build optimizations, and comprehensive integration testing suite execution.
  - **Basic Light Checks**: Runs on `develop` and ad-hoc branches. Limits validation to syntax checking, compilation warnings, basic lint reviews, and fast execution checks to maintain agile iteration loops without exposing test databases.

## Software Engineering & Architectural Principles
- **SOLID Design Principles**: All software components must follow SOLID principles:
  - *Single Responsibility Principle (SRP)*: Each class/module handles a single aspect of functionality (e.g., separate Authorization, Data Access, Quality Rule Evaluation, Scoring Calculation, Duplicate Detection, and Exporting).
  - *Open/Closed Principle (OCP)*: Design abstractions open for extension (e.g., adding new quality rule validators) but closed for modification.
  - *Liskov Substitution Principle (LSP)*: Subclasses or mock implementations must be seamlessly substitutable for their parent interfaces.
  - *Interface Segregation Principle (ISP)*: Prefer small, cohesive, role-specific interfaces (`ZIF_MDQ_REPOSITORY`, `ZIF_MDQ_RULE_ENGINE`, `ZIF_MDQ_SCORING_ENGINE`, `ZIF_MDQ_AUTH_SERVICE`).
  - *Dependency Inversion Principle (DIP)*: High-level business modules depend on abstractions (interfaces), not low-level data access implementations.
- **Clean Code & Clean ABAP**:
  - Prefer ABAP Objects (OO) over procedural Function Modules or Include scripts.
  - **ABAP Object Naming Convention**: All custom SAP ABAP objects, classes, interfaces, structures, database tables, and file names starting with 'Z' MUST have their names written in **UPPERCASE** (e.g., `ZCL_MDQ_RULE_ENGINE.clas.abap`, `ZIF_MDQ_REPOSITORY.intf.abap`, `ZMDQ_RULE`).
  - Keep methods short, readable, and highly cohesive.
  - Use descriptive self-documenting method and variable names in English.
  - Avoid magic values and numbers; encapsulate constants in dedicated interfaces or classes (`ZIF_MDQ_CONSTANTS`).
  - Use class-based exception handling (`CX_STATIC_CHECK` / `CX_NO_CHECK` derived exceptions like `CX_MDQ_QUALITY_ERROR`).
  - Apply inline declarations (`DATA(...)`) and modern ABAP constructs (`VALUE`, `CORRESPONDING`, `FILTER`, `REDUCE`) where readability is enhanced.
  - Enforce mandatory ABAP Unit test suites for logic verification.
- **Separation of Concerns (SoC)**: Strict architectural layers: Presentation Layer (SALV / Fiori UI5), Application Service Layer (`ZCL_MDQ_REPORT_SERVICE`), Domain / Business Logic Layer (`ZCL_MDQ_RULE_ENGINE`, `ZCL_MDQ_SCORING_ENGINE`, `ZCL_MDQ_DUPLICATE_ENGINE`), Data Access / Repository Layer (`ZCL_MDQ_REPOSITORY`), and Integration Layer (OData / CDS Views).
- **KISS, YAGNI & DRY**:
  - *Keep It Simple, Stupid (KISS)*: Choose clear, straightforward designs over overly complex patterns.
  - *You Aren't Gonna Need It (YAGNI)*: Implement only required functionality according to `REQUIREMENTS.md`.
  - *Don't Repeat Yourself (DRY)*: Centralize shared algorithms, field transformations, and error handling.

## Official SAP Guidelines & Technical Standards
- **Multi-Database & Platform Compatibility**:
  - The solution must be fully compatible with both classic SAP R/3 environments (running on traditional DB engines such as Oracle, SQL Server, or DB2) and modern SAP S/4HANA environments (running on SAP HANA DB).
  - Data retrieval mechanisms must support classic Open SQL with `FOR ALL ENTRIES IN` for classic DBs as well as HANA DB Pushdown, CDS Views, and ABAP SQL aggregations for S/4HANA.
- **ABAP Performance Guidelines**:
  - Strict prohibition of `SELECT` statements inside `LOOP ... ENDLOOP` blocks. Use `FOR ALL ENTRIES IN` (classic R/3) or Database JOINs / CDS Aggregations (S/4HANA).
  - Avoid `SELECT *`; fetch explicitly required fields.
  - Push down data filtering, groupings, and sums to the database layer when HANA DB is available.
- **Security & Authorization Standards**:
  - Enforce explicit `AUTHORITY-CHECK` statements (e.g., `M_MATE_STA` for Material Master, `V_VBAK_VKO` / `F_BKPF_BUK` for Customer/Vendor Master, `B_BUPA_GRP` for Business Partner) before executing data retrieval queries.
  - Validate all user input parameters and selection range tables.
  - Implement structured Application Logging via SAP standard Application Log (`BAL_LOG_*` / `CL_BALI_LOGGER`) for auditability.
  - Zero tolerance for hardcoded credentials, system tokens, or sensitive client data.

## Offline Execution & Mock Data Strategy
- **Context & Rationale**: This project is developed in a greenfield environment without access to an active SAP ERP server (R/3 or S/4HANA) or SAP clients (mandantes). Standard SAP workbench transactions (`SE11`, `SE24`, `SE37`, `SE38`, `ST22`, `SE80`, `SE16N`) cannot be executed live. However, all developed software must be 100% production-grade and ready for deployment into any corporate SAP landscape.
- **Architectural Solution**:
  - The system design uses **Dependency Injection (DI)** driven by ABAP OO Interfaces.
  - Mock Repositories (`ZCL_MDQ_REPO_MOCK`) and static mock datasets (`data/mock_mara.json`, `data/mock_kna1.json`, `data/mock_lfa1.json`, `data/mock_but000.json`, etc.) simulate standard SAP MM/SD/FI/BP tables (`MARA`, `MAKT`, `MARC`, `KNA1`, `KNB1`, `LFA1`, `LFB1`, `BUT000`).
  - Unit testing suites and mock execution harnesses allow 100% offline verification of business logic, quality rule evaluations, score calculations, authorizations, and data transformations.


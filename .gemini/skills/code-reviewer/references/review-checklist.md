# Code Review Checklist

## 1. Project-Specific Patterns
- [ ] Does the code adhere to the project's established patterns?
- [ ] **Consult `references/project-patterns.md` for detailed guidelines on:**
    - App Routing and Navigation Shell
    - Reusable Widget Extraction
    - Form Field and Dropdown Wrappers
    - Stepper Validation Flow
    - Selection & Bulk Actions
    - Report Table Listing Pattern
- [ ] **Consult `references/project-examples.md` for concrete code examples.**

## 2. General Best Practices
- [ ] **Functionality**: Does the code work as intended and handle edge cases?
- [ ] **Readability**: Is the code clear, well-named, and easy to understand?
- [ ] **Duplication**: Is there any unnecessary duplicated code?
- [ ] **Comments**: Are comments clear, concise, and only present where necessary?
- [ ] **Security**: Are there any potential security vulnerabilities (e.g., hardcoded secrets, input validation)?

## 3. Testing
- [ ] Are there sufficient tests for the new code?
- [ ] Do all existing and new tests pass?
- [ ] Are the tests clear and maintainable?

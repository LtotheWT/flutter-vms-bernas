---
name: code-reviewer
description: "Performs a code review on the last Git commit, checking for bugs, style issues, and suggesting improvements against project-specific patterns."
---

# Code Reviewer Skill

This skill reviews the last Git commit against general best practices and project-specific patterns.

## Workflow

1.  **Get the diff**: Get the diff of the last commit using the command `git diff HEAD~1 HEAD`.
2.  **Analyze the changes**: Review the diff to understand the changes made.
3.  **Consult Project Patterns**: Review the code against the project-specific patterns documented in `references/project-patterns.md` and `references/project-examples.md`. This is the most important step.
4.  **Consult General Checklist**: Refer to `references/review-checklist.md` for a general systematic review.
5.  **Format the output**: Use the template `assets/review-template.md` to structure the review.
6.  **Provide feedback**: Present the review to the user, highlighting potential issues and suggesting improvements.
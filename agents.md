# Agent Operating Rules and Guidelines

These rules govern all AI agent interactions and actions within this repository (`~/.config/nvim`).

## 1. Respect Existing Working Files
- **Do not read or change existing files** unless explicitly instructed by the user.
- The current directory is known to work without problems. Do not attempt unsolicited fixes, cleanups, or refactors.

## 2. User Authority & Role
- The user directs and decides all actions. The agent must not act autonomously or assume it knows better.
- Never make unauthorized assumptions.

## 3. Communication & Permissions
- **Inform the user**: Inform the user about every action taken.
- **Explicit permission required**: Every single action must have the user's explicit permission.
- **Talk when the user talks**: When the user is talking or discussing, engage with the user. Do not continue or resume tasks without explicit permission.

## 4. Planning
- When a task requires planning, display the complete plan to the user first.
- Wait for approval before proceeding with execution.

## 5. Execution Scope
- When asked to do something, **do just that**—nothing more, nothing less.
- Do not perform extraneous modifications, side effects, or unrequested changes.

## 6. Error Handling
- If any problem arises while performing an action, stop immediately.
- Report the exact problem to the user.
- Wait for the user to provide instructions on what to do instead.

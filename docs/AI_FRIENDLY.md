# 🤖 AI-Friendly Development

GRAB is designed from the ground up to work seamlessly with AI coding assistants, providing comprehensive guidelines that help AI understand the project structure, patterns, and best practices.

---

## 📋 Overview

GRAB includes **out-of-the-box AI assistance** for all major coding assistants:

- **GitHub Copilot** - Works in VS Code, JetBrains IDEs, Visual Studio, and more
- **Cursor** - Auto-loads rules with intelligent code completion
- **Windsurf** - Always-On assistance with project awareness
- **JetBrains AI** - Supports AGENTS.md standard
- **Any AGENTS.md-compatible assistant** - Universal compatibility

**No configuration needed** - just clone and start coding with intelligent AI suggestions tailored to GRAB's architecture.

---

## 🎯 What Makes GRAB AI-Friendly?

### 1. **Comprehensive AI Guidelines**

GRAB includes four types of AI configuration files:

| File | Purpose | Supported IDEs |
|------|---------|----------------|
| `.github/copilot-instructions.md` | GitHub Copilot guidelines | VS Code, JetBrains, Visual Studio, Xcode, Eclipse, CLI |
| `.cursor/rules/grab.mdc` | Cursor-specific rules with auto-apply | Cursor IDE |
| `.windsurf/rules/grab.md` | Windsurf-specific rules with Always-On | Windsurf IDE |
| `AGENTS.md` | Universal AI standard (OpenAI) | All AI assistants supporting the standard |

### 2. **Developer-Focused Content**

All guidelines focus on **using** GRAB, not maintaining it:

- ✅ Adding new domains/entities (step-by-step)
- ✅ Creating database migrations
- ✅ Writing Clean Architecture code
- ✅ Testing patterns and coverage
- ✅ Authentication & authorization
- ✅ Error handling
- ✅ Swagger documentation
- ✅ Docker workflow

### 3. **Pattern Recognition**

AI assistants understand:

- **Clean Architecture**: Handler → Service → Repository
- **Domain Structure**: `internal/<domain>/` with model, dto, repository, service, handler
- **Migration Naming**: `YYYYMMDDHHMMSS_verb_noun_table`
- **Testing Conventions**: Table-driven tests with mocks
- **Error Handling**: Centralized `errors.HandleError()` and `errors.HandleValidationError()`
- **Context Helpers**: `contextutil.GetUserID()`, `contextutil.GetUserEmail()`, etc.

### 4. **Documentation Integration**

Every AI file links to comprehensive documentation:

- [Authentication Guide](AUTHENTICATION.md)
- [RBAC Documentation](RBAC.md)
- [Migrations Guide](MIGRATIONS_GUIDE.md)
- [Testing Guide](TESTING.md)
- [Configuration](CONFIGURATION.md)
- And more...

---

## 🚀 Getting Started

### Prerequisites

Clone GRAB to your local machine:

```bash
git clone https://github.com/vahiiiid/go-rest-api-boilerplate.git
cd go-rest-api-boilerplate
```

### IDE-Specific Setup

=== "GitHub Copilot"

    **Supported Editors**: VS Code, JetBrains IDEs (IntelliJ, GoLand), Visual Studio, Xcode, Eclipse, GitHub CLI
    
    **How it works**: GitHub Copilot automatically reads `.github/copilot-instructions.md` from your repository root. No configuration needed!
    
    **Verification**:
    
    1. Open GRAB in your IDE
    2. Create a new Go file in `internal/`
    3. Type `func New` and wait for Copilot suggestions
    4. Suggestions should follow Clean Architecture patterns
    
    **Features**:
    
    - 350+ lines of developer-focused guidelines
    - Complete domain creation examples
    - Migration patterns and best practices
    - Testing strategies
    - Pre-commit workflow
    
    **Documentation**: [GitHub Copilot Docs](https://docs.github.com/en/copilot)

=== "Cursor"

    **How it works**: Cursor automatically reads `.cursor/rules/*.mdc` files with `alwaysApply: true` frontmatter. Rules are always active!
    
    **Verification**:
    
    1. Open GRAB in Cursor
    2. Open Cursor Settings (Cmd/Ctrl + ,)
    3. Go to "Cursor Rules"
    4. You should see `grab.mdc` listed
    
    **Features**:
    
    - 180+ lines of concise guidelines
    - Auto-applies to all conversations
    - Quick reference tables
    - Docker-first workflow guidance
    
    **Customization**:
    
    Want to add personal preferences? Create `.cursor/rules/personal.mdc`:
    
    ```markdown
    ---
    alwaysApply: true
    ---
    
    # My Personal Rules
    
    - Prefer `assert` over `require` in tests
    - Use `context.TODO()` for examples
    - Add TODO comments for future work
    ```
    
    **Documentation**: [Cursor AI Docs](https://docs.cursor.com/)

=== "Windsurf"

    **How it works**: Windsurf reads `.windsurf/rules/*.md` files with "Always On" activation. Rules are globally available!
    
    **Verification**:
    
    1. Open GRAB in Windsurf
    2. Open Windsurf Settings
    3. Navigate to "AI Rules"
    4. Confirm `grab.md` is active
    
    **Features**:
    
    - 180+ lines of focused guidelines
    - Always-On activation (no manual enabling)
    - Pattern examples with code snippets
    - Pre-commit checklist
    
    **Documentation**: [Windsurf by Codeium](https://codeium.com/windsurf)

=== "GoLand / IntelliJ"

    **Dual AI Support**: GoLand works with **both GitHub Copilot and JetBrains AI**!
    
    **GitHub Copilot** (Recommended)
    
    - Automatically reads `.github/copilot-instructions.md`
    - 350+ lines of developer-focused guidelines
    - No IDE-specific configuration needed
    - Same experience as VS Code Copilot
    
    **JetBrains AI Assistant**
    
    - Reads `AGENTS.md` from repository root
    - 800+ lines comprehensive guide
    - Universal OpenAI standard
    - Works with all JetBrains IDEs
    
    **Verification** (GitHub Copilot):
    
    1. Open GRAB in GoLand/IntelliJ
    2. Enable GitHub Copilot in Preferences → Tools → GitHub Copilot
    3. Create a new Go file in `internal/`
    4. Type `func New` and wait for suggestions
    5. Suggestions should follow Clean Architecture patterns
    
    **Verification** (JetBrains AI):
    
    1. Open GRAB in GoLand/IntelliJ
    2. Enable JetBrains AI in Preferences → Tools → AI Assistant
    3. Open AI Assistant panel
    4. Ask: "How do I add a new domain?"
    5. Response should reference GRAB's architecture
    
    **Which to use?**
    
    - Use **GitHub Copilot** for inline completions and real-time suggestions
    - Use **JetBrains AI** for chat-based assistance and explanations
    - Use **both** for maximum productivity!
    
    **Documentation**:
    - [GitHub Copilot in JetBrains](https://docs.github.com/en/copilot/using-github-copilot/getting-started-with-github-copilot#getting-started-with-github-copilot-in-a-jetbrains-ide)
    - [JetBrains AI Assistant](https://www.jetbrains.com/help/idea/ai-assistant.html)

=== "Other IDEs"

    **AGENTS.md-Compatible Assistants**
    
    The following AI assistants support the `AGENTS.md` standard:
    
    - **Amazon Q** - AWS's AI coding assistant
    - **Tabnine** - AI code completion
    - **Sourcegraph Cody** - Code intelligence
    - **Any assistant supporting AGENTS.md** - Universal compatibility
    
    **How it works**: These assistants read `AGENTS.md` from your repository root automatically.
    
    **Features**:
    
    - 800+ lines comprehensive guide
    - Universal OpenAI standard
    - Complete examples for all common tasks
    - Works across multiple editors
    
    **Documentation**: [AGENTS.md Standard](https://github.com/openai/agents-md)

---

## 📊 IDE Comparison

### Feature Matrix

| Feature | GitHub Copilot | Cursor | Windsurf | GoLand/IntelliJ | AGENTS.md |
|---------|----------------|--------|----------|-----------------|-----------|-------|
| **Auto-loads** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes (both) | ✅ Yes |
| **File Path** | `.github/copilot-instructions.md` | `.cursor/rules/*.mdc` | `.windsurf/rules/*.md` | Same as Copilot + `AGENTS.md` | `AGENTS.md` |
| **Configuration** | None | YAML frontmatter | Markdown header | None | None |
| **Activation** | Automatic | `alwaysApply: true` | "Always On" | Automatic | Automatic |
| **Content Length** | 350+ lines | 180+ lines | 180+ lines | 350+ / 800+ lines | 800+ lines |
| **Scope** | Developer-focused | Developer-focused | Developer-focused | Developer-focused + Universal | Universal |
| **Customization** | N/A | Personal rules | Per-project | N/A | N/A |
| **IDE-Specific Files** | ❌ No | ✅ Yes (`.cursor/`) | ✅ Yes (`.windsurf/`) | ❌ No | ❌ No |

### File Structure Overview

```
go-rest-api-boilerplate/
├── .github/
│   └── copilot-instructions.md   # ← GitHub Copilot (VS Code, GoLand, etc.)
├── .cursor/
│   └── rules/
│       └── grab.mdc               # ← Cursor IDE only
├── .windsurf/
│   └── rules/
│       └── grab.md                # ← Windsurf IDE only
└── AGENTS.md                      # ← Universal (JetBrains AI, Amazon Q, etc.)
```

### Key Differences

| IDE | Needs Dedicated Directory? | Files Used |
|-----|---------------------------|------------|
| **Cursor** | ✅ Yes (`.cursor/`) | `.cursor/rules/grab.mdc` |
| **Windsurf** | ✅ Yes (`.windsurf/`) | `.windsurf/rules/grab.md` |
| **VS Code** | ❌ No | `.github/copilot-instructions.md` |
| **GoLand** | ❌ No | `.github/copilot-instructions.md` + `AGENTS.md` |
| **IntelliJ** | ❌ No | `.github/copilot-instructions.md` + `AGENTS.md` |
| **Visual Studio** | ❌ No | `.github/copilot-instructions.md` |

**Why GoLand doesn't need dedicated files:**

- GitHub Copilot in GoLand uses the same `.github/copilot-instructions.md` as VS Code
- JetBrains AI Assistant reads `AGENTS.md` (universal standard)
- No IDE-specific configuration directories required
- Works out-of-the-box after cloning the repository

---

## 💡 What AI Assistants Learn

When you use AI assistants with GRAB, they understand:

### Architecture Patterns

```go
// AI knows to create Handler → Service → Repository layers
internal/todo/
├── model.go       // GORM models
├── dto.go         // Request/Response DTOs
├── repository.go  // Database access
├── service.go     // Business logic
├── handler.go     // HTTP handlers
└── *_test.go      // Tests
```

### Docker Workflow

```bash
# AI suggests Docker-first commands
make up           # AI knows containers auto-start
make test         # AI knows this runs in container
make migrate-up   # AI knows Makefile handles context
```

### Migration Conventions

```bash
# AI generates correct migration names
make migrate-create NAME=create_todos_table
# Creates: 20251210143022_create_todos_table.up.sql
```

### Clean Architecture Code

```go
// AI suggests proper layer separation
func (h *Handler) CreateTodo(c *gin.Context) {
    userID := contextutil.GetUserID(c)  // AI knows context helpers
    
    var req CreateTodoRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        errors.HandleValidationError(c, err)  // AI uses centralized errors
        return
    }
    
    result, err := h.service.CreateTodo(c.Request.Context(), userID, &req)
    if err != nil {
        errors.HandleError(c, err)  // AI handles errors consistently
        return
    }
    
    c.JSON(http.StatusCreated, result)
}
```

### Testing Patterns

```go
// AI generates table-driven tests
tests := []struct {
    name        string
    request     *CreateTodoRequest
    setupMocks  func(*MockRepository)
    expectError bool
}{
    {
        name: "success",
        request: &CreateTodoRequest{Title: "Test"},
        setupMocks: func(m *MockRepository) {
            m.EXPECT().Create(gomock.Any(), gomock.Any()).Return(nil)
        },
    },
}
```

---

## 🔧 Customization

### Adding Personal Rules (Cursor)

Create `.cursor/rules/personal.mdc` for your preferences:

```markdown
---
alwaysApply: true
---

# Personal Coding Preferences

### Testing Style
- Use `assert` for most checks
- Use `require` when test can't continue
- Always add test description comments

### Error Messages
- Include context in error messages
- Use `fmt.Errorf` with `%w` for wrapping
- Log errors before returning

### Code Organization
- Group related functions together
- Separate public/private with blank line
- Add TODO comments with GitHub issues
```

### Project-Specific Overrides

Want different rules for a specific GRAB-based project? Create custom rules:

```markdown
---
alwaysApply: true
---

# MyProject Customizations

Based on GRAB, but with:
- Redis caching layer
- GraphQL API alongside REST
- Multi-tenancy support
- Additional middleware for analytics
```

### Disabling AI Rules

If you need to disable AI rules temporarily:

**GitHub Copilot**: No built-in disable, but you can:
- Rename `.github/copilot-instructions.md` temporarily
- Or use Copilot's disable keyboard shortcut

**Cursor**: 
1. Open Settings → Cursor Rules
2. Disable specific rule files
3. Or add `alwaysApply: false` to frontmatter

**Windsurf**:
1. Open Settings → AI Rules
2. Toggle off specific rules
3. Or remove "Always On" from file

---

## 🐛 Troubleshooting

### AI Not Following GRAB Patterns

**Issue**: AI suggestions don't match GRAB's Clean Architecture

**Solutions**:

1. **Verify file exists**:
   ```bash
   ls -la .github/copilot-instructions.md    # GitHub Copilot
   ls -la .cursor/rules/grab.mdc             # Cursor
   ls -la .windsurf/rules/grab.md            # Windsurf
   ls -la AGENTS.md                          # Universal
   ```

2. **Check file content**: Open the file and verify it has content (not empty)

3. **Restart IDE**: Sometimes IDE needs restart to load new rules

4. **Check IDE version**: Ensure your IDE/extension is up to date

5. **Explicitly mention GRAB**: In your prompt, say "Follow GRAB's Clean Architecture pattern"

### Cursor Rules Not Loading

**Issue**: `.cursor/rules/grab.mdc` not being applied

**Solutions**:

1. **Check frontmatter**:
   ```markdown
   ---
   alwaysApply: true
   ---
   ```

2. **Verify location**: File must be in `.cursor/rules/` directory

3. **Check file extension**: Must be `.mdc` not `.md`

4. **Reload window**: Use Command Palette → "Reload Window"

### Conflicting AI Suggestions

**Issue**: AI suggests patterns that contradict GRAB

**Solutions**:

1. **Be explicit**: "Use GRAB's pattern from internal/user/"

2. **Reference existing code**: "Follow the same structure as UserHandler"

3. **Mention specific guidelines**: "Use Clean Architecture like in AGENTS.md"

4. **Override suggestion**: Accept suggestion, then refactor with AI's help

### Performance Issues

**Issue**: AI responses are slow with large guidelines

**Solutions**:

- This is normal - comprehensive guidelines need processing time
- Initial responses may be slower, subsequent ones faster
- Consider using shorter format (Cursor/Windsurf) if speed is critical

---

## 📚 Examples

### Example: AI-Assisted Domain Creation

**Prompt**: "Create a Todo domain following GRAB patterns"

**AI Understanding**:
- Creates `internal/todo/` directory
- Generates model.go with GORM tags
- Creates dto.go with validation tags
- Implements repository interface
- Implements service with business logic
- Creates handler with Swagger annotations
- Registers routes in router.go
- Suggests migration command

**Result**: Complete domain in ~2 minutes instead of ~30 minutes

### Example: AI-Assisted Testing

**Prompt**: "Write tests for TodoService.CreateTodo"

**AI Understanding**:
- Uses table-driven test pattern
- Creates mock repository
- Tests success case
- Tests validation errors
- Tests repository errors
- Follows GRAB's testing conventions
- Includes gomock expectations

**Result**: Comprehensive test suite matching project standards

### Example: AI-Assisted Refactoring

**Prompt**: "Refactor this handler to use centralized error handling"

**AI Understanding**:
- Knows about `errors.HandleError()`
- Knows about `errors.HandleValidationError()`
- Maintains response format
- Preserves Swagger annotations
- Follows GRAB patterns

**Result**: Clean, consistent error handling

---

## 🎓 Best Practices

### 1. **Be Specific with Prompts**

❌ Bad: "Add error handling"

✅ Good: "Add error handling using GRAB's centralized errors package"

### 2. **Reference Existing Code**

❌ Bad: "Create a handler"

✅ Good: "Create a handler similar to UserHandler in internal/user/handler.go"

### 3. **Mention Architecture**

❌ Bad: "Add database code"

✅ Good: "Add repository layer following Clean Architecture"

### 4. **Use GRAB Terminology**

✅ Say: "domain", "repository", "service", "handler", "DTO"

❌ Don't say: "module", "model layer", "controller", "request struct"

### 5. **Leverage Examples**

Prompt: "Look at internal/user/ and create similar structure for products"

AI will mirror the proven patterns from the user domain.

---

## 🔗 Additional Resources

- **Main Documentation**: [GRAB Docs](https://vahiiiid.github.io/go-rest-api-docs/)
- **Development Guide**: [Development Guide](DEVELOPMENT_GUIDE.md)
- **Quick Reference**: [Quick Reference](QUICK_REFERENCE.md)
- **Testing Guide**: [Testing](TESTING.md)
- **GitHub Repository**: [vahiiiid/go-rest-api-boilerplate](https://github.com/vahiiiid/go-rest-api-boilerplate)

---

## 🤝 Contributing

Found ways to improve AI assistance? We'd love your input!

- **Open an Issue**: [GitHub Issues](https://github.com/vahiiiid/go-rest-api-boilerplate/issues)
- **Start a Discussion**: [GitHub Discussions](https://github.com/vahiiiid/go-rest-api-boilerplate/discussions)
- **Submit a PR**: Update AI guidelines with better examples

---

## 📝 FAQ

### Why separate files for different IDEs?

Each IDE has unique conventions:
- GitHub Copilot: Reads from `.github/` directory
- Cursor: Uses `.mdc` with YAML frontmatter
- Windsurf: Uses `.md` with special headers
- Universal: AGENTS.md standard

Having IDE-specific files ensures optimal experience for each tool.

### Can I use multiple AI assistants?

Yes! All files coexist peacefully. Use Copilot in VS Code, Cursor in Cursor IDE, and AGENTS.md works everywhere.

### Do I need to configure anything?

No! Just clone GRAB and start coding. AI assistants auto-discover their configuration files.

### What if my AI doesn't support these formats?

Use `AGENTS.md` - it's the universal standard supported by most modern AI assistants.

### Can I modify the AI guidelines?

Yes! Fork GRAB and customize for your needs. But consider:
- Keep maintainer rules local (`.github/copilot-instructions.local.md`)
- Commit developer-focused rules to help team

### Will AI guidelines slow down my IDE?

No. AI reads guidelines once and caches them. No performance impact on your development workflow.

---

**Last Updated**: 2025-12-10  
**GRAB Version**: v2.0.0

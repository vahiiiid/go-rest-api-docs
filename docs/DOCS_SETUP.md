# 📚 Documentation Setup

This project uses [MkDocs](https://www.mkdocs.org/) with the [Material theme](https://squidfunk.github.io/mkdocs-material/) for beautiful, searchable documentation.

## 🌐 Live Documentation

**🔗 https://vahiiiid.github.io/go-rest-api-boilerplate/**

The documentation is automatically deployed to GitHub Pages when changes are pushed to the `main` branch.

## 🛠️ Local Development

### Prerequisites

- Python 3.x
- pip

### Installation

Install MkDocs and required plugins:

```bash
pip install mkdocs mkdocs-material mkdocs-minify-plugin
```

Or use the provided script:

```bash
pip install -r docs-requirements.txt
```

### Running Locally

Start the development server with hot-reload:

```bash
mkdocs serve
```

The documentation will be available at **http://127.0.0.1:8000**

Changes to any `.md` file will automatically reload in your browser!

### Building

To build the static site:

```bash
mkdocs build
```

The built site will be in the `site/` directory.

To build with strict mode (recommended before committing):

```bash
mkdocs build --strict
```

This will fail if there are any warnings (broken links, missing files, etc.).

## 📁 Documentation Structure

```
.
├── mkdocs.yml              # MkDocs configuration
├── README.md               # Copied to index.md for homepage
├── docs/                   # Documentation pages
│   ├── SETUP.md
│   ├── DOCKER.md
│   ├── DEVELOPMENT_GUIDE.md
│   ├── QUICK_REFERENCE.md
│   ├── PROJECT_SUMMARY.md
│   └── SWAGGER.md
├── migrations/
│   └── README.md           # Migration guide
├── CONTRIBUTING.md         # Contributing guidelines
└── LICENSE                 # License file
```

## ✏️ Adding New Pages

### 1. Create the Markdown File

Add your new `.md` file in the appropriate location:
- General guides → `docs/`
- Feature-specific docs → `docs/features/` (create if needed)

### 2. Update Navigation

Edit `mkdocs.yml` and add your page to the `nav` section:

```yaml
nav:
  - Home: index.md
  - Your Section:
      - New Page: docs/your-new-page.md
```

### 3. Test Locally

```bash
mkdocs serve
```

Visit http://127.0.0.1:8000 and verify:
- ✅ Page appears in navigation
- ✅ Content renders correctly
- ✅ Links work
- ✅ Code blocks have syntax highlighting

### 4. Commit and Push

```bash
git add docs/your-new-page.md mkdocs.yml
git commit -m "docs: add new page"
git push origin main
```

GitHub Actions will automatically deploy the updated docs!

## 🎨 Styling and Features

### Code Blocks

Use fenced code blocks with language tags:

```markdown
\`\`\`go
func main() {
    fmt.Println("Hello, World!")
}
\`\`\`
```

### Admonitions

Use admonitions for tips, warnings, notes:

```markdown
!!! tip "Pro Tip"
    Use `make quick-start` for fastest setup!

!!! warning
    Change JWT_SECRET before production!

!!! note
    This feature requires Go 1.23+

!!! danger
    This operation is irreversible!
```

### Tabs

Create tabbed content:

```markdown
=== "macOS"
    ```bash
    brew install go
    ```

=== "Linux"
    ```bash
    sudo apt install golang
    ```

=== "Windows"
    ```powershell
    choco install golang
    ```
```

### Tables

Standard Markdown tables are supported:

```markdown
| Feature | Status |
|---------|--------|
| JWT Auth | ✅ |
| Docker | ✅ |
| Tests | ✅ |
```

### Links

Link to other docs:

```markdown
See [Setup Guide](SETUP.md) for details.
```

Link to external sites:

```markdown
Check out [Go Documentation](https://go.dev/doc/)
```

## 🚀 Deployment

### Automatic Deployment

The documentation is automatically deployed via GitHub Actions when:
- Changes are pushed to `main` branch
- Any `.md` file is modified
- `mkdocs.yml` is updated

Workflow file: `.github/workflows/docs.yml`

### Manual Deployment

If needed, you can manually deploy:

```bash
# Deploy to GitHub Pages
mkdocs gh-deploy --force

# Or trigger the GitHub Action manually
gh workflow run docs.yml
```

## 🔧 Configuration

All configuration is in `mkdocs.yml`:

```yaml
site_name: Go REST API Boilerplate
theme:
  name: material
  palette:
    - scheme: default      # Light mode
    - scheme: slate        # Dark mode
  features:
    - navigation.instant   # Fast loading
    - navigation.tabs      # Top-level tabs
    - search.suggest       # Search suggestions
    - content.code.copy    # Copy code button
```

### Customizing Theme

To customize colors, fonts, or features, edit the `theme` section in `mkdocs.yml`.

See [Material theme documentation](https://squidfunk.github.io/mkdocs-material/setup/changing-the-colors/) for all options.

## 📊 Analytics (Optional)

To add Google Analytics, add to `mkdocs.yml`:

```yaml
extra:
  analytics:
    provider: google
    property: G-XXXXXXXXXX
```

## 🐛 Troubleshooting

### "Module not found" error

```bash
pip install --upgrade mkdocs mkdocs-material mkdocs-minify-plugin
```

### Broken links

Run with strict mode to find issues:

```bash
mkdocs build --strict
```

### Images not showing

- Ensure images are in `docs/` or a subdirectory
- Use relative paths: `![Alt](./images/screenshot.png)`
- Or absolute paths: `![Alt](/assets/logo.png)`

### Changes not reflecting

- Clear browser cache
- Restart `mkdocs serve`
- Delete `site/` directory and rebuild

## 📚 Resources

- [MkDocs Documentation](https://www.mkdocs.org/)
- [Material Theme](https://squidfunk.github.io/mkdocs-material/)
- [Markdown Guide](https://www.markdownguide.org/)
- [GitHub Pages](https://pages.github.com/)

## ✅ Checklist for Documentation Changes

Before committing documentation changes:

- [ ] Created/updated `.md` files
- [ ] Updated `mkdocs.yml` navigation if needed
- [ ] Tested locally with `mkdocs serve`
- [ ] Built with strict mode: `mkdocs build --strict`
- [ ] Checked for broken links
- [ ] Verified code examples work
- [ ] Tested in both light and dark mode
- [ ] Committed and pushed to `main`

---

**Happy documenting! 📝**


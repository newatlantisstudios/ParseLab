# **TODO**

## **Phase 1: MVP – JSON Core + iOS Basics**
### 📁 **File Handling**
- [x] File browsing history / recent files list (optional)
- [x] Handle .json file extension
- [x] Open files from Files app (via UIDocumentPicker)

### 👀 **Viewer**
- [x] Minimap or breadcrumb for nested navigation
- [x] Tree view UI for navigating nested structures
- [x] Pretty-printed JSON display
- [x] Raw text viewer with syntax highlighting

### 🧰 **Basic Tools**
- [x] Toggle between raw and structured view
- [x] Collapse/expand sections in tree view
- [x] Search within JSON (keys/values)

### ✏️ **Editor**
- [x] Auto-indentation / formatting on edit
- [x] Syntax validation on save
- [x] In-place JSON editing

### 🧪 **Validation**
- [x] JSON Schema validation (optional for v1)
- [x] Basic JSON syntax check

### 🎨 **UI/UX**
- [x] Light/dark mode support
- [x] File metadata display (filename, size, last modified)

## 🧠 **Phase 2: Structured Format Expansion**
### 🧩 **Add Support For:**
- [x] YAML (.yml, .yaml)
- [x] TOML (.toml)
- [x] INI (.ini)
- [x] CSV (.csv) – table view
  - [x] CSV to JSON toolbar bug
  - [x] Test type to type toolbar to find bugs

- [x] XML (.xml) – tree + raw view
- [ ] PLIST (.plist)
- [ ] Validation works correctly for each of type of files

### 🔄 **Format Conversion**
- [ ] JSON ↔ YAML
- [ ] JSON ↔ TOML
- [ ] JSON ↔ XML
- [ ] CSV ↔ JSON
- [ ] Conversion UI with format picker and preview

**Other**

- [ ] TipJar
- [ ] Sample buttons needs to be a list, not a bunch of buttons
- [ ] The app needs to be aware of what file type it is in for UI text

## 🧬 **Phase 3: Advanced File Formats & Features**
### 💾 **Heavier Formats**
- [ ] Protobuf (.pb + optional .proto schema support)
- [ ] MessagePack (.msgpack)
- [ ] CBOR (.cbor)
- [ ] SQLite viewer (browse tables, rows)
- [ ] Realm file viewer (read-only)

### 🧠 **Advanced Tools**
- [ ] Large file handling (streaming, lazy load)
- [ ] Highlight changes (diff mode)
- [ ] Linting / semantic warnings
- [ ] Toggle "view-only" or "edit mode"

### 📤 **Sharing & Export**
- [ ] Export edited file
- [ ] Export as another format
- [ ] Copy pretty/compact string to clipboard

## 🌟 **Phase 4: Pro Features / Extra Polish**
- [ ] Settings screen (theme, indentation size, font)
- [ ] File bookmarks or pinned files
- [ ] Quick actions (e.g. "Paste from clipboard", "Open last file")
- [ ] iCloud or local storage sync (optional)
- [ ] Help / docs / "What is this format?" guides

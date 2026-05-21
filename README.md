# block_sort.nvim

Sort text blocks in Neovim using regex-defined headers.

## Description

This plugin identifies blocks of text starting with a line that matches a given regex pattern. It sorts these blocks alphabetically (A-Z, a-z, 0-9) while keeping each block's header and body together. You can run it on the entire buffer from the cursor down, or restrict it to a visual selection or specific line range.

## Installing

### LazyVim

```lua
return {
  {
    "wnndgws/nvim-blocksort",
    config = function()
      require("blocksort")
    end,
  }
}
```

### Manual

Clone the repository into your Neovim `pack` directory or a plugin manager folder:

```bash
git clone https://github.com/wnndgws/block_sort.nvim.git ~/.local/share/nvim/site/pack/plugins/start/block_sort.nvim
```

Ensure the `lua/block_sort/init.lua` file is in your runtime path.

## Usage

Call the command with a Vim regex pattern:

```vim
:BlockSort <regex>
```

### Modes

- **Normal Mode**: Sorts blocks from the current cursor line to the end of the file.
- **Visual Mode**: Select a range of lines, then run `:'<,'>BlockSort <regex>`. Only blocks within the selection are sorted.
- **Line Range**: Specify explicit line numbers, e.g., `:10,50BlockSort ^##`.

### Sorting Order

Headers are compared character by character using this priority:

1. Uppercase letters (A-Z)
2. Lowercase letters (a-z)
3. Numbers (0-9)
4. All other characters

## Examples

### Markdown Headers

Sort sections by their level-two headers:

```vim
:BlockSort ^##
```

**Before:**

```markdown
## Beta
Content B

## Alpha
Content A
```

**After:**

```markdown
## Alpha
Content A

## Beta
Content B
```

### Numbered Lists

Sort items that start with a number and a period:

```vim
:BlockSort ^\d+\.
```

### Function Definitions

Sort functions by name in a script:

```vim
:BlockSort ^function
```

## Contributing

This is my first lua plugin, and all contributions are welcome!

1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/your-idea`).
3. Commit your changes (`git commit -m 'Add feature'`).
4. Push to the branch (`git push origin feature/your-idea`).
5. Open a Pull Request.

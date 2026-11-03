-- Render Mermaid diagrams in markdown buffers as unicode art.
-- Requires the termaid CLI on PATH (installed via chezmoi packages.yaml).
return {
  {
    "RokPre/mermaid.nvim",
    name = "mermaid.nvim",
    ft = { "markdown" },
    cmd = { "ASCImermaidRender", "ASCImermaidClear", "ASCImermaidToggle", "ASCImermaidInfo" },
    opts = {
      renderer = "termaid",
      placement = "above",
    },
  },
}

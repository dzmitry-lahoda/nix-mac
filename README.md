1. Install Nix and the Brave browser manually.
2. Use Nix for the rest.
3. Use Secure Enclave for auth; VS Code works well.
4. I use Bash.
   - Bash is good, zsh may be better, but Bash is still more common.
5. No Apple build tools, Xcode Select, or similar setup; Nix and only Nix dev tools.
   - So I cannot build apps for iOS.
6. Waiting for Asahi, especially to receive crypto donations the way Redox did.
7. Local LM Studio MLX Qwen AI 35B (17 GB RAM), along with Gemini/Codex installs (fuck Anthropic lock-in).
8. I removed everything except system apps from the panel; I use Apple as close to Linux as possible.

Agent skills are managed through [agent-skills-nix](https://github.com/Kyure-A/agent-skills-nix)
in `modules/ai/default.nix`, using the sources pinned in `flake.lock`. The shared
source roots are scanned recursively for `SKILL.md`, including new nested skills
when source pins are updated. The discovered skills install to Codex (`~/.codex/skills`) and Antigravity
(`~/.gemini/antigravity/skills`), and is also exposed through the Antigravity CLI
plugin. Apply configuration changes with `nix run .#rebuild`.

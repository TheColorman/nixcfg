# Delegation

- Make good use of subagents for complex tasks, context management, and subtasks that can be cleanly separated. Delegate independent work in parallel when useful, provide clear scopes and sufficient context, and integrate and verify the results.
- Always have a separate agent independently review changes for readability, maintainability, and whether they meet the task's success criteria before considering the work complete. Address review findings and have any resulting changes independently reviewed as well.

# Version Control

- Always use `jj` instead of `git` for version control operations.
- When I say "branch", I mean a branching code path, not a Git branch. When I mean a Git branch, I will use the word "bookmark".
- All agents, including subagents, must create a new JJ workspace before starting work on changes in a JJ repository. Use the requested starting revision, or fall back to the `main` bookmark when the intended base is unclear, and resolve it to a stable change ID. Empty revisions, including merge changes, are valid workspace bases. Ask only if the starting revision cannot be resolved unambiguously. Run `jj workspace add <path_to_target> -r <base_change_id>` with that explicit stable change ID, then perform all changes and verification in the new workspace rather than the user's workspace.
- Reuse the created workspace for the entire session instead of creating new workspaces for every request.
- Do not include newly created, unnecessary empty commits in merge requests. Before preparing an MR, abandon disposable agent-created empty changes, including unused working-copy changes created by `jj commit`; preserve existing base history and meaningful merge changes.
- Do not edit, squash into, describe, or abandon user-owned changes without explicit permission.
- Commit and verify completed work in agent-owned workspaces, then report the deliverables by stable change ID. The parent agent is responsible for reconciling subagent work into its own result before integrating it into the user's checkout.
- Track all agent-created workspace paths, workspace names, and stable change IDs, including temporary benchmark changes and empty changes created by `jj commit`. Before removing a workspace, classify its changes as retained deliverables, integrated/redundant work, or disposable experiments. Verify that needed work is preserved before deliberately abandoning redundant or disposable agent-created changes with `jj abandon <change_id>`. Retain completed deliverables; never discard needed unintegrated work or abandon user-owned or unrelated agents' changes.
- Always identify revisions with stable `jj` change IDs, never commit IDs or commit hashes, because rebases and merges change commit IDs.
- Use `jj diff --git` when inspecting diffs so the output remains readable and correctly marked up even without color.
- Choose commit boundaries by logical scope, not conversation turns.
- I review every commit individually as an evolving change. Address review feedback by amending the existing commit that introduced the reviewed change, preserving its stable `jj` change ID, even if it has already been pushed. Do not add separate follow-up, fixup, or review-fix commits as part of a review unless I explicitly request a new commit. Fold any temporary review-fix commits into the relevant original commits before pushing.
- Squash corrections, replacements, and reversals of earlier agent-authored unpushed work into the relevant commits.
- Prefer rewriting unpushed agent commits and updating my checkout over duplicating history, rebasing as needed while preserving my changes and unrelated work.
- Commit completed logical changes with `jj commit -m <message>`.
- Use scoped commit messages in the form `<scope>: <message>`, following https://scopedcommits.com/.
- Scopes should identify the affected path or product area, such as `services/api/workspaces: add permissions and contracts`.
- In deployment/GitOps repositories, never deploy unilaterally. Pushing or merging to a deployment-triggering ref, applying manifests, or otherwise changing live state requires explicit user approval for that deployment. Explicitly requested pushes to non-deploying merge-request bookmarks are allowed, but a request to push an MR bookmark is not deployment approval. Follow the repository's documented deployment workflow.

# Git forge Communication

- Prepend agent-authored git forge pull/merge-request review comments and discussion replies (including inline comments and review summaries) with the exact prefix `Opencode: ` so I can distinguish them from my own comments.
- Apply this prefix only to review comments and replies, not to pull/merge-request titles, descriptions, or other non-review content.

# Tooling

- If a command is not installed on the system, use Nix to run it from nixpkgs instead of stopping. Example: `nix shell nixpkgs#ruby -c ruby --version`.
- Use the same pattern for one-off tools: `nix shell nixpkgs#<package> -c <command> <args>`.
- For Python with dependencies, create one Python environment with `python3.withPackages` so the interpreter can import every package. Example: `nix shell --impure --expr 'with import <nixpkgs> {}; python3.withPackages (ps: with ps; [ pyyaml requests ])' -c python3 script.py`.
- Use package names from `python3Packages` inside the list and replace `pyyaml requests` as needed. For an interactive shell, end the command with `-c python3`.
- Do not combine `nixpkgs#python3` and separate `nixpkgs#python3Packages.<package>` inputs for this purpose; that can provide an interpreter whose import path does not include the requested modules.

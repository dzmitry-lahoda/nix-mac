/* Hack until codex allow trust overlay ad hoc or other compatible ways to run on nix hm */
{
  codex,
  git,
  writeShellApplication,
}:

writeShellApplication {
  name = "codex-this";
  runtimeInputs = [ git ];
  text = ''
    if project_dir="$(git rev-parse --show-toplevel 2>/dev/null)"; then
      :
    else
      project_dir="$(pwd -P)"
    fi

    escaped_project_dir="''${project_dir//\\/\\\\}"
    escaped_project_dir="''${escaped_project_dir//\"/\\\"}"

    exec ${codex}/bin/codex \
      -c "projects={\"$escaped_project_dir\"={trust_level=\"trusted\"}}" \
      "$@"
  '';
}

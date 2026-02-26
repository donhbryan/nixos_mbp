{ config, pkgs, ... }:

{

  environment.systemPackages = [

    # Custom GitHub Automation Script
    (pkgs.writeShellScriptBin "github-save" ''
      set -e
      TARGET_DIR="$1"
      GITHUB_REPO="$2"
      COMMIT_MSG="''${3:-Automated update}"

      if [ -z "$TARGET_DIR" ] || [ -z "$GITHUB_REPO" ]; then
          echo "Usage: github-save <directory_path> <github_repo_url> [\"commit message\"]"
          exit 1
      fi

      if [ ! -d "$TARGET_DIR" ]; then
          echo "Error: Directory '$TARGET_DIR' does not exist."
          exit 1
      fi

      cd "$TARGET_DIR" || exit

      if [ ! -d ".git" ]; then
          echo "🌱 Initializing new Git repository..."
          git init
          git branch -M main
          git remote add origin "$GITHUB_REPO"
          FIRST_PUSH=true
      else
          echo "✅ Git repository already initialized."
          FIRST_PUSH=false
      fi

      git add .

      if [ -n "$(git status --porcelain)" ]; then
          echo "📝 Committing changes..."
          git commit -m "$COMMIT_MSG"
      else
          echo "🤷 No new files to commit. Checking for unpushed changes..."
      fi

      echo "🚀 Pushing to GitHub..."
      if [ "$FIRST_PUSH" = true ]; then
          git push -u origin main
      else
          git push
      fi
      echo "🎉 Done!"
    '')
  ];
}

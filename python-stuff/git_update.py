import os
import subprocess
from pathlib import Path
import argparse
from typing import List, Tuple, Dict
from datetime import datetime
import getpass

class GitRepoManager:
    def __init__(self, base_path: str, commit_message: str = None):
        self.base_path = Path(base_path).resolve()
        self.commit_message = commit_message or f"Automatic update {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
        self.results = {
            'success': [],
            'failed': [],
            'auth_failed': []
        }
        self.credentials = None

    def find_git_repos(self) -> List[Path]:
        """Recursively find all git repositories in and under the base path."""
        repos = []
        for root, dirs, _ in os.walk(self.base_path):
            # Skip .git directories in the search
            if '.git' in dirs:
                dirs.remove('.git')
            
            # Skip common dependency directories
            for skip_dir in ['node_modules', 'venv', 'env', '__pycache__']:
                if skip_dir in dirs:
                    dirs.remove(skip_dir)
            
            current_path = Path(root)
            if self.is_git_repo(current_path):
                repos.append(current_path)
                # Skip searching in subdirectories of a git repo
                dirs.clear()
        
        return repos

    def is_git_repo(self, path: Path) -> bool:
        """Check if the given path is a git repository."""
        git_dir = path / '.git'
        return git_dir.exists() and git_dir.is_dir()

    def prompt_credentials(self):
        """Prompt user for Git credentials."""
        print("\nEnter your Git credentials:")
        username = input("Username: ").strip()
        password = getpass.getpass("Password/Token: ").strip()
        return username, password

    def set_git_credentials(self, repo_path: Path) -> bool:
        """Set Git credentials for the repository."""
        if not self.credentials:
            self.credentials = self.prompt_credentials()
        
        username, password = self.credentials
        
        # Set Git credential helper to store credentials temporarily
        commands = [
            ['git', 'config', '--local', 'credential.helper', 'store'],
            ['git', 'config', '--local', 'user.name', username],
        ]
        
        for cmd in commands:
            try:
                subprocess.run(cmd, cwd=repo_path, check=True, capture_output=True)
            except subprocess.CalledProcessError:
                return False
        
        # Store credentials
        try:
            credential_input = f'protocol=https\nhost=github.com\nusername={username}\npassword={password}\n'
            subprocess.run(['git', 'credential', 'approve'], 
                         input=credential_input.encode(), 
                         cwd=repo_path,
                         capture_output=True)
            return True
        except subprocess.CalledProcessError:
            return False

    def is_auth_error(self, error_message: str) -> bool:
        """Check if the error message indicates an authentication failure."""
        auth_error_messages = [
            "authentication failed",
            "could not read Username",
            "could not read Password",
            "terminal prompts disabled",
            "403",
            "401",
            "fatal: Authentication failed",
            "access denied",
            "permission denied"
        ]
        return any(msg.lower() in error_message.lower() for msg in auth_error_messages)

    def run_git_command(self, repo_path: Path, command: List[str], retry_auth: bool = True) -> Tuple[bool, str]:
        """Run a git command with authentication retry support."""
        try:
            # First attempt
            result = subprocess.run(
                ['git'] + command,
                cwd=repo_path,
                capture_output=True,
                text=True,
                check=True,
                env={**os.environ, 'GIT_TERMINAL_PROMPT': '0'}
            )
            return True, result.stdout
        except subprocess.CalledProcessError as e:
            error_message = e.stderr
            
            # If it's an authentication error and we should retry
            if retry_auth and self.is_auth_error(error_message):
                print(f"\nAuthentication failed for {repo_path.name}, retrying with new credentials...")
                self.credentials = None  # Clear existing credentials
                
                # Try setting new credentials
                if self.set_git_credentials(repo_path):
                    try:
                        # Retry the command
                        result = subprocess.run(
                            ['git'] + command,
                            cwd=repo_path,
                            capture_output=True,
                            text=True,
                            check=True
                        )
                        return True, result.stdout
                    except subprocess.CalledProcessError as e:
                        return False, f"Error after retry: {e.stderr}"
                else:
                    return False, "Failed to set credentials"
            
            return False, f"Error: {error_message}"
        except Exception as e:
            return False, f"Unexpected error: {str(e)}"

    def get_current_branch(self, repo_path: Path) -> str:
        """Get the current branch name of the repository."""
        success, output = self.run_git_command(repo_path, ['branch', '--show-current'])
        return output.strip() if success else "unknown"

    def has_changes(self, repo_path: Path) -> Tuple[bool, str]:
        """Check if repository has any changes to commit."""
        status_success, status_output = self.run_git_command(repo_path, ['status', '--porcelain'])
        if not status_success:
            return False, f"Failed to check status: {status_output}"
        return bool(status_output.strip()), status_output

    def update_repository(self, repo_path: Path) -> Tuple[bool, List[str], str]:
        """Update a single repository (commit, pull, and push)."""
        messages = []
        try:
            current_branch = self.get_current_branch(repo_path)
            messages.append(f"On branch: {current_branch}")
            
            # Check for changes
            has_local_changes, status = self.has_changes(repo_path)
            
            # If there are changes, commit them
            if has_local_changes:
                messages.append("Found local changes, committing...")
                stage_success, stage_output = self.run_git_command(repo_path, ['add', '.'])
                if not stage_success:
                    return False, messages, f"Failed to stage changes: {stage_output}"
                
                commit_success, commit_output = self.run_git_command(
                    repo_path, ['commit', '-m', self.commit_message]
                )
                if not commit_success:
                    return False, messages, f"Failed to commit changes: {commit_output}"
                messages.append("Changes committed successfully")
            else:
                messages.append("No local changes to commit")
            
            # Pull changes
            messages.append("Pulling changes...")
            pull_success, pull_output = self.run_git_command(repo_path, ['pull'])
            if not pull_success:
                if self.is_auth_error(pull_output):
                    self.results['auth_failed'].append((str(repo_path.relative_to(self.base_path)), pull_output))
                return False, messages, f"Failed to pull: {pull_output}"
            messages.append("Pull successful")
            
            # Push changes
            messages.append("Pushing changes...")
            push_success, push_output = self.run_git_command(repo_path, ['push'])
            if not push_success:
                if self.is_auth_error(push_output):
                    self.results['auth_failed'].append((str(repo_path.relative_to(self.base_path)), push_output))
                return False, messages, f"Failed to push: {push_output}"
            messages.append("Push successful")
            
            return True, messages, "All operations completed successfully"
            
        except Exception as e:
            return False, messages, f"Unexpected error: {str(e)}"

    def process_all_repositories(self, dry_run: bool = False) -> None:
        """Process all repositories and collect results."""
        repos = self.find_git_repos()
        
        if not repos:
            print("No Git repositories found in the specified directory or its subdirectories.")
            return
        
        print(f"\nFound {len(repos)} repositories:")
        for repo in repos:
            print(f"- {repo.relative_to(self.base_path)}")
        
        if dry_run:
            print("\nDry run completed. Use without --dry-run to perform updates.")
            return
        
        print("\nProcessing repositories...")
        for repo in repos:
            repo_path = repo.relative_to(self.base_path)
            print(f"\n=== Processing {repo_path} ===")
            
            success, messages, final_message = self.update_repository(repo)
            for message in messages:
                print(f"  {message}")
            
            if success:
                self.results['success'].append(str(repo_path))
                status_symbol = '✓'
            else:
                self.results['failed'].append((str(repo_path), final_message))
                status_symbol = '✗'
            
            print(f"=== {status_symbol} {final_message} ===")
        
        self.print_summary()

    def print_summary(self) -> None:
        """Print a summary of all operations."""
        print("\n=== Summary ===")
        total = len(self.results['success']) + len(self.results['failed'])
        print(f"Total repositories processed: {total}")
        print(f"Successful: {len(self.results['success'])}")
        print(f"Failed: {len(self.results['failed'])}")
        
        if self.results['success']:
            print("\nSuccessfully updated repositories:")
            for repo in self.results['success']:
                print(f"✓ {repo}")
        
        if self.results['auth_failed']:
            print("\nAuthentication failed repositories:")
            for repo, error in self.results['auth_failed']:
                print(f"🔒 {repo}")
                print(f"  Error: {error}")
        
        if self.results['failed']:
            print("\nFailed repositories (non-auth errors):")
            for repo, error in self.results['failed']:
                if not any(repo == failed_repo for failed_repo, _ in self.results['auth_failed']):
                    print(f"✗ {repo}")
                    print(f"  Error: {error}")

def main():
    parser = argparse.ArgumentParser(description='Recursively update Git repositories in a directory')
    parser.add_argument('path', help='Path to the directory containing Git repositories')
    parser.add_argument('--dry-run', action='store_true', help='Show what would be done without making changes')
    parser.add_argument('--message', '-m', help='Custom commit message')
    args = parser.parse_args()
    
    manager = GitRepoManager(args.path, args.message)
    manager.process_all_repositories(args.dry_run)

if __name__ == "__main__":
    main()
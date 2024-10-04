#!/usr/bin/env python3
import os
import sys
import re
import requests

"""
List all markdown files in the given directory and its subdirectories.

Args:
  directory (str): The directory to search for markdown files. Defaults to the current directory.

Returns:
  list: A list of markdown files in the given directory and its subdirectories.
"""
def list_markdown_files(directory="."):
    markdown_files = []
    for root, _, files in os.walk(directory):
        # ignore node_modules
        if "node_modules" in root:
            continue

        for file in files:
            # ignore files starting with _ (e.g. _sidebar.md or _coverpage.md)
            if file.startswith("_"):
                continue
            if file.endswith(".md"):
                markdown_files.append(os.path.join(root, file))

    return markdown_files

"""
Fetch all commits with the repository URL from the given file.

Args:
    filepath (str): The file to search for commits.

Returns:
    list: A list of urls and commits in the given file.
"""
def fetch_commits_from_file(filepath):
    with open(filepath, "r") as f:
        content = f.read()
        # find git clone and git checkout commands
        return re.findall(r">?\s?git clone (.*)\s+>?\s?git checkout -b .* ([a-z0-9]{7})", content)

"""
Construct a commit URL from the given URL and commit.

Args:
    url (str): The URL of the repository.
    commit (str): The commit hash.

Returns:
    str: The commit URL.
"""
def construct_commit_url(url, commit):
    url = url.replace(".git", "")
    return f"{url}/commit/{commit}"

"""
Check if the given commit exists in the given repository.

Args:
    url (str): The URL to the commit.

Returns:
    bool: True if the commit exists, False otherwise.
"""
def commit_exists(url):
    response = requests.get(url)
    return response.status_code == 200


if __name__ == "__main__":
    # read dir from env GITHUB_WORKSPACE
    directory = os.environ.get("GITHUB_WORKSPACE")
    markdown_files = list_markdown_files(directory)

    should_fail = False

    for file in markdown_files:
        not_existing_commits = []

        commits = fetch_commits_from_file(file)

        for [repoUrl, commit] in commits:
            commitUrl = construct_commit_url(repoUrl, commit)
            if not commit_exists(commitUrl):
                should_fail = True
                not_existing_commits.append([repoUrl, commit])

        if (len(not_existing_commits) == 0):
            continue

        print(file)

        for [repoUrl, commit] in not_existing_commits:
            print(f"\tCommit {commit} does not exist in {repoUrl}")

        print("")

    if not should_fail:
        print("No broken GitHub commit references found.")

    sys.exit(should_fail and 1 or 0)

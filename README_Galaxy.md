# Galaxy Integration


## Develop the Tool Wrapper XML using Planemo

The following commands assume that Planemo is installed.
Either set up the virtual environment using [uv](https://docs.astral.sh/uv/), or install planemo in another way.
uv installation instructions:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
uv sync
source .venv/bin/activate
```

Spin up Galaxy, to run the tool [in the browser](http://127.0.0.1:9090/):

```bash
planemo serve --biocontainers
```

Run the tests (will only succeed on Linux):

```bash
planemo test --biocontainers fileidentification-galaxy.xml
```

Keep in mind:

- Before running the tests, make sure that Docker Desktop for Mac allows bind mounting of `/private/var/folders`.
- If there is more than 1 line inside the CDATA of the `<command>` block,
  the lines must end with `&&` (but NOT with `\`),
  and new lines must NOT be indented.
- Inside the Docker container, the app is installed in `/app`, which is read-only in Galaxy.
- The commands inside the `<command>` block of the XML file are executed in a dedicated user directory defined by Galaxy - 
  not in the `WORKDIR` specified in the Dockerfile.
- Only the user directory is writable, all other dirs are read-only: the input dir, `/app`, ...
- The test asserts on the structure of the JSON report, not on byte-for-byte console text, so it passes
  the same way on macOS and on the Linux CI runner.


### Rebuilding the Docker Image (just for local testing)

If you modify the Python code or `Dockerfile.galaxy`, and open a PR, the automated tests will rebuild the Docker
image. But if you want your local planemo to be aware of your changes, make sure to rebuild the image first:

```bash
TOOL_VERSION=xyz    # copy from macros.xml
docker build -f Dockerfile.galaxy -t daschswiss/fileidentification-galaxy:${TOOL_VERSION} .
```

Note: `Dockerfile.galaxy` is a separate, Galaxy-only image, kept deliberately slim (`--inspect` never
invokes soffice or sipi). The plain `Dockerfile` at the repo root is upstream's and stays untouched, so
syncing the fork never conflicts on it.


## Tool Shed

Publishing to Galaxy's app store <https://toolshed.g2.bx.psu.edu/> is automatically done by tools-iuc,
and configured by `.shed.yml`.
Steps to test if `.shed.yml` is correct:

- Create an account on <https://testtoolshed.g2.bx.psu.edu/>
- Run `planemo config_init`
- In `~/.planemo.yml` > sheds > testtoolshed, fill in your credentials for <https://testtoolshed.g2.bx.psu.edu/>
- Fill in your test account name in `.shed.yml` > owner
- Check the `.shed.yml` with `planemo shed_lint --tools`.
- Create the remote repository with `planemo shed_create --shed_target testtoolshed`.
- DaSCH has an account on the prod toolshed <https://toolshed.g2.bx.psu.edu/>,
  which is not used, because of `owner: iuc`.


## How to update the Galaxy Tool

Follow these steps to bring the latest changes from <https://github.com/dasch-swiss/fileidentification>
into Galaxy's tool shed (app store) <https://toolshed.g2.bx.psu.edu/>.

Make sure the upstream is set correctly:

```bash
% git remote -v
origin	  git@github.com:dasch-swiss/fileidentification-galaxy (fetch)
origin	  git@github.com:dasch-swiss/fileidentification-galaxy (push)
upstream	git@github.com:dasch-swiss/fileidentification.git (fetch)
upstream	git@github.com:dasch-swiss/fileidentification.git (push)
```

Pull in the changes from upstream:

```bash
git fetch upstream
git checkout -b sync-upstream
git merge upstream/main -m "Pull in changes from upstream"
```

If anything has changed on <https://github.com/galaxyproject/tools-iuc/tree/main/tools/fileidentification>,
copy over the changed files into this repo.

Update the versions in `macros.xml`:

- If only the Galaxy wrapper stuff has changed: bump `@VERSION_SUFFIX@`
- If the Python code, Python dependencies, or `Dockerfile.galaxy` have changed:
  bump `@TOOL_VERSION@`, according to the version from `pyproject.toml`.
  This is enforced by a GitHub actions check,
  because the images on Docker Hub are versioned according to `@TOOL_VERSION@`.
  Galaxy will only be able to pull a new image from Docker Hub if a new image has been pushed,
  which only happens if `@TOOL_VERSION@` is bumped.

Then, commit your changes and push them:

```bash
git add macros.xml
git commit -m "update versions in macros.xml"
git push -u origin sync-upstream
gh pr create --title "Synchronize fork with upstream changes"
```

Once the automated tests succeed, merge your PR
using GitHub's "Create a merge commit" option - do NOT squash or rebase.
Squashing the sync PR collapses upstream's commits into a single commit,
which freezes the merge-base at the previous sync point.
The fork then shows up as "behind" upstream on GitHub,
and every future `git merge upstream/main` re-surfaces already-resolved conflicts.
A real merge commit keeps upstream's commits as ancestors, so the fork stays "0 behind".
(Normal feature PRs in this fork can still be squash-merged; only the sync PR needs a merge commit.)

If the Python code, Python dependencies, or `Dockerfile.galaxy` have changed,
this will automatically publish the newest Docker image to
[Docker Hub](https://hub.docker.com/r/daschswiss/fileidentification-galaxy).

Then, open a PR which updates <https://github.com/galaxyproject/tools-iuc/tree/main/tools/fileidentification>.
In the simplest case, you can just copy over the `macros.xml`,
but if you modified anything else, then update the other files, too.
Once the PR in tools-iuc is merged, the Galaxy tool will be updated in Galaxy's tool shed.


## Resources

- Tutorial: Tool development and integration into Galaxy:
  <https://training.galaxyproject.org/training-material/topics/dev/tutorials/tool-integration/slides.html#1>
- Documentation of the XML Schema: <https://docs.galaxyproject.org/en/latest/dev/schema.html>
- ToolShed Readiness Checklist:
  <https://galaxy-iuc-standards.readthedocs.io/en/latest/best_practices/integration_checklist.html>

Toolshed Yaml File:

- <https://planemo.readthedocs.io/en/latest/publishing.html>
- <https://galaxy-iuc-standards.readthedocs.io/en/latest/best_practices/shed_yml.html>

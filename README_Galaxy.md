# Galaxy Integration

Every push to the main branch triggers a rebuild of the Docker image,
and uploads it to [Docker Hub](https://hub.docker.com/r/daschswiss/fileidentification-galaxy).

If you modify the Dockerfile, make sure to build the image before proceeding with Planemo:

```bash
docker build -t daschswiss/fileidentification-galaxy:latest .
```

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
- The Terminal output of the tool slightly differs across operating systems, e.g. regarding the order of files.
  The e2e test will fail on MacOS, because the expected output doesn't exactly match the actual output.
  You can run the e2e test on MacOS anyways, to get a rough idea about what's going on.


## Synchronize this fork with the upstream

Make sure the upstream is set correctly:

```bash
git remote -v
origin	    git@github.com:dasch-swiss/fileidentification-galaxy (fetch)
origin	    git@github.com:dasch-swiss/fileidentification-galaxy (push)
upstream	git@github.com:dasch-swiss/fileidentification.git (fetch)
upstream	git@github.com:dasch-swiss/fileidentification.git (push)
```

Synchronize with upstream: `git fetch upstream; git merge upstream/main -m "Pull in changes from upstream"`,
or better: in the GitHub UI.

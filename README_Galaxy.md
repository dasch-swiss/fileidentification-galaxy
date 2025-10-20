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
planemo serve --biocontainers --galaxy_root=.galaxy
```

Run the tests:

```bash
planemo test --biocontainers --galaxy_root=.galaxy fileidentification-galaxy.xml
```

Keep in mind:

- Before running the tests, make sure that Docker Desktop for Mac allows bind mounting of `/private/var` and `/var`.
- Do not use `\` for line continuation inside the CDATA block of `<command>`.
- Do not indent new lines inside the CDATA block of `<command>`.
- Inside the Docker container, the app is installed in `/app`, which is read-only in Galaxy.
- The commands inside the `<command>` block of the XML file are executed in a dedicated user directory defined by Galaxy - 
  not in the `WORKDIR` specified in the Dockerfile.
- Only the user directory is writable, all other dirs are read-only: the input dir, `/app`, ...


## Synchronize this fork with the upstream

Make sure the upstream is set correctly:

```bash
git remote -v
origin	    git@github.com:dasch-swiss/fileidentification-galaxy (fetch)
origin	    git@github.com:dasch-swiss/fileidentification-galaxy (push)
upstream	git@github.com:dasch-swiss/fileidentification.git (fetch)
upstream	git@github.com:dasch-swiss/fileidentification.git (push)
```

Synchronize with upstream: `git fetch upstream; git merge upstream/main`

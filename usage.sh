# Build the container
make build

# Build and publish the container
make release

# Publish a container to configured repo.
# This includes the login to the repo
make publish

# Build the container with different deploy file
make dpl=another_deploy.env build

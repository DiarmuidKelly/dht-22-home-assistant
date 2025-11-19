#!/bin/bash
# Release script for bumping versions and creating tags
# Usage: ./scripts/release.sh [major|minor|patch]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if argument provided
if [ $# -eq 0 ]; then
    echo -e "${RED}Error: No version bump type specified${NC}"
    echo "Usage: $0 [major|minor|patch]"
    echo "  major: 1.0.0 -> 2.0.0"
    echo "  minor: 1.0.0 -> 1.1.0"
    echo "  patch: 1.0.0 -> 1.0.1"
    exit 1
fi

BUMP_TYPE=$1

# Validate bump type
if [[ ! "$BUMP_TYPE" =~ ^(major|minor|patch)$ ]]; then
    echo -e "${RED}Error: Invalid bump type '$BUMP_TYPE'${NC}"
    echo "Must be one of: major, minor, patch"
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${RED}Error: You have uncommitted changes${NC}"
    echo "Please commit or stash your changes before creating a release"
    exit 1
fi

# Get current version from VERSION file
CURRENT_VERSION=$(cat VERSION)
echo -e "${YELLOW}Current version: ${CURRENT_VERSION}${NC}"

# Split version into components
IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR="${VERSION_PARTS[0]}"
MINOR="${VERSION_PARTS[1]}"
PATCH="${VERSION_PARTS[2]}"

# Bump version based on type
case $BUMP_TYPE in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
esac

NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
echo -e "${GREEN}New version: ${NEW_VERSION}${NC}"

# Confirm with user
read -p "Create release v${NEW_VERSION}? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Release cancelled${NC}"
    exit 0
fi

# Update VERSION file
echo "$NEW_VERSION" > VERSION
echo -e "${GREEN}✓ Updated VERSION file${NC}"

# Update version in main.py
sed -i "s/__version__ = \".*\"/__version__ = \"${NEW_VERSION}\"/" main.py
echo -e "${GREEN}✓ Updated main.py${NC}"

# Update README.md
sed -i "s/version-[0-9]\+\.[0-9]\+\.[0-9]\+-blue/version-${NEW_VERSION}-blue/" README.md
sed -i "s/\*\*Version\*\*: [0-9]\+\.[0-9]\+\.[0-9]\+/**Version**: ${NEW_VERSION}/" README.md
echo -e "${GREEN}✓ Updated README.md${NC}"

# Update CHANGELOG.md - move Unreleased to new version
TODAY=$(date +%Y-%m-%d)
sed -i "s/## \[Unreleased\]/## [Unreleased]\n\n## [${NEW_VERSION}] - ${TODAY}/" CHANGELOG.md
sed -i "s|\[Unreleased\]: .*/compare/v.*\.\.\.HEAD|[Unreleased]: https://github.com/DiarmuidKelly/dht-22-ha/compare/v${NEW_VERSION}...HEAD|" CHANGELOG.md
sed -i "/\[Unreleased\]:/a [${NEW_VERSION}]: https://github.com/DiarmuidKelly/dht-22-ha/releases/tag/v${NEW_VERSION}" CHANGELOG.md
echo -e "${GREEN}✓ Updated CHANGELOG.md${NC}"

# Stage all changes
git add VERSION main.py README.md CHANGELOG.md
echo -e "${GREEN}✓ Staged version updates${NC}"

# Create commit
git commit -m "chore: bump version to ${NEW_VERSION}

- Update VERSION file to ${NEW_VERSION}
- Update __version__ in main.py
- Update version badge in README.md
- Update CHANGELOG.md with release date"

echo -e "${GREEN}✓ Created commit${NC}"

# Create annotated tag
git tag -a "v${NEW_VERSION}" -m "Release version ${NEW_VERSION}

See CHANGELOG.md for details."

echo -e "${GREEN}✓ Created tag v${NEW_VERSION}${NC}"

# Print next steps
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Release v${NEW_VERSION} prepared successfully!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Next steps:"
echo "  1. Review the changes:"
echo "     git show HEAD"
echo "     git show v${NEW_VERSION}"
echo ""
echo "  2. Push to GitHub (this will trigger the release workflow):"
echo "     git push origin main"
echo "     git push origin v${NEW_VERSION}"
echo ""
echo "  3. GitHub Actions will automatically create the release"
echo "     at: https://github.com/DiarmuidKelly/dht-22-ha/releases"
echo ""

#!/bin/bash

mkdir -p ~/.git_template/hooks

cd ~/.git_template/hooks

# Ctags script

cat > ctags << END
#!/bin/sh
set -e
PATH="/usr/local/bin:\$PATH"
trap "rm -f .git/tags.\$$" EXIT
ctags --tag-relative -Rf.git/tags.\$$ --exclude=.git --fields=+l
mv .git/tags.\$$ .git/tags
END

chmod a+x ctags

# Git hooks

cat > post-commit << END
#!/bin/sh
.git/hooks/ctags >/dev/null 2>&1 &
END

cat > post-rewrite << END
#!/bin/sh
case "\$1" in
    rebase) exec .git/hooks/post-merge ;;
esac
END

chmod a+x post-commit post-rewrite

cp post-commit post-merge
cp post-commit post-checkout

# Git global config

git config --global init.templatedir '~/.git_template'

git config --global alias.ctags '!.git/hooks/ctags'


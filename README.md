# Beta Repository Git Remote Task

## Objective
Update the `/usr/src/kodekloudrepos/beta` repository with a new remote, add a file, commit changes, and push to the new remote.

## Steps

1. **Navigate and configure**
```bash
cd /usr/src/kodekloudrepos/beta
git config --global --add safe.directory /usr/src/kodekloudrepos/beta
git config --global user.name "natasha"
git config --global user.email "natasha@ststor01.stratos.xfusioncorp.com"
```

2. **Add remote**
```bash
git remote add dev_beta /opt/xfusioncorp_beta.git
```

3. **Add file and commit**
```bash
cp /tmp/index.html .
git checkout master
git add index.html
git commit -m "Added index.html for beta updates"
```

4. **Push to remote**
```bash
git push dev_beta master
```

## Verification
```bash
git remote -v
git log --oneline
git ls-remote dev_beta
```
# Save2Git

Bash script to save a folder into git repository.

## Installation

```bash
curl -s https://raw.githubusercontent.com/babeuloula/save2git/master/install.sh | sudo bash
```

## How to use

First you need to init your repository:

```bash
save2git --mode init --path /path/to/save
```

Then, you need to push all data to your repository:

```bash
save2git --mode push --path /path/to/save
```

You can easily setting up a CRON task to sync your repository automatically.

```bash
0 0 * * * save2git --mode push --path /path/to/save 2>&1
```

## Uninstallation

```bash
curl -s https://raw.githubusercontent.com/babeuloula/save2git/master/uninstall.sh | sudo bash
```

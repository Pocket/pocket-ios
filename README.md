# Pocket iOS

Welcome to the Next iteration of the Pocket iOS client, currently in development.


# Getting Started

## Setup a Pocket Consumer Key

// TODO: Create a secrets file/


# Build Targets

## Apollo CodeGen

//TODO: Show how to download and generate 
new schema

## Pocket Kit

### Sync

### Textile

### Analytics

### Save To Pocket

## Pocket iOS



## Commit strategy

We prefer to keep out commit history linear (meaning avoiding noisy merge
commits). To keep your branch up to date, follow these steps:

```sh
# while on your PR branch
$ git checkout develop
$ git pull --rebase
$ git checkout my-pr-branch
$ git rebase develop
$ git push origin my-pr-branch --force[-with-lease]
```



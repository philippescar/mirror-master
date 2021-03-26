# Mirror Master aka Repo Syncer

![Mirror Master Flash Enemy with a pistol, Flash reflection in all mirror](./images/mirror-master.jpeg)

## Introduction

Mirror Master is a lightweight docker image that uses [skopeo](https://github.com/containers/skopeo), to sync images between docker images registries, it supports all the registries supported by Skopeo such as _GCR_, _Docker Hub_, _ECR_ and _Quay_.

### If Skopeo does the job why I need this image?

That's a fair question! 

**_Answer:_** Skopeo is awesome to deal with the complexity of docker manifest and authentication between registries, but not with filtering which tags you wanna sync (as you can see [here](https://github.com/containers/skopeo/blob/master/docs/skopeo-sync.1.md) the _sync_ command does not have a `--filter` option), which leaves to you the burden/hassle/fun of list all tags and somehow decide what you want to ignore or not.

_Mirror Master_  is meant to be a simple wrapper around the awesome work of Skopeo, easy to customize and use.

## Default Variables

The default variables are environments variables that can be used to configure the container. 

| Name             | Description                                                                                                                                                          | Mandatory? |
| ---------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :--------: |
| DEST_REGISTRY    | Destination Registry where the images will be copied.                                                                                                                |    YES     |
| DEST_AUTH_PWD    | Destination Registry password if needed.                                                                                                                             |     NO     |
| DEST_AUTH_USER   | Destination Registry username if needed.                                                                                                                             |     NO     |
| IGNORED_TAGS     | Tags from the source registry that should be ignored, the tags need to be declared like: `IGNORED_TAGS="alpine|beta|dev|latest|rc|lts|perl|mainline|stable|py2|py3"` |    YES     |
| SOURCE_REGISTRY  | Source Registry from where the images will be copied.                                                                                                                |    YES     |
| SOURCE_AUTH_PWD  | Source Registry password if needed.                                                                                                                                  |     NO     |
| SOURCE_AUTH_USER | Destination Registry username if needed.                                                                                                                             |     NO     |

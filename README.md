# box

A minimal sandbox wrapper for running commands in an isolated environment. It is ideal to isolate coding agents or testing untrusted Windows software under Wine.

The core idea is to provide a simple way to restrict processes to their own directory without the overhead of starting containers or creating new user accounts.

It is particularly well-suited for isolating agents like ([pi-agent](https://github.com/earendil-works/pi)) into individual directories, preventing them from interfering with the rest of your private files.

## Features

The tool uses a multi-profile approach. It is designed to be minimal and follows the KISS principle. When starting a new box, it draws a shield emoji (🛡️) into your prompt to indicate that you're sandboxed.

## Install

You will need `bwrap` (bubblewrap) installed, which is available in most common distributions or via your package manager.

Copy `box` to `/usr/bin/box` and the `config` directory to `~/.config/box`.

## Usage

Run `box` to use the default profile, or `box wine` to use the Wine profile.

## Profiles

The example configurations include:

| Profile | Description |
| --- | --- |
| default | Basic sandbox with bash configuration |
| pi | Configuration for the pi agent |
| wine | Environment for running Windows software via Wine |

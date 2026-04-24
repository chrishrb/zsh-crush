# zsh-crush

> A `zsh` plugin for Crush CLI

<p align="center">
  <img src="https://i.imgur.com/7C2CYZl.gif" alt="Demo gif">
</p>

## ✔️ Setup

Requires [Crush CLI](https://github.com/chainlift/crush) installed and configured.

> The plugin will check for the `crush` command and other dependencies at source time. To disable this check, set the `ZSH_CRUSH_NO_CHECK` environment variable to `1`.

### Model Configuration

You can configure the AI model to use by setting the `CRUSH_MODEL` environment variable:

```zsh
export CRUSH_MODEL="claude-3-5-sonnet"  # or any other supported model
```

Default model: `claude-haiku-4.5`

## 🚀 Installation

### [antigen](https://github.com/zsh-users/antigen)

Add the following to your `.zshrc`:

```zsh
antigen bundle chrishrb/zsh-crush@main
```

### [oh-my-zsh](http://github.com/robbyrussell/oh-my-zsh)

Clone this repository into `$ZSH_CUSTOM/plugins` (by default `~/.oh-my-zsh/custom/plugins`):

```zsh
git clone https://github.com/chrishrb/zsh-crush ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-crush
```

Add the plugin to the list of plugins for Oh My Zsh to load (inside `~/.zshrc`):

```zsh
plugins=(
    # other plugins...
    zsh-crush
)
```

### [zinit](https://github.com/zdharma-continuum/zinit)

Add the following to your `.zshrc`:

```zsh
zinit light chrishrb/zsh-crush
```

### [zplug](https://github.com/zplug/zplug)

Add the following to your `.zshrc`:

```zsh
zplug "chrishrb/zsh-crush"
```

### [zpm](https://github.com/zpm-zsh/zpm)

Add the following to your `.zshrc`:

```zsh
zpm load chrishrb/zsh-crush
```

## 🧠Usage

Bind the **suggest** and/or **explain** widgets:

### For Linux/Windows

```zsh
bindkey '^[|' zsh_crush_explain  # bind Alt+shift+\ to explain
bindkey '^[\' zsh_crush_suggest  # bind Alt+\ to suggest
```

### For Mac

```zsh
bindkey '»' zsh_crush_explain  # bind Option+shift+\ to explain
bindkey '«' zsh_crush_suggest  # bind Option+\ to suggest
```

### Explanations

To get command explanations, write out the command in your prompt and hit your keybind.

### Suggestions

To get Crush to suggest a command to fulfill a query, type out the query in your prompt and hit your suggest keybind.

## 🤩 Credit

This plugin draws from [`stefanheule/zsh-llm-suggestions`](https://github.com/stefanheule/zsh-llm-suggestions)

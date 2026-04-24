typeset -g CRUSH_CLI_RESULT_FILE
typeset -g CRUSH_MODEL
typeset -g RESET
typeset -g RED
typeset -g GREEN

CRUSH_CLI_RESULT_FILE="${CRUSH_CLI_RESULT_FILE:-/tmp/zsh_crush_cli_result}"
CRUSH_MODEL="${CRUSH_MODEL:-claude-haiku-4.5}"

if type tput >/dev/null; then
    RESET="$(tput sgr0)"
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
else
    RESET=""
    RED=""
    GREEN=""
fi

_echo_exit() {
    printf "%s%s%s" "$RED" "$@" "$RESET" >&2
    return 1
}

if [[ -z $ZSH_CRUSH_NO_CHECK ]]; then
    type tput >/dev/null || _echo_exit "zsh-crush: tput not found."
    type crush >/dev/null || _echo_exit "zsh-crush: crush not found. Install from: https://github.com/chainlift/crush"
fi

_crush_cli() {
    # run crush with the configured model
    crush run --quiet --model "$CRUSH_MODEL" "$@" 2>/dev/null
}

_spinner() {
    local pid=$1
    local delay=0.1
    local spin='⣾⣽⣻⢿⡿⣟⣯⣷'

    cleanup() {
        # shellcheck disable=SC2317
        kill "$pid"
        # shellcheck disable=SC2317
        tput cnorm
    }
    trap cleanup SIGINT

    i=0
    # while the copilot process is running
    tput civis
    while kill -0 "$pid" 2>/dev/null; do
        i=$(((i + 1) % ${#spin}))
        printf "  %s%s%s" "${RED}" ${spin:$i:1} "${RESET}"
        sleep "$delay"
        printf "\b\b\b"
    done
    printf "   \b\b\b"
    tput cnorm
    trap - SIGINT
}

_crush_cli_spinner() {
    # run crush in the background and show a spinner
    read -r < <(
        _crush_cli "$@" >|"$CRUSH_CLI_RESULT_FILE" &
        echo $!
    )
    _spinner "$REPLY" >&2
    cat "$CRUSH_CLI_RESULT_FILE"
}

_crush_cli_explain() {
    local result
    result="$(_crush_cli_spinner "Explain this shell command: $*. Format your explanation as bullet points starting with •")"
    result="$(__strip_markdown_formatting "$result")"
    __trim_string "$result"
}

_crush_cli_suggest() {
    local result
    result="$(_crush_cli_spinner "Suggest a shell command for: $*. Output ONLY the command, no explanation.")"
    result="$(__strip_markdown_code "$result")"
    __trim_string "$result"
}

__trim_string() {
    # reomve leading and trailing whitespaces
    # from https://github.com/dylanaraps/pure-bash-bible?tab=readme-ov-file#trim-leading-and-trailing-white-space-from-string
    # Usage: trim_string "   example   string    "
    : "${1#"${1%%[![:space:]]*}"}"
    : "${_%"${_##*[![:space:]]}"}"
    printf '%s\n' "$_"
}

__strip_markdown_code() {
    # Remove markdown code blocks and extract just the command
    local input="$1"
    local result
    result="$(echo "$input" | sed -E '/^```/d')"
    __trim_string "$result"
}

__strip_markdown_formatting() {
    # Remove markdown formatting (bold, italic, code blocks)
    local input="$1"
    echo "$input" | sed -E 's/\*\*([^*]+)\*\*/\1/g; s/\*([^*]+)\*/\1/g; s/`([^`]+)`/\1/g'
}

_prompt_msg() {
    # print a message to the prompt
    printf "\n%s%s%s\n\n" "$GREEN" "$@" "$RESET"
    # this isn't great because it might not work with multiline prompts
    zle reset-prompt
}

zsh_crush_suggest() {
    # based on https://github.com/stefanheule/zsh-llm-suggestions/blob/master/zsh-llm-suggestions.zsh#L65
    # check if the buffer is empty
    [ -z "$BUFFER" ] && return
    zle end-of-line

    local result
    # place the query in history
    print -s "$BUFFER"
    result="$(_crush_cli_suggest "$BUFFER")"
    [ -z "$result" ] && _prompt_msg "No suggestion found" && return
    zle reset-prompt
    # replace the current buffer with the result
    BUFFER="${result}"
    # shellcheck disable=SC2034
    CURSOR=${#BUFFER}
}

zsh_crush_explain() {
    # based on https://github.com/stefanheule/zsh-llm-suggestions/blob/master/zsh-llm-suggestions.zsh#L71
    # check if the buffer is empty
    [ -z "$BUFFER" ] && return
    zle end-of-line

    local result
    result="$(_crush_cli_explain "$BUFFER")"
    _prompt_msg "${result:-No explanation found}"
}

zle -N zsh_crush_suggest
zle -N zsh_crush_explain

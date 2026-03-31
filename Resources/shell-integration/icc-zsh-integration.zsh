# icc shell integration for zsh
# Injected automatically — do not source manually

_icc_send() {
    local payload="$1"
    if command -v ncat >/dev/null 2>&1; then
        print -r -- "$payload" | ncat -w 1 -U "$ICC_SOCKET_PATH" --send-only
    elif command -v socat >/dev/null 2>&1; then
        print -r -- "$payload" | socat -T 1 - "UNIX-CONNECT:$ICC_SOCKET_PATH" >/dev/null 2>&1
    elif command -v nc >/dev/null 2>&1; then
        # Some nc builds don't support unix sockets, but keep as a last-ditch fallback.
        #
        # Important: macOS/BSD nc will often wait for the peer to close the socket
        # after it has finished writing. icc keeps the connection open, so
        # a plain `nc -U` can hang indefinitely and leak background processes.
        #
        # Prefer flags that guarantee we exit after sending, and fall back to a
        # short timeout so we never block sidebar updates.
        if print -r -- "$payload" | nc -N -U "$ICC_SOCKET_PATH" >/dev/null 2>&1; then
            :
        else
            print -r -- "$payload" | nc -w 1 -U "$ICC_SOCKET_PATH" >/dev/null 2>&1 || true
        fi
    fi
}

_icc_restore_scrollback_once() {
    local path="${ICC_RESTORE_SCROLLBACK_FILE:-}"
    [[ -n "$path" ]] || return 0
    unset ICC_RESTORE_SCROLLBACK_FILE

    if [[ -r "$path" ]]; then
        /bin/cat -- "$path" 2>/dev/null || true
        /bin/rm -f -- "$path" >/dev/null 2>&1 || true
    fi
}
_icc_restore_scrollback_once

# Throttle heavy work to avoid prompt latency.
typeset -g _ICC_PWD_LAST_PWD=""
typeset -g _ICC_GIT_LAST_PWD=""
typeset -g _ICC_GIT_LAST_RUN=0
typeset -g _ICC_GIT_JOB_PID=""
typeset -g _ICC_GIT_JOB_STARTED_AT=0
typeset -g _ICC_GIT_FORCE=0
typeset -g _ICC_GIT_HEAD_LAST_PWD=""
typeset -g _ICC_GIT_HEAD_PATH=""
typeset -g _ICC_GIT_HEAD_SIGNATURE=""
typeset -g _ICC_GIT_HEAD_WATCH_PID=""
typeset -g _ICC_PR_POLL_PID=""
typeset -g _ICC_PR_POLL_PWD=""
typeset -g _ICC_PR_POLL_INTERVAL=45
typeset -g _ICC_PR_FORCE=0
typeset -g _ICC_ASYNC_JOB_TIMEOUT=20

typeset -g _ICC_PORTS_LAST_RUN=0
typeset -g _ICC_CMD_START=0
typeset -g _ICC_SHELL_ACTIVITY_LAST=""
typeset -g _ICC_TTY_NAME=""
typeset -g _ICC_TTY_REPORTED=0
typeset -g _ICC_GHOSTTY_SEMANTIC_PATCHED=0
typeset -g _ICC_WINCH_GUARD_INSTALLED=0
typeset -g _ICC_TMUX_PUSH_SIGNATURE=""
typeset -g _ICC_TMUX_PULL_SIGNATURE=""
typeset -ga _ICC_TMUX_SYNC_KEYS=(
    ICC_BUNDLED_CLI_PATH
    ICC_BUNDLE_ID
    ICCD_UNIX_PATH
    ICC_REPO_ROOT
    ICC_DEBUG_LOG
    ICC_LOAD_GHOSTTY_ZSH_INTEGRATION
    ICC_PORT
    ICC_PORT_END
    ICC_PORT_RANGE
    ICC_REMOTE_DAEMON_ALLOW_LOCAL_BUILD
    ICC_SHELL_INTEGRATION
    ICC_SHELL_INTEGRATION_DIR
    ICC_SOCKET_ENABLE
    ICC_SOCKET_MODE
    ICC_SOCKET_PATH
    ICC_TAB_ID
    ICC_TAG
    ICC_WORKSPACE_ID
)
typeset -ga _ICC_TMUX_SURFACE_SCOPED_KEYS=(
    ICC_PANEL_ID
    ICC_SURFACE_ID
)

_icc_tmux_sync_key_is_managed() {
    local candidate="$1"
    local key
    for key in "${_ICC_TMUX_SYNC_KEYS[@]}"; do
        [[ "$key" == "$candidate" ]] && return 0
    done
    return 1
}

_icc_tmux_shell_env_signature() {
    local key value
    local -a parts
    for key in "${_ICC_TMUX_SYNC_KEYS[@]}"; do
        value="${(P)key}"
        [[ -n "$value" ]] || continue
        parts+=("${key}=${value}")
    done
    print -r -- "${(j:\x1f:)parts}"
}

_icc_tmux_publish_icc_environment() {
    [[ -z "$TMUX" ]] || return 0
    command -v tmux >/dev/null 2>&1 || return 0

    local signature
    signature="$(_icc_tmux_shell_env_signature)"
    [[ -n "$signature" ]] || return 0
    [[ "$signature" == "$_ICC_TMUX_PUSH_SIGNATURE" ]] && return 0

    local key value
    for key in "${_ICC_TMUX_SYNC_KEYS[@]}"; do
        value="${(P)key}"
        [[ -n "$value" ]] || continue
        tmux set-environment -g "$key" "$value" >/dev/null 2>&1 || return 0
    done

    for key in "${_ICC_TMUX_SURFACE_SCOPED_KEYS[@]}"; do
        tmux set-environment -gu "$key" >/dev/null 2>&1 || return 0
    done

    _ICC_TMUX_PUSH_SIGNATURE="$signature"
}

_icc_tmux_refresh_icc_environment() {
    [[ -n "$TMUX" ]] || return 0
    command -v tmux >/dev/null 2>&1 || return 0

    local output
    output="$(tmux show-environment -g 2>/dev/null)" || return 0

    local line key filtered="" did_change=0
    while IFS= read -r line; do
        [[ "$line" == ICC_* ]] || continue
        key="${line%%=*}"
        _icc_tmux_sync_key_is_managed "$key" || continue
        filtered+="${line}"$'\n'
    done <<< "$output"

    [[ -n "$filtered" ]] || return 0
    [[ "$filtered" == "$_ICC_TMUX_PULL_SIGNATURE" ]] && return 0

    local value
    while IFS= read -r line; do
        [[ "$line" == ICC_* ]] || continue
        key="${line%%=*}"
        _icc_tmux_sync_key_is_managed "$key" || continue
        value="${line#*=}"
        if [[ "${(P)key}" != "$value" ]]; then
            export "$key=$value"
            did_change=1
        fi
    done <<< "$filtered"

    _ICC_TMUX_PULL_SIGNATURE="$filtered"
    if (( did_change )); then
        _ICC_TTY_REPORTED=0
        _ICC_SHELL_ACTIVITY_LAST=""
        _ICC_PWD_LAST_PWD=""
        _ICC_GIT_LAST_PWD=""
        _ICC_GIT_HEAD_LAST_PWD=""
        _ICC_GIT_HEAD_PATH=""
        _ICC_GIT_HEAD_SIGNATURE=""
        _ICC_GIT_FORCE=1
        _ICC_PR_FORCE=1
        _icc_stop_pr_poll_loop
        _icc_stop_git_head_watch
    fi
}

_icc_tmux_sync_icc_environment() {
    if [[ -n "$TMUX" ]]; then
        _icc_tmux_refresh_icc_environment
    else
        _icc_tmux_publish_icc_environment
    fi
}

_icc_ensure_ghostty_preexec_strips_both_marks() {
    local fn_name="$1"
    (( $+functions[$fn_name] )) || return 0

    local old_strip new_strip updated
    old_strip=$'PS1=${PS1//$\'%{\\e]133;A;cl=line\\a%}\'}'
    new_strip=$'PS1=${PS1//$\'%{\\e]133;A;redraw=last;cl=line\\a%}\'}'
    updated="${functions[$fn_name]}"

    if [[ "$updated" == *"$new_strip"* && "$updated" != *"$old_strip"* ]]; then
        updated="${updated/$new_strip/$old_strip
        $new_strip}"
        functions[$fn_name]="$updated"
        _ICC_GHOSTTY_SEMANTIC_PATCHED=1
        return 0
    fi
    if [[ "$updated" == *"$old_strip"* && "$updated" != *"$new_strip"* ]]; then
        updated="${updated/$old_strip/$old_strip
        $new_strip}"
        functions[$fn_name]="$updated"
        _ICC_GHOSTTY_SEMANTIC_PATCHED=1
    fi
}

_icc_patch_ghostty_semantic_redraw() {
    local old_frag new_frag
    old_frag='133;A;cl=line'
    new_frag='133;A;redraw=last;cl=line'

    # Patch both deferred and live hook definitions, depending on init timing.
    if (( $+functions[_ghostty_deferred_init] )); then
        functions[_ghostty_deferred_init]="${functions[_ghostty_deferred_init]//$old_frag/$new_frag}"
        _ICC_GHOSTTY_SEMANTIC_PATCHED=1
    fi
    if (( $+functions[_ghostty_precmd] )); then
        functions[_ghostty_precmd]="${functions[_ghostty_precmd]//$old_frag/$new_frag}"
        _ICC_GHOSTTY_SEMANTIC_PATCHED=1
    fi
    if (( $+functions[_ghostty_preexec] )); then
        functions[_ghostty_preexec]="${functions[_ghostty_preexec]//$old_frag/$new_frag}"
        _ICC_GHOSTTY_SEMANTIC_PATCHED=1
    fi

    # Keep legacy + redraw-aware strip lines so prompts created before patching
    # are still cleared by preexec.
    _icc_ensure_ghostty_preexec_strips_both_marks _ghostty_deferred_init
    _icc_ensure_ghostty_preexec_strips_both_marks _ghostty_preexec
}
_icc_patch_ghostty_semantic_redraw

_icc_prompt_wrap_guard() {
    local cmd_start="$1"
    local pwd="$2"
    [[ -n "$cmd_start" && "$cmd_start" != 0 ]] || return 0

    local cols="${COLUMNS:-0}"
    (( cols > 0 )) || return 0

    local budget=$(( cols - 24 ))
    (( budget < 20 )) && budget=20
    (( ${#pwd} >= budget )) || return 0

    # Keep a spacer line between command output and a wrapped prompt so
    # resize-driven prompt redraw cannot overwrite the command tail.
    builtin print -r -- ""
}

_icc_install_winch_guard() {
    (( _ICC_WINCH_GUARD_INSTALLED )) && return 0

    # Respect user-defined WINCH handlers (function-based or trap-based).
    local existing_winch_trap=""
    existing_winch_trap="$(trap -p WINCH 2>/dev/null || true)"
    if (( $+functions[TRAPWINCH] )) || [[ -n "$existing_winch_trap" ]]; then
        _ICC_WINCH_GUARD_INSTALLED=1
        return 0
    fi

    TRAPWINCH() {
        [[ -n "$ICC_TAB_ID" ]] || return 0
        [[ -n "$ICC_PANEL_ID" ]] || return 0

        # Ghostty already marks prompt redraws on SIGWINCH. Writing to the PTY
        # here grows the screen and makes resize look like a fresh prompt.
        return 0
    }

    _ICC_WINCH_GUARD_INSTALLED=1
}
_icc_install_winch_guard

_icc_git_resolve_head_path() {
    # Resolve the HEAD file path without invoking git (fast; works for worktrees).
    local dir="$PWD"
    while true; do
        if [[ -d "$dir/.git" ]]; then
            print -r -- "$dir/.git/HEAD"
            return 0
        fi
        if [[ -f "$dir/.git" ]]; then
            local line gitdir
            line="$(<"$dir/.git")"
            if [[ "$line" == gitdir:* ]]; then
                gitdir="${line#gitdir:}"
                gitdir="${gitdir## }"
                gitdir="${gitdir%% }"
                [[ -n "$gitdir" ]] || return 1
                [[ "$gitdir" != /* ]] && gitdir="$dir/$gitdir"
                print -r -- "$gitdir/HEAD"
                return 0
            fi
        fi
        [[ "$dir" == "/" || -z "$dir" ]] && break
        dir="${dir:h}"
    done
    return 1
}

_icc_git_head_signature() {
    local head_path="$1"
    [[ -n "$head_path" && -r "$head_path" ]] || return 1
    local line=""
    if IFS= read -r line < "$head_path"; then
        print -r -- "$line"
        return 0
    fi
    return 1
}

_icc_report_tty_payload() {
    [[ -n "$ICC_TAB_ID" ]] || return 0
    [[ -n "$_ICC_TTY_NAME" ]] || return 0

    local payload="report_tty $_ICC_TTY_NAME --tab=$ICC_TAB_ID"
    if [[ -z "$TMUX" ]]; then
        [[ -n "$ICC_PANEL_ID" ]] || return 0
        payload+=" --panel=$ICC_PANEL_ID"
    fi

    print -r -- "$payload"
}

_icc_report_tty_once() {
    # Send the TTY name to the app once per session so the batched port scanner
    # knows which TTY belongs to this panel.
    (( _ICC_TTY_REPORTED )) && return 0
    [[ -S "$ICC_SOCKET_PATH" ]] || return 0

    local payload=""
    payload="$(_icc_report_tty_payload)"
    [[ -n "$payload" ]] || return 0

    _ICC_TTY_REPORTED=1
    {
        _icc_send "$payload"
    } >/dev/null 2>&1 &!
}

_icc_report_shell_activity_state() {
    local state="$1"
    [[ -n "$state" ]] || return 0
    [[ -S "$ICC_SOCKET_PATH" ]] || return 0
    [[ -n "$ICC_TAB_ID" ]] || return 0
    [[ -n "$ICC_PANEL_ID" ]] || return 0
    [[ "$_ICC_SHELL_ACTIVITY_LAST" == "$state" ]] && return 0
    _ICC_SHELL_ACTIVITY_LAST="$state"
    {
        _icc_send "report_shell_state $state --tab=$ICC_TAB_ID --panel=$ICC_PANEL_ID"
    } >/dev/null 2>&1 &!
}

_icc_ports_kick() {
    # Lightweight: just tell the app to run a batched scan for this panel.
    # The app coalesces kicks across all panels and runs a single ps+lsof.
    [[ -S "$ICC_SOCKET_PATH" ]] || return 0
    [[ -n "$ICC_TAB_ID" ]] || return 0
    [[ -n "$ICC_PANEL_ID" ]] || return 0
    _ICC_PORTS_LAST_RUN=$EPOCHSECONDS
    {
        _icc_send "ports_kick --tab=$ICC_TAB_ID --panel=$ICC_PANEL_ID"
    } >/dev/null 2>&1 &!
}

_icc_report_git_branch_for_path() {
    local repo_path="$1"
    [[ -n "$repo_path" ]] || return 0
    [[ -S "$ICC_SOCKET_PATH" ]] || return 0
    [[ -n "$ICC_TAB_ID" ]] || return 0
    [[ -n "$ICC_PANEL_ID" ]] || return 0

    # Skip git operations if not in a git repository to avoid TCC prompts
    git -C "$repo_path" rev-parse --git-dir >/dev/null 2>&1 || return 0

    local branch dirty_opt="" first
    branch="$(git -C "$repo_path" branch --show-current 2>/dev/null)"
    if [[ -n "$branch" ]]; then
        first="$(git -C "$repo_path" status --porcelain -uno 2>/dev/null | head -1)"
        [[ -n "$first" ]] && dirty_opt="--status=dirty"
        _icc_send "report_git_branch $branch $dirty_opt --tab=$ICC_TAB_ID --panel=$ICC_PANEL_ID"
    else
        _icc_send "clear_git_branch --tab=$ICC_TAB_ID --panel=$ICC_PANEL_ID"
    fi
}

_icc_clear_pr_for_panel() {
    [[ -S "$ICC_SOCKET_PATH" ]] || return 0
    [[ -n "$ICC_TAB_ID" ]] || return 0
    [[ -n "$ICC_PANEL_ID" ]] || return 0
    _icc_send "clear_pr --tab=$ICC_TAB_ID --panel=$ICC_PANEL_ID"
}

_icc_pr_output_indicates_no_pull_request() {
    local output="${1:l}"
    [[ "$output" == *"no pull requests found"* \
        || "$output" == *"no pull request found"* \
        || "$output" == *"no pull requests associated"* \
        || "$output" == *"no pull request associated"* ]]
}

_icc_github_repo_slug_for_path() {
    local repo_path="$1"
    local remote_url="" path_part=""
    [[ -n "$repo_path" ]] || return 0

    remote_url="$(git -C "$repo_path" remote get-url origin 2>/dev/null)"
    [[ -n "$remote_url" ]] || return 0

    case "$remote_url" in
        git@github.com:*)
            path_part="${remote_url#git@github.com:}"
            ;;
        ssh://git@github.com/*)
            path_part="${remote_url#ssh://git@github.com/}"
            ;;
        https://github.com/*)
            path_part="${remote_url#https://github.com/}"
            ;;
        http://github.com/*)
            path_part="${remote_url#http://github.com/}"
            ;;
        git://github.com/*)
            path_part="${remote_url#git://github.com/}"
            ;;
        *)
            return 0
            ;;
    esac

    path_part="${path_part%.git}"
    [[ "$path_part" == */* ]] || return 0
    print -r -- "$path_part"
}

_icc_report_pr_for_path() {
    local repo_path="$1"
    [[ -n "$repo_path" ]] || {
        _icc_clear_pr_for_panel
        return 0
    }
    [[ -d "$repo_path" ]] || {
        _icc_clear_pr_for_panel
        return 0
    }
    [[ -S "$ICC_SOCKET_PATH" ]] || return 0
    [[ -n "$ICC_TAB_ID" ]] || return 0
    [[ -n "$ICC_PANEL_ID" ]] || return 0

    local branch repo_slug="" gh_output="" gh_error="" err_file="" number state url status_opt="" gh_status
    local -a gh_repo_args
    gh_repo_args=()
    branch="$(git -C "$repo_path" branch --show-current 2>/dev/null)"
    if [[ -z "$branch" ]] || ! command -v gh >/dev/null 2>&1; then
        _icc_clear_pr_for_panel
        return 0
    fi
    repo_slug="$(_icc_github_repo_slug_for_path "$repo_path")"
    if [[ -n "$repo_slug" ]]; then
        gh_repo_args=(--repo "$repo_slug")
    fi

    err_file="$(/usr/bin/mktemp "${TMPDIR:-/tmp}/icc-gh-pr-view.XXXXXX" 2>/dev/null || true)"
    [[ -n "$err_file" ]] || return 1
    gh_output="$(
        builtin cd "$repo_path" 2>/dev/null \
            && gh pr view "$branch" \
                "${gh_repo_args[@]}" \
                --json number,state,url \
                --jq '[.number, .state, .url] | @tsv' \
                2>"$err_file"
    )"
    gh_status=$?
    if [[ -f "$err_file" ]]; then
        gh_error="$("/bin/cat" -- "$err_file" 2>/dev/null || true)"
        /bin/rm -f -- "$err_file" >/dev/null 2>&1 || true
    fi

    if (( gh_status != 0 )) || [[ -z "$gh_output" ]]; then
        if (( gh_status == 0 )) && [[ -z "$gh_output" ]]; then
            _icc_clear_pr_for_panel
            return 0
        fi
        if _icc_pr_output_indicates_no_pull_request "$gh_error"; then
            _icc_clear_pr_for_panel
            return 0
        fi

        # Always scope PR detection to the exact current branch. When gh fails
        # transiently (auth hiccups, API lag, rate limiting), keep the last-known
        # badge and retry on the next poll instead of showing a mismatched PR.
        return 1
    fi

    local IFS=$'\t'
    read -r number state url <<< "$gh_output"
    if [[ -z "$number" ]] || [[ -z "$url" ]]; then
        return 1
    fi

    case "$state" in
        MERGED) status_opt="--state=merged" ;;
        OPEN) status_opt="--state=open" ;;
        CLOSED) status_opt="--state=closed" ;;
        *) return 1 ;;
    esac

    local quoted_branch="${branch//\"/\\\"}"
    _icc_send "report_pr $number $url $status_opt --branch=\"$quoted_branch\" --tab=$ICC_TAB_ID --panel=$ICC_PANEL_ID"
}

_icc_child_pids() {
    local parent_pid="$1"
    [[ -n "$parent_pid" ]] || return 0
    /bin/ps -ax -o pid= -o ppid= 2>/dev/null | /usr/bin/awk -v parent="$parent_pid" '$2 == parent { print $1 }'
}

_icc_kill_process_tree() {
    local pid="$1"
    local signal="${2:-TERM}"
    local child_pid=""
    [[ -n "$pid" ]] || return 0

    while IFS= read -r child_pid; do
        [[ -n "$child_pid" ]] || continue
        [[ "$child_pid" == "$pid" ]] && continue
        _icc_kill_process_tree "$child_pid" "$signal"
    done < <(_icc_child_pids "$pid")

    kill "-$signal" "$pid" >/dev/null 2>&1 || true
}

_icc_run_pr_probe_with_timeout() {
    local repo_path="$1"
    local probe_pid=""
    local started_at=$EPOCHSECONDS
    local now=$started_at

    (
        _icc_report_pr_for_path "$repo_path"
    ) &
    probe_pid=$!

    while kill -0 "$probe_pid" >/dev/null 2>&1; do
        sleep 1
        now=$EPOCHSECONDS
        if (( _ICC_ASYNC_JOB_TIMEOUT > 0 )) && (( now - started_at >= _ICC_ASYNC_JOB_TIMEOUT )); then
            _icc_kill_process_tree "$probe_pid" TERM
            sleep 0.2
            if kill -0 "$probe_pid" >/dev/null 2>&1; then
                _icc_kill_process_tree "$probe_pid" KILL
                sleep 0.2
            fi
            if ! kill -0 "$probe_pid" >/dev/null 2>&1; then
                wait "$probe_pid" >/dev/null 2>&1 || true
            fi
            return 1
        fi
    done

    wait "$probe_pid"
}

_icc_stop_pr_poll_loop() {
    if [[ -n "$_ICC_PR_POLL_PID" ]]; then
        # Use SIGKILL directly to avoid blocking sleep in preexec.
        # The poll loop is lightweight and safe to kill abruptly.
        _icc_kill_process_tree "$_ICC_PR_POLL_PID" KILL
        _ICC_PR_POLL_PID=""
    fi
}

_icc_start_pr_poll_loop() {
    [[ -S "$ICC_SOCKET_PATH" ]] || return 0
    [[ -n "$ICC_TAB_ID" ]] || return 0
    [[ -n "$ICC_PANEL_ID" ]] || return 0

    local watch_pwd="${1:-$PWD}"
    local force_restart="${2:-0}"
    local watch_shell_pid="$$"
    local interval="${_ICC_PR_POLL_INTERVAL:-45}"

    if [[ "$force_restart" != "1" && "$watch_pwd" == "$_ICC_PR_POLL_PWD" && -n "$_ICC_PR_POLL_PID" ]] \
        && kill -0 "$_ICC_PR_POLL_PID" 2>/dev/null; then
        return 0
    fi

    _icc_stop_pr_poll_loop
    _ICC_PR_POLL_PWD="$watch_pwd"

    {
        while true; do
            kill -0 "$watch_shell_pid" >/dev/null 2>&1 || break
            _icc_run_pr_probe_with_timeout "$watch_pwd" || true
            sleep "$interval"
        done
    } >/dev/null 2>&1 &!
    _ICC_PR_POLL_PID=$!
}

_icc_stop_git_head_watch() {
    if [[ -n "$_ICC_GIT_HEAD_WATCH_PID" ]]; then
        kill "$_ICC_GIT_HEAD_WATCH_PID" >/dev/null 2>&1 || true
        _ICC_GIT_HEAD_WATCH_PID=""
    fi
}

_icc_start_git_head_watch() {
    [[ -S "$ICC_SOCKET_PATH" ]] || return 0
    [[ -n "$ICC_TAB_ID" ]] || return 0
    [[ -n "$ICC_PANEL_ID" ]] || return 0

    local watch_pwd="$PWD"
    local watch_head_path
    watch_head_path="$(_icc_git_resolve_head_path 2>/dev/null || true)"
    [[ -n "$watch_head_path" ]] || return 0

    local watch_head_signature
    watch_head_signature="$(_icc_git_head_signature "$watch_head_path" 2>/dev/null || true)"

    _ICC_GIT_HEAD_LAST_PWD="$watch_pwd"
    _ICC_GIT_HEAD_PATH="$watch_head_path"
    _ICC_GIT_HEAD_SIGNATURE="$watch_head_signature"

    _icc_stop_git_head_watch
    {
        local last_signature="$watch_head_signature"
        while true; do
            sleep 1

            local signature
            signature="$(_icc_git_head_signature "$watch_head_path" 2>/dev/null || true)"
            if [[ -n "$signature" && "$signature" != "$last_signature" ]]; then
                last_signature="$signature"
                _icc_report_git_branch_for_path "$watch_pwd"
            fi
        done
    } >/dev/null 2>&1 &!
    _ICC_GIT_HEAD_WATCH_PID=$!
}

_icc_preexec() {
    _icc_tmux_sync_icc_environment

    if [[ -z "$_ICC_TTY_NAME" ]]; then
        local t
        t="$(tty 2>/dev/null || true)"
        t="${t##*/}"
        [[ -n "$t" && "$t" != "not a tty" ]] && _ICC_TTY_NAME="$t"
    fi

    _ICC_CMD_START=$EPOCHSECONDS
    _icc_report_shell_activity_state running

    # Heuristic: commands that may change git branch/dirty state without changing $PWD.
    local cmd="${1## }"
    case "$cmd" in
        git\ *|git|gh\ *|lazygit|lazygit\ *|tig|tig\ *|gitui|gitui\ *|stg\ *|jj\ *)
            _ICC_GIT_FORCE=1
            _ICC_PR_FORCE=1 ;;
    esac

    # Register TTY + kick batched port scan for foreground commands (servers).
    _icc_report_tty_once
    _icc_ports_kick
    _icc_stop_pr_poll_loop
    _icc_start_git_head_watch
}

_icc_precmd() {
    _icc_stop_git_head_watch
    _icc_tmux_sync_icc_environment

    # Skip if socket doesn't exist yet
    [[ -S "$ICC_SOCKET_PATH" ]] || return 0
    [[ -n "$ICC_TAB_ID" ]] || return 0
    [[ -n "$ICC_PANEL_ID" ]] || return 0
    _icc_report_shell_activity_state prompt

    # Handle cases where Ghostty integration initializes after this file.
    _icc_patch_ghostty_semantic_redraw

    if [[ -z "$_ICC_TTY_NAME" ]]; then
        local t
        t="$(tty 2>/dev/null || true)"
        t="${t##*/}"
        [[ -n "$t" && "$t" != "not a tty" ]] && _ICC_TTY_NAME="$t"
    fi

    _icc_report_tty_once

    local now=$EPOCHSECONDS
    local pwd="$PWD"
    local cmd_start="$_ICC_CMD_START"
    _ICC_CMD_START=0

    _icc_prompt_wrap_guard "$cmd_start" "$pwd"

    # Post-wake socket writes can occasionally leave a probe process wedged.
    # If one probe is stale, clear the guard so fresh async probes can resume.
    if [[ -n "$_ICC_GIT_JOB_PID" ]]; then
        if ! kill -0 "$_ICC_GIT_JOB_PID" 2>/dev/null; then
            _ICC_GIT_JOB_PID=""
            _ICC_GIT_JOB_STARTED_AT=0
        elif (( _ICC_GIT_JOB_STARTED_AT > 0 )) && (( now - _ICC_GIT_JOB_STARTED_AT >= _ICC_ASYNC_JOB_TIMEOUT )); then
            _ICC_GIT_JOB_PID=""
            _ICC_GIT_JOB_STARTED_AT=0
            _ICC_GIT_FORCE=1
        fi
    fi

    # CWD: keep the app in sync with the actual shell directory.
    # This is also the simplest way to test sidebar directory behavior end-to-end.
    if [[ "$pwd" != "$_ICC_PWD_LAST_PWD" ]]; then
        _ICC_PWD_LAST_PWD="$pwd"
        {
            # Quote to preserve spaces.
            local qpwd="${pwd//\"/\\\"}"
            _icc_send "report_pwd \"${qpwd}\" --tab=$ICC_TAB_ID --panel=$ICC_PANEL_ID"
        } >/dev/null 2>&1 &!
    fi

    # Git branch/dirty: update immediately on directory change, otherwise every ~3s.
    # While a foreground command is running, _icc_start_git_head_watch probes HEAD
    # once per second so agent-initiated git checkouts still surface quickly.
    local should_git=0
    local git_head_changed=0

    # Git branch can change without a `git ...`-prefixed command (aliases like `gco`,
    # tools like `gh pr checkout`, etc.). Detect HEAD changes and force a refresh.
    if [[ "$pwd" != "$_ICC_GIT_HEAD_LAST_PWD" ]]; then
        _ICC_GIT_HEAD_LAST_PWD="$pwd"
        _ICC_GIT_HEAD_PATH="$(_icc_git_resolve_head_path 2>/dev/null || true)"
        _ICC_GIT_HEAD_SIGNATURE=""
    fi
    if [[ -n "$_ICC_GIT_HEAD_PATH" ]]; then
        local head_signature
        head_signature="$(_icc_git_head_signature "$_ICC_GIT_HEAD_PATH" 2>/dev/null || true)"
        if [[ -n "$head_signature" ]]; then
            if [[ -z "$_ICC_GIT_HEAD_SIGNATURE" ]]; then
                # The first observed HEAD value establishes the baseline for this
                # shell session. Don't treat it as a branch change or we'll clear
                # restore-seeded PR badges before the first background probe runs.
                _ICC_GIT_HEAD_SIGNATURE="$head_signature"
            elif [[ "$head_signature" != "$_ICC_GIT_HEAD_SIGNATURE" ]]; then
                _ICC_GIT_HEAD_SIGNATURE="$head_signature"
                git_head_changed=1
                # Treat HEAD file change like a git command — force-replace any
                # running probe so the sidebar picks up the new branch immediately.
                _ICC_GIT_FORCE=1
                _ICC_PR_FORCE=1
                should_git=1
            fi
        fi
    fi

    if [[ "$pwd" != "$_ICC_GIT_LAST_PWD" ]]; then
        should_git=1
    elif (( _ICC_GIT_FORCE )); then
        should_git=1
    elif (( now - _ICC_GIT_LAST_RUN >= 3 )); then
        should_git=1
    fi

    if (( should_git )); then
        local can_launch_git=1
        if [[ -n "$_ICC_GIT_JOB_PID" ]] && kill -0 "$_ICC_GIT_JOB_PID" 2>/dev/null; then
            # If a stale probe is still running but the cwd changed (or we just ran
            # a git command), restart immediately so branch state isn't delayed
            # until the next user command/prompt.
            # Note: this repeats the cwd check above on purpose. The first check
            # decides whether we should refresh at all; this one decides whether
            # an in-flight older probe can be reused vs. replaced.
            if [[ "$pwd" != "$_ICC_GIT_LAST_PWD" ]] || (( _ICC_GIT_FORCE )); then
                kill "$_ICC_GIT_JOB_PID" >/dev/null 2>&1 || true
                _ICC_GIT_JOB_PID=""
                _ICC_GIT_JOB_STARTED_AT=0
            else
                can_launch_git=0
            fi
        fi

        if (( can_launch_git )); then
            _ICC_GIT_FORCE=0
            _ICC_GIT_LAST_PWD="$pwd"
            _ICC_GIT_LAST_RUN=$now
            {
                _icc_report_git_branch_for_path "$pwd"
            } >/dev/null 2>&1 &!
            _ICC_GIT_JOB_PID=$!
            _ICC_GIT_JOB_STARTED_AT=$now
        fi
    fi

    # Pull request metadata is remote state. Keep a lightweight background poll
    # alive while the shell is idle so gh-created PRs and merge status changes
    # appear even without another prompt.
    local should_restart_pr_poll=0
    local pr_context_changed=0
    if [[ -n "$_ICC_PR_POLL_PWD" && "$pwd" != "$_ICC_PR_POLL_PWD" ]]; then
        pr_context_changed=1
    elif (( git_head_changed )); then
        pr_context_changed=1
    fi
    if [[ "$pwd" != "$_ICC_PR_POLL_PWD" ]]; then
        should_restart_pr_poll=1
    elif (( _ICC_PR_FORCE )); then
        should_restart_pr_poll=1
    elif [[ -z "$_ICC_PR_POLL_PID" ]] || ! kill -0 "$_ICC_PR_POLL_PID" 2>/dev/null; then
        should_restart_pr_poll=1
    fi

    if (( should_restart_pr_poll )); then
        _ICC_PR_FORCE=0
        if (( pr_context_changed )); then
            _icc_clear_pr_for_panel
        fi
        _icc_start_pr_poll_loop "$pwd" 1
    fi

    # Ports: lightweight kick to the app's batched scanner.
    # - Periodic scan to avoid stale values.
    # - Forced scan when a long-running command returns to the prompt (common when stopping a server).
    local cmd_dur=0
    if [[ -n "$cmd_start" && "$cmd_start" != 0 ]]; then
        cmd_dur=$(( now - cmd_start ))
    fi

    if (( cmd_dur >= 2 || now - _ICC_PORTS_LAST_RUN >= 10 )); then
        _icc_ports_kick
    fi
}

# Ensure Resources/bin is at the front of PATH, and remove the app's
# Contents/MacOS entry so the GUI icc binary cannot shadow the CLI icc.
# Shell init (.zprofile/.zshrc) may prepend other dirs after launch.
# We fix this once on first prompt (after all init files have run).
_icc_fix_path() {
    if [[ -n "${GHOSTTY_BIN_DIR:-}" ]]; then
        local gui_dir="${GHOSTTY_BIN_DIR%/}"
        local bin_dir="${gui_dir%/MacOS}/Resources/bin"
        if [[ -d "$bin_dir" ]]; then
            # Remove existing entries and re-prepend the CLI bin dir.
            local -a parts=("${(@s/:/)PATH}")
            parts=("${(@)parts:#$bin_dir}")
            parts=("${(@)parts:#$gui_dir}")
            PATH="${bin_dir}:${(j/:/)parts}"
        fi
    fi
    add-zsh-hook -d precmd _icc_fix_path
}

_icc_zshexit() {
    _icc_stop_git_head_watch
    _icc_stop_pr_poll_loop
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _icc_preexec
add-zsh-hook precmd _icc_precmd
add-zsh-hook precmd _icc_fix_path
add-zsh-hook zshexit _icc_zshexit

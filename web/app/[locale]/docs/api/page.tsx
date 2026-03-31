import { useTranslations } from "next-intl";
import { getTranslations } from "next-intl/server";
import { CodeBlock } from "../../components/code-block";
import { Callout } from "../../components/callout";

export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  const t = await getTranslations({ locale, namespace: "docs.api" });
  return {
    title: t("metaTitle"),
    description: t("metaDescription"),
  };
}

function Cmd({
  name,
  desc,
  cli,
  socket,
}: {
  name: string;
  desc: string;
  cli: string;
  socket: string;
}) {
  return (
    <div className="mb-6">
      <h4>{name}</h4>
      <p>{desc}</p>
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
        <CodeBlock title="CLI" lang="bash">{cli}</CodeBlock>
        <CodeBlock title="Socket" lang="json">{socket}</CodeBlock>
      </div>
    </div>
  );
}

export default function ApiPage() {
  const t = useTranslations("docs.api");

  return (
    <>
      <h1>{t("title")}</h1>
      <p>{t("intro")}</p>

      <h2>{t("socket")}</h2>
      <table>
        <thead>
          <tr>
            <th>{t("buildHeader")}</th>
            <th>{t("pathHeader")}</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>{t("release")}</td>
            <td>
              <code>/tmp/icc.sock</code>
            </td>
          </tr>
          <tr>
            <td>{t("debug")}</td>
            <td>
              <code>/tmp/icc-debug.sock</code>
            </td>
          </tr>
          <tr>
            <td>{t("taggedDebug")}</td>
            <td>
              <code>/tmp/icc-debug-&lt;tag&gt;.sock</code>
            </td>
          </tr>
        </tbody>
      </table>
      <p>{t("socketOverride")}</p>
      <CodeBlock lang="json">{`{"id":"req-1","method":"workspace.list","params":{}}
// Response:
{"id":"req-1","ok":true,"result":{"workspaces":[...]}}`}</CodeBlock>
      <Callout>
        {t.rich("socketCallout", {
          legacy: (chunks) => <code>{chunks}</code>,
        })}
      </Callout>

      <h2>{t("accessModes")}</h2>
      <table>
        <thead>
          <tr>
            <th>{t("modeHeader")}</th>
            <th>{t("descriptionHeader")}</th>
            <th>{t("howToEnableHeader")}</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>
              <strong>Off</strong>
            </td>
            <td>{t("offMode")}</td>
            <td>{t("offEnable")}</td>
          </tr>
          <tr>
            <td>
              <strong>icc processes only</strong>
            </td>
            <td>{t("iccOnlyMode")}</td>
            <td>{t("iccOnlyEnable")}</td>
          </tr>
          <tr>
            <td>
              <strong>allowAll</strong>
            </td>
            <td>{t("allowAllMode")}</td>
            <td>{t("allowAllEnable")}</td>
          </tr>
        </tbody>
      </table>
      <Callout type="warn">
        {t("accessCallout")}
      </Callout>

      <h2>{t("cliOptions")}</h2>
      <table>
        <thead>
          <tr>
            <th>{t("flagHeader")}</th>
            <th>{t("descriptionHeader")}</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>
              <code>--socket PATH</code>
            </td>
            <td>{t("customSocketPath")}</td>
          </tr>
          <tr>
            <td>
              <code>--json</code>
            </td>
            <td>{t("outputJson")}</td>
          </tr>
          <tr>
            <td>
              <code>--window ID</code>
            </td>
            <td>{t("targetWindow")}</td>
          </tr>
          <tr>
            <td>
              <code>--workspace ID</code>
            </td>
            <td>{t("targetWorkspace")}</td>
          </tr>
          <tr>
            <td>
              <code>--surface ID</code>
            </td>
            <td>{t("targetSurface")}</td>
          </tr>
          <tr>
            <td>
              <code>--id-format refs|uuids|both</code>
            </td>
            <td>{t("idFormat")}</td>
          </tr>
        </tbody>
      </table>

      <h2>{t("workspaceCommands")}</h2>

      <Cmd
        name="list-workspaces"
        desc={t("listWorkspacesDesc")}
        cli={`icc list-workspaces
icc list-workspaces --json`}
        socket={`{"id":"ws-list","method":"workspace.list","params":{}}`}
      />
      <Cmd
        name="new-workspace"
        desc={t("newWorkspaceDesc")}
        cli={`icc new-workspace`}
        socket={`{"id":"ws-new","method":"workspace.create","params":{}}`}
      />
      <Cmd
        name="select-workspace"
        desc={t("selectWorkspaceDesc")}
        cli={`icc select-workspace --workspace <id>`}
        socket={`{"id":"ws-select","method":"workspace.select","params":{"workspace_id":"<id>"}}`}
      />
      <Cmd
        name="current-workspace"
        desc={t("currentWorkspaceDesc")}
        cli={`icc current-workspace
icc current-workspace --json`}
        socket={`{"id":"ws-current","method":"workspace.current","params":{}}`}
      />
      <Cmd
        name="close-workspace"
        desc={t("closeWorkspaceDesc")}
        cli={`icc close-workspace --workspace <id>`}
        socket={`{"id":"ws-close","method":"workspace.close","params":{"workspace_id":"<id>"}}`}
      />

      <h2>{t("splitCommands")}</h2>

      <Cmd
        name="new-split"
        desc={t("newSplitDesc")}
        cli={`icc new-split right
icc new-split down`}
        socket={`{"id":"split-new","method":"surface.split","params":{"direction":"right"}}`}
      />
      <Cmd
        name="list-surfaces"
        desc={t("listSurfacesDesc")}
        cli={`icc list-surfaces
icc list-surfaces --json`}
        socket={`{"id":"surface-list","method":"surface.list","params":{}}`}
      />
      <Cmd
        name="focus-surface"
        desc={t("focusSurfaceDesc")}
        cli={`icc focus-surface --surface <id>`}
        socket={`{"id":"surface-focus","method":"surface.focus","params":{"surface_id":"<id>"}}`}
      />

      <h2>{t("inputCommands")}</h2>

      <Cmd
        name="send"
        desc={t("sendDesc")}
        cli={`icc send "echo hello"
icc send "ls -la\\n"`}
        socket={`{"id":"send-text","method":"surface.send_text","params":{"text":"echo hello\\n"}}`}
      />
      <Cmd
        name="send-key"
        desc={t("sendKeyDesc")}
        cli={`icc send-key enter`}
        socket={`{"id":"send-key","method":"surface.send_key","params":{"key":"enter"}}`}
      />
      <Cmd
        name="send-surface"
        desc={t("sendSurfaceDesc")}
        cli={`icc send-surface --surface <id> "command"`}
        socket={`{"id":"send-surface","method":"surface.send_text","params":{"surface_id":"<id>","text":"command"}}`}
      />
      <Cmd
        name="send-key-surface"
        desc={t("sendKeySurfaceDesc")}
        cli={`icc send-key-surface --surface <id> enter`}
        socket={`{"id":"send-key-surface","method":"surface.send_key","params":{"surface_id":"<id>","key":"enter"}}`}
      />

      <h2>{t("notificationCommands")}</h2>

      <Cmd
        name="notify"
        desc={t("notifyDesc")}
        cli={`icc notify --title "Title" --body "Body"
icc notify --title "T" --subtitle "S" --body "B"`}
        socket={`{"id":"notify","method":"notification.create","params":{"title":"Title","subtitle":"S","body":"Body"}}`}
      />
      <Cmd
        name="list-notifications"
        desc={t("listNotificationsDesc")}
        cli={`icc list-notifications
icc list-notifications --json`}
        socket={`{"id":"notif-list","method":"notification.list","params":{}}`}
      />
      <Cmd
        name="clear-notifications"
        desc={t("clearNotificationsDesc")}
        cli={`icc clear-notifications`}
        socket={`{"id":"notif-clear","method":"notification.clear","params":{}}`}
      />

      <h2>{t("sidebarMetadata")}</h2>
      <p>{t("sidebarMetadataDesc")}</p>

      <Cmd
        name="set-status"
        desc={t("setStatusDesc")}
        cli={`icc set-status build "compiling" --icon hammer --color "#ff9500"
icc set-status deploy "v1.2.3" --workspace workspace:2`}
        socket={`set_status build compiling --icon=hammer --color=#ff9500 --tab=<workspace-uuid>`}
      />
      <Cmd
        name="clear-status"
        desc={t("clearStatusDesc")}
        cli={`icc clear-status build`}
        socket={`clear_status build --tab=<workspace-uuid>`}
      />
      <Cmd
        name="list-status"
        desc={t("listStatusDesc")}
        cli={`icc list-status`}
        socket={`list_status --tab=<workspace-uuid>`}
      />
      <Cmd
        name="set-progress"
        desc={t("setProgressDesc")}
        cli={`icc set-progress 0.5 --label "Building..."
icc set-progress 1.0 --label "Done"`}
        socket={`set_progress 0.5 --label=Building... --tab=<workspace-uuid>`}
      />
      <Cmd
        name="clear-progress"
        desc={t("clearProgressDesc")}
        cli={`icc clear-progress`}
        socket={`clear_progress --tab=<workspace-uuid>`}
      />
      <Cmd
        name="log"
        desc={t("logDesc")}
        cli={`icc log "Build started"
icc log --level error --source build "Compilation failed"
icc log --level success -- "All 42 tests passed"`}
        socket={`log --level=error --source=build --tab=<workspace-uuid> -- Compilation failed`}
      />
      <Cmd
        name="clear-log"
        desc={t("clearLogDesc")}
        cli={`icc clear-log`}
        socket={`clear_log --tab=<workspace-uuid>`}
      />
      <Cmd
        name="list-log"
        desc={t("listLogDesc")}
        cli={`icc list-log
icc list-log --limit 5`}
        socket={`list_log --limit=5 --tab=<workspace-uuid>`}
      />
      <Cmd
        name="sidebar-state"
        desc={t("sidebarStateDesc")}
        cli={`icc sidebar-state
icc sidebar-state --workspace workspace:2`}
        socket={`sidebar_state --tab=<workspace-uuid>`}
      />

      <h2>{t("utilityCommands")}</h2>

      <Cmd
        name="ping"
        desc={t("pingDesc")}
        cli={`icc ping`}
        socket={`{"id":"ping","method":"system.ping","params":{}}
// Response: {"id":"ping","ok":true,"result":{"pong":true}}`}
      />
      <Cmd
        name="capabilities"
        desc={t("capabilitiesDesc")}
        cli={`icc capabilities
icc capabilities --json`}
        socket={`{"id":"caps","method":"system.capabilities","params":{}}`}
      />
      <Cmd
        name="identify"
        desc={t("identifyDesc")}
        cli={`icc identify
icc identify --json`}
        socket={`{"id":"identify","method":"system.identify","params":{}}`}
      />

      <h2>{t("envVariables")}</h2>
      <table>
        <thead>
          <tr>
            <th>{t("variableHeader")}</th>
            <th>{t("descriptionHeader")}</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>
              <code>ICC_SOCKET_PATH</code>
            </td>
            <td>{t("socketPathDesc")}</td>
          </tr>
          <tr>
            <td>
              <code>ICC_SOCKET_ENABLE</code>
            </td>
            <td>{t("socketEnableDesc")}</td>
          </tr>
          <tr>
            <td>
              <code>ICC_SOCKET_MODE</code>
            </td>
            <td>{t("socketModeDesc")}</td>
          </tr>
          <tr>
            <td>
              <code>ICC_WORKSPACE_ID</code>
            </td>
            <td>{t("workspaceIdDesc")}</td>
          </tr>
          <tr>
            <td>
              <code>ICC_SURFACE_ID</code>
            </td>
            <td>{t("surfaceIdDesc")}</td>
          </tr>
          <tr>
            <td>
              <code>TERM_PROGRAM</code>
            </td>
            <td>{t("termProgramDesc")}</td>
          </tr>
          <tr>
            <td>
              <code>TERM</code>
            </td>
            <td>{t("termDesc")}</td>
          </tr>
        </tbody>
      </table>
      <Callout>
        {t("envCallout")}
      </Callout>

      <h2>{t("detectingIcc")}</h2>
      <CodeBlock title="bash" lang="bash">{`# Prefer explicit socket path if set
SOCK="\${ICC_SOCKET_PATH:-/tmp/icc.sock}"
[ -S "$SOCK" ] && echo "Socket available"

# Check for the CLI
command -v icc &>/dev/null && echo "icc available"

# In icc-managed terminals these are auto-set
[ -n "\${ICC_WORKSPACE_ID:-}" ] && [ -n "\${ICC_SURFACE_ID:-}" ] && echo "Inside icc surface"

# Distinguish from regular Ghostty
[ "$TERM_PROGRAM" = "ghostty" ] && [ -n "\${ICC_WORKSPACE_ID:-}" ] && echo "In icc"`}</CodeBlock>

      <h2>{t("examples")}</h2>

      <h3>{t("pythonClient")}</h3>
      <CodeBlock title="python" lang="python">{`import json
import os
import socket

SOCKET_PATH = os.environ.get("ICC_SOCKET_PATH", "/tmp/icc.sock")

def rpc(method, params=None, req_id=1):
    payload = {"id": req_id, "method": method, "params": params or {}}
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
        sock.connect(SOCKET_PATH)
        sock.sendall(json.dumps(payload).encode("utf-8") + b"\\n")
        return json.loads(sock.recv(65536).decode("utf-8"))

# List workspaces
print(rpc("workspace.list", req_id="ws"))

# Send notification
print(rpc(
    "notification.create",
    {"title": "Hello", "body": "From Python!"},
    req_id="notify"
))`}</CodeBlock>

      <h3>{t("shellScript")}</h3>
      <CodeBlock title="bash" lang="bash">{`#!/bin/bash
SOCK="\${ICC_SOCKET_PATH:-/tmp/icc.sock}"

icc_cmd() {
    printf "%s\\n" "$1" | nc -U "$SOCK"
}

icc_cmd '{"id":"ws","method":"workspace.list","params":{}}'
icc_cmd '{"id":"notify","method":"notification.create","params":{"title":"Done","body":"Task complete"}}'`}</CodeBlock>

      <h3>{t("buildScriptNotification")}</h3>
      <CodeBlock title="bash" lang="bash">{`#!/bin/bash
npm run build
if [ $? -eq 0 ]; then
    icc notify --title "✓ Build Success" --body "Ready to deploy"
else
    icc notify --title "✗ Build Failed" --body "Check the logs"
fi`}</CodeBlock>
    </>
  );
}

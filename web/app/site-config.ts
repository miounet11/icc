const version = "v1.0.6";
const releaseDmgName = `icc-${version}-macos.dmg`;

export const siteConfig = {
  name: "icc",
  version,
  releaseDmgName,
  descriptor: "AI Command Center for macOS",
  title: "icc",
  tagline: "One cockpit for terminal-first AI execution.",
  description:
    "icc is a native macOS command center for serious AI work. It combines Ghostty-grade terminal rendering, local and remote file exploration, in-app editing, browser execution, source control visibility, and a supervisor layer in one focused workspace.",
  canonicalUrl: "https://www.iccjk.com",
  domain: "www.iccjk.com",
  repoUrl: "https://github.com/miounet11/icc",
  releasesUrl: "https://www.iccjk.com/changelog",
  downloadUrl: `https://www.iccjk.com/downloads/archive/${version}/${releaseDmgName}`,
  appcastUrl: "https://www.iccjk.com/downloads/appcast.xml",
  latestManifestUrl: "https://www.iccjk.com/downloads/latest.json",
  remoteManifestUrl: "https://www.iccjk.com/downloads/remote/cmuxd-remote-manifest.json",
  issuesUrl: "https://github.com/miounet11/icc/issues",
  githubApiRepo: "https://api.github.com/repos/miounet11/icc",
} as const;

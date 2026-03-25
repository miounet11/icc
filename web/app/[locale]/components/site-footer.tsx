import { LanguageSwitcher } from "./language-switcher";
import { siteConfig } from "../../site-config";

export function SiteFooter({
  locale = "en",
  descriptor = siteConfig.descriptor,
  labels = {
    blurb:
      "Native Swift and AppKit. Ghostty-grade rendering. Local and remote context, file operations, browser execution, source control, and supervision in one operator-first workspace.",
    explore: "Explore",
    release: "Release",
    capabilities: "Capabilities",
    workflow: "Workflow",
    faq: "FAQ",
    download: "Download for macOS",
    releases: "Releases",
    repository: "GitHub Repository",
    support: "Support / Issues",
    copyright: "© {year} icc. One cockpit for terminal-first AI execution.",
  },
  languageLabel = "Language",
  exploreLinks,
}: {
  locale?: string;
  descriptor?: string;
  labels?: {
    blurb: string;
    explore: string;
    release: string;
    capabilities: string;
    workflow: string;
    faq: string;
    download: string;
    releases: string;
    repository: string;
    support: string;
    copyright: string;
  };
  languageLabel?: string;
  exploreLinks?: Array<{
    href: string;
    label: string;
    external?: boolean;
  }>;
}) {
  const year = new Date().getFullYear();
  const resolvedExploreLinks = exploreLinks ?? [
    { href: "#capabilities", label: labels.capabilities },
    { href: "#workflow", label: labels.workflow },
    { href: "#faq", label: labels.faq },
  ];

  return (
    <footer className="mt-24 border-t border-border/70">
      <div className="max-w-6xl mx-auto px-6 py-10">
        <div className="grid gap-10 md:grid-cols-[minmax(0,1.4fr)_minmax(0,0.8fr)_minmax(0,0.8fr)]">
          <div className="space-y-4">
            <div className="flex items-center gap-3">
              <img
                src="/logo.png"
                alt={siteConfig.name}
                width={28}
                height={28}
                className="rounded-lg"
              />
              <div>
                <div className="text-sm font-semibold tracking-tight">{siteConfig.name}</div>
                <div className="text-xs text-muted">{descriptor}</div>
              </div>
            </div>
            <p className="max-w-xl text-sm leading-6 text-muted">{labels.blurb}</p>
          </div>

          <div>
            <div className="mb-3 text-xs font-semibold uppercase tracking-[0.18em] text-muted">
              {labels.explore}
            </div>
            <div className="space-y-2 text-sm text-muted">
              {resolvedExploreLinks.map((link) => (
                <a
                  key={`${link.href}-${link.label}`}
                  href={link.href}
                  target={link.external ? "_blank" : undefined}
                  rel={link.external ? "noopener noreferrer" : undefined}
                  className="block hover:text-foreground transition-colors"
                >
                  {link.label}
                </a>
              ))}
            </div>
          </div>

          <div>
            <div className="mb-3 text-xs font-semibold uppercase tracking-[0.18em] text-muted">
              {labels.release}
            </div>
            <div className="space-y-2 text-sm text-muted">
              <a href={siteConfig.downloadUrl} className="block hover:text-foreground transition-colors">
                {labels.download}
              </a>
              <a
                href={siteConfig.releasesUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="block hover:text-foreground transition-colors"
              >
                {labels.releases}
              </a>
              <a
                href={siteConfig.repoUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="block hover:text-foreground transition-colors"
              >
                {labels.repository}
              </a>
              <a
                href={siteConfig.issuesUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="block hover:text-foreground transition-colors"
              >
                {labels.support}
              </a>
            </div>
          </div>
        </div>

        <div className="mt-10 flex flex-col gap-2 border-t border-border/70 pt-5 text-xs text-muted sm:flex-row sm:items-center sm:justify-between">
          <p>{labels.copyright.replace("{year}", String(year))}</p>
          <div className="flex items-center gap-4">
            <p>{siteConfig.domain}</p>
            <div className="rounded-full border border-border/70 px-2.5 py-1">
              <LanguageSwitcher currentLocale={locale} label={languageLabel} />
            </div>
          </div>
        </div>
      </div>
    </footer>
  );
}

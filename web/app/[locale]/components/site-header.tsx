"use client";

import { DownloadButton } from "./download-button";
import { ThemeToggle } from "../theme";
import { GitHubStarsBadge } from "./github-stars";
import { LanguageSwitcher } from "./language-switcher";
import {
  useMobileDrawer,
  MobileDrawerOverlay,
  MobileDrawerToggle,
} from "./mobile-drawer";
import { siteConfig } from "../../site-config";
import { getLocalizedHomePath } from "../../marketing-copy";

export function SiteHeader({
  section,
  hideLogo,
  locale = "en",
  homeHref,
  descriptor = siteConfig.descriptor,
  nav,
  downloadLabel = "Download for macOS",
  links,
}: {
  section?: string;
  hideLogo?: boolean;
  locale?: string;
  homeHref?: string;
  descriptor?: string;
  nav?: {
    capabilities: string;
    workflow: string;
    faq: string;
    github: string;
    language: string;
    toggleTheme: string;
    openMenu: string;
    closeMenu: string;
    };
  downloadLabel?: string;
  links?: Array<{
    href: string;
    label: string;
    external?: boolean;
  }>;
}) {
  const { open, toggle, close, drawerRef, buttonRef } = useMobileDrawer();
  const labels = nav ?? {
    capabilities: "Capabilities",
    workflow: "Workflow",
    faq: "FAQ",
    github: "GitHub",
    language: "Language",
    toggleTheme: "Toggle theme",
    openMenu: "Open menu",
    closeMenu: "Close menu",
  };
  const resolvedHomeHref = homeHref ?? getLocalizedHomePath(locale);
  const navLinks = links ?? [
    { href: "#capabilities", label: labels.capabilities },
    { href: "#workflow", label: labels.workflow },
    { href: "#faq", label: labels.faq },
    { href: siteConfig.repoUrl, label: labels.github, external: true },
  ];

  return (
    <>
      <header className="sticky top-0 z-30 w-full border-b border-border/60 bg-background/88 backdrop-blur-xl">
        <div className="w-full max-w-6xl mx-auto flex items-center px-6 h-14">
          {/* Left: logo + section */}
          <div className="flex flex-1 items-center gap-3 min-w-0">
            {!hideLogo && (
              <>
                <a href={resolvedHomeHref} className="flex items-center gap-3">
                  <img
                    src="/logo.png"
                    alt={siteConfig.name}
                    width={28}
                    height={28}
                    className="rounded-lg"
                  />
                  <div className="flex flex-col leading-none">
                    <span className="text-sm font-semibold tracking-tight">
                      {siteConfig.name}
                    </span>
                    <span className="text-[11px] text-muted">
                      {descriptor}
                    </span>
                  </div>
                </a>
                {section && (
                  <>
                    <span className="text-border text-[13px]">/</span>
                    <span className="text-[13px] text-muted">{section}</span>
                  </>
                )}
              </>
            )}
          </div>

          {/* Center: nav links */}
          <nav className="hidden md:flex items-center justify-center gap-5 text-sm text-muted shrink-0">
            {navLinks.map((link) => (
              <a
                key={`${link.href}-${link.label}`}
                href={link.href}
                target={link.external ? "_blank" : undefined}
                rel={link.external ? "noopener noreferrer" : undefined}
                className="hover:text-foreground transition-colors"
              >
                {link.label}
              </a>
            ))}
          </nav>

          {/* Right: GitHub stars + Download + theme + mobile */}
          <div className="flex flex-1 items-center justify-end gap-3 min-w-0">
            <GitHubStarsBadge />
            <div className="hidden md:flex items-center rounded-full border border-border/70 px-2.5 py-1">
              <LanguageSwitcher currentLocale={locale} label={labels.language} />
            </div>
            <div className="hidden md:block">
              <DownloadButton size="sm" location="navbar" label={downloadLabel} />
            </div>
            <ThemeToggle label={labels.toggleTheme} />
            <MobileDrawerToggle
              open={open}
              onClick={toggle}
              buttonRef={buttonRef}
              openLabel={labels.openMenu}
              closeLabel={labels.closeMenu}
            />
          </div>
        </div>
      </header>

      {/* Mobile overlay + drawer */}
      <MobileDrawerOverlay open={open} onClose={close} />
      <nav
        ref={drawerRef}
        role="navigation"
        aria-label="Main navigation"
        className={`fixed inset-y-0 right-0 z-50 w-56 bg-background border-l border-border overflow-y-auto transition-transform md:hidden ${
          open ? "translate-x-0" : "translate-x-full invisible"
        }`}
      >
        <div className="flex items-center justify-end gap-1 px-4 h-12">
          <ThemeToggle label={labels.toggleTheme} />
          <button
            onClick={close}
            className="w-8 h-8 flex items-center justify-center text-muted hover:text-foreground transition-colors"
            aria-label={labels.closeMenu}
          >
            <svg
              width="16"
              height="16"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
              aria-hidden="true"
            >
              <path d="M18 6L6 18M6 6l12 12" />
            </svg>
          </button>
        </div>

        <div className="flex flex-col gap-3 text-sm text-muted px-4 pb-4">
          {navLinks.map((link) => (
            <a
              key={`${link.href}-${link.label}`}
              href={link.href}
              target={link.external ? "_blank" : undefined}
              rel={link.external ? "noopener noreferrer" : undefined}
              onClick={close}
              className="hover:text-foreground transition-colors py-1"
            >
              {link.label}
            </a>
          ))}
          <div className="pt-1">
            <LanguageSwitcher currentLocale={locale} label={labels.language} />
          </div>
          <GitHubStarsBadge location="mobile_drawer" />
          <div className="pt-2">
            <DownloadButton size="sm" location="mobile_drawer" label={downloadLabel} />
          </div>
        </div>
      </nav>
    </>
  );
}

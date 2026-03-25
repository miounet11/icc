import type { Metadata } from "next";
import { DownloadButton } from "../components/download-button";
import { SiteFooter } from "../components/site-footer";
import { SiteHeader } from "../components/site-header";
import { getMarketingCopy } from "../../marketing-copy";
import {
  buildLocalizedAlternates,
  getLocalizedProductPath,
  getProductPagesCopy,
} from "../../product-pages-copy";
import { siteConfig } from "../../site-config";

export async function generateMetadata({
  params,
}: {
  params: Promise<{ locale: string }>;
}): Promise<Metadata> {
  const { locale } = await params;
  const copy = getProductPagesCopy(locale);
  const path = getLocalizedProductPath(locale, "changelog");
  const canonical = locale === "en" ? `${siteConfig.canonicalUrl}/changelog` : `${siteConfig.canonicalUrl}${path}`;

  return {
    title: copy.changelog.metaTitle,
    description: copy.changelog.metaDescription,
    alternates: buildLocalizedAlternates(locale, "changelog"),
    openGraph: {
      title: copy.changelog.metaTitle,
      description: copy.changelog.metaDescription,
      url: canonical,
      siteName: siteConfig.name,
      type: "article",
    },
    twitter: {
      card: "summary_large_image",
      title: copy.changelog.metaTitle,
      description: copy.changelog.metaDescription,
    },
  };
}

export default async function ChangelogPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  const marketingCopy = getMarketingCopy(locale);
  const copy = getProductPagesCopy(locale);
  const homeHref = locale === "en" ? "/" : `/${locale}`;
  const guideHref = getLocalizedProductPath(locale, "guide");
  const changelogHref = getLocalizedProductPath(locale, "changelog");
  const navLinks = [
    { href: homeHref, label: copy.nav.home },
    { href: guideHref, label: copy.nav.guide },
    { href: changelogHref, label: copy.nav.changelog },
    { href: siteConfig.repoUrl, label: copy.nav.github, external: true },
  ];

  return (
    <div className="min-h-screen bg-[radial-gradient(circle_at_top_left,_rgba(35,93,255,0.12),_transparent_40%),radial-gradient(circle_at_top_right,_rgba(249,115,22,0.12),_transparent_30%),linear-gradient(180deg,_rgba(255,255,255,0.98),_rgba(245,243,238,0.96))] dark:bg-[radial-gradient(circle_at_top_left,_rgba(59,130,246,0.16),_transparent_34%),radial-gradient(circle_at_top_right,_rgba(249,115,22,0.12),_transparent_26%),linear-gradient(180deg,_rgba(9,14,26,1),_rgba(7,10,20,1))]">
      <SiteHeader
        section={copy.changelog.section}
        locale={locale}
        homeHref={homeHref}
        descriptor={marketingCopy.descriptor}
        nav={marketingCopy.header}
        downloadLabel={marketingCopy.buttons.download}
        links={navLinks}
      />

      <main className="mx-auto flex w-full max-w-5xl flex-col gap-12 px-6 pb-14 pt-12 md:pt-16">
        <section className="rounded-[32px] border border-border/70 bg-background/84 p-8 shadow-[0_18px_60px_rgba(15,23,42,0.06)]">
          <div className="space-y-5">
            <div className="text-xs font-semibold uppercase tracking-[0.22em] text-muted">{copy.changelog.eyebrow}</div>
            <h1 className="max-w-3xl text-4xl font-semibold tracking-[-0.05em] text-foreground sm:text-5xl">
              {copy.changelog.title}
            </h1>
            <p className="max-w-3xl text-base leading-8 text-muted">{copy.changelog.intro}</p>
          </div>

          <div className="mt-8 rounded-[28px] border border-border/60 bg-background/70 p-6">
            <div className="text-xs font-semibold uppercase tracking-[0.18em] text-muted">{copy.changelog.currentReleaseLabel}</div>
            <div className="mt-3 text-2xl font-semibold tracking-tight text-foreground">{siteConfig.version}</div>
            <p className="mt-3 text-sm leading-7 text-muted">{copy.changelog.currentReleaseBody}</p>
          </div>

          <div className="mt-8 flex flex-wrap items-center gap-3">
            <DownloadButton label={marketingCopy.buttons.download} location="changelog_hero" />
            <a
              href={guideHref}
              className="inline-flex items-center rounded-full border border-border px-5 py-2.5 text-[15px] font-medium text-foreground transition-colors hover:bg-code-bg"
            >
              {copy.changelog.secondaryCta}
            </a>
          </div>
        </section>

        <section className="space-y-5">
          <div className="text-xs font-semibold uppercase tracking-[0.22em] text-muted">{copy.changelog.entriesTitle}</div>
          {copy.changelog.entries.map((entry) => (
            <article
              key={`${entry.date}-${entry.title}`}
              className="rounded-[28px] border border-border/70 bg-background/84 p-8 shadow-[0_18px_60px_rgba(15,23,42,0.06)]"
            >
              <div className="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
                <div>
                  <div className="text-xs font-semibold uppercase tracking-[0.18em] text-muted">{entry.date}</div>
                  <h2 className="mt-3 text-2xl font-semibold tracking-[-0.03em] text-foreground">{entry.title}</h2>
                </div>
                <div className="rounded-full border border-border/70 px-3 py-1 text-xs font-medium text-muted">
                  {entry.version}
                </div>
              </div>
              <p className="mt-4 text-base leading-8 text-muted">{entry.body}</p>
              <ul className="mt-6 space-y-3">
                {entry.bullets.map((bullet) => (
                  <li key={bullet} className="rounded-2xl border border-border/60 bg-background/72 px-4 py-4 text-sm leading-7 text-foreground/90">
                    {bullet}
                  </li>
                ))}
              </ul>
            </article>
          ))}
        </section>

        <section className="rounded-[28px] border border-border/70 bg-[linear-gradient(135deg,rgba(15,23,42,0.96),rgba(30,41,59,0.96))] p-8 text-slate-100 shadow-[0_30px_100px_rgba(15,23,42,0.24)]">
          <div className="text-xs font-semibold uppercase tracking-[0.22em] text-slate-400">{copy.changelog.upgradeTitle}</div>
          <div className="mt-5 grid gap-4 md:grid-cols-2">
            {copy.changelog.upgradeSteps.map((step) => (
              <div key={step} className="rounded-2xl border border-white/10 bg-white/[0.04] p-5 text-sm leading-7 text-slate-200">
                {step}
              </div>
            ))}
          </div>
        </section>
      </main>

      <SiteFooter
        locale={locale}
        descriptor={marketingCopy.descriptor}
        labels={marketingCopy.footer}
        languageLabel={marketingCopy.header.language}
        exploreLinks={navLinks}
      />
    </div>
  );
}

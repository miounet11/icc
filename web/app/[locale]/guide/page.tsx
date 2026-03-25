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
  const path = getLocalizedProductPath(locale, "guide");
  const canonical = locale === "en" ? `${siteConfig.canonicalUrl}/guide` : `${siteConfig.canonicalUrl}${path}`;

  return {
    title: copy.guide.metaTitle,
    description: copy.guide.metaDescription,
    alternates: buildLocalizedAlternates(locale, "guide"),
    openGraph: {
      title: copy.guide.metaTitle,
      description: copy.guide.metaDescription,
      url: canonical,
      siteName: siteConfig.name,
      type: "article",
    },
    twitter: {
      card: "summary_large_image",
      title: copy.guide.metaTitle,
      description: copy.guide.metaDescription,
    },
  };
}

export default async function GuidePage({
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
        section={copy.guide.section}
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
            <div className="text-xs font-semibold uppercase tracking-[0.22em] text-muted">{copy.guide.eyebrow}</div>
            <h1 className="max-w-3xl text-4xl font-semibold tracking-[-0.05em] text-foreground sm:text-5xl">
              {copy.guide.title}
            </h1>
            <p className="max-w-3xl text-base leading-8 text-muted">{copy.guide.intro}</p>
          </div>

          <div className="mt-8 flex flex-wrap items-center gap-3">
            <DownloadButton label={marketingCopy.buttons.download} location="guide_hero" />
            <a
              href={changelogHref}
              className="inline-flex items-center rounded-full border border-border px-5 py-2.5 text-[15px] font-medium text-foreground transition-colors hover:bg-code-bg"
            >
              {copy.guide.secondaryCta}
            </a>
          </div>
        </section>

        <section className="rounded-[28px] border border-border/70 bg-background/84 p-8 shadow-[0_18px_60px_rgba(15,23,42,0.06)]">
          <div className="text-xs font-semibold uppercase tracking-[0.22em] text-muted">{copy.guide.quickStartTitle}</div>
          <ol className="mt-5 grid gap-4 md:grid-cols-2">
            {copy.guide.quickStartSteps.map((step, index) => (
              <li key={step} className="rounded-2xl border border-border/60 bg-background/70 p-5">
                <div className="text-xs font-semibold uppercase tracking-[0.18em] text-muted">
                  {String(index + 1).padStart(2, "0")}
                </div>
                <p className="mt-3 text-sm leading-7 text-foreground/90">{step}</p>
              </li>
            ))}
          </ol>
        </section>

        <section className="grid gap-5">
          {copy.guide.sections.map((section) => (
            <article
              key={section.title}
              className="rounded-[28px] border border-border/70 bg-background/84 p-8 shadow-[0_18px_60px_rgba(15,23,42,0.06)]"
            >
              <h2 className="text-2xl font-semibold tracking-[-0.03em] text-foreground">{section.title}</h2>
              <p className="mt-4 text-base leading-8 text-muted">{section.body}</p>
              <ul className="mt-6 space-y-3">
                {section.points.map((point) => (
                  <li key={point} className="rounded-2xl border border-border/60 bg-background/72 px-4 py-4 text-sm leading-7 text-foreground/90">
                    {point}
                  </li>
                ))}
              </ul>
            </article>
          ))}
        </section>

        <section className="rounded-[28px] border border-border/70 bg-[linear-gradient(135deg,rgba(15,23,42,0.96),rgba(30,41,59,0.96))] p-8 text-slate-100 shadow-[0_30px_100px_rgba(15,23,42,0.24)]">
          <div className="text-xs font-semibold uppercase tracking-[0.22em] text-slate-400">{copy.guide.updateTitle}</div>
          <div className="mt-5 grid gap-4 md:grid-cols-2">
            {copy.guide.updateSteps.map((step) => (
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

import { DownloadButton } from "./[locale]/components/download-button";
import { GitHubButton } from "./[locale]/components/github-button";
import { SiteFooter } from "./[locale]/components/site-footer";
import { SiteHeader } from "./[locale]/components/site-header";
import { getLocalizedHomePath, getMarketingCopy } from "./marketing-copy";
import { getLocalizedProductPath, getProductPagesCopy } from "./product-pages-copy";
import { siteConfig } from "./site-config";

export default function MarketingHome({ locale = "en" }: { locale?: string }) {
  const copy = getMarketingCopy(locale);
  const productCopy = getProductPagesCopy(locale);
  const homeHref = getLocalizedHomePath(locale);
  const guideHref = getLocalizedProductPath(locale, "guide");
  const changelogHref = getLocalizedProductPath(locale, "changelog");
  const homeHeaderLinks = [
    { href: "#capabilities", label: copy.header.capabilities },
    { href: guideHref, label: productCopy.nav.guide },
    { href: changelogHref, label: productCopy.nav.changelog },
    { href: "#faq", label: copy.header.faq },
    { href: siteConfig.repoUrl, label: copy.header.github, external: true },
  ];
  const footerExploreLinks = [
    { href: "#capabilities", label: copy.footer.capabilities },
    { href: "#workflow", label: copy.footer.workflow },
    { href: guideHref, label: productCopy.nav.guide },
    { href: changelogHref, label: productCopy.nav.changelog },
    { href: "#faq", label: copy.footer.faq },
  ];

  return (
    <div className="min-h-screen bg-[radial-gradient(circle_at_top_left,_rgba(35,93,255,0.14),_transparent_42%),radial-gradient(circle_at_top_right,_rgba(249,115,22,0.14),_transparent_34%),linear-gradient(180deg,_rgba(255,255,255,0.98),_rgba(245,243,238,0.96))] dark:bg-[radial-gradient(circle_at_top_left,_rgba(59,130,246,0.18),_transparent_36%),radial-gradient(circle_at_top_right,_rgba(249,115,22,0.14),_transparent_28%),linear-gradient(180deg,_rgba(9,14,26,1),_rgba(7,10,20,1))]">
      <SiteHeader
        locale={locale}
        homeHref={homeHref}
        descriptor={copy.descriptor}
        nav={copy.header}
        downloadLabel={copy.buttons.download}
        links={homeHeaderLinks}
      />

      <main className="mx-auto flex w-full max-w-6xl flex-col gap-20 px-6 pb-10 pt-12 md:pt-16">
        <section className="grid gap-10 lg:grid-cols-[minmax(0,1.1fr)_minmax(0,0.9fr)] lg:items-center">
          <div className="space-y-8">
            <div className="inline-flex items-center gap-2 rounded-full border border-border/70 bg-background/78 px-3 py-1 text-xs font-semibold uppercase tracking-[0.18em] text-muted shadow-[0_18px_60px_rgba(15,23,42,0.08)] backdrop-blur">
              <span className="h-2 w-2 rounded-full bg-emerald-500" />
              {copy.eyebrow}
              <span className="text-border">/</span>
              {siteConfig.version}
            </div>

            <div className="space-y-5">
              <h1 className="max-w-3xl text-5xl font-semibold leading-[0.95] tracking-[-0.05em] text-foreground sm:text-6xl">
                {copy.tagline}
              </h1>
              <p className="max-w-2xl text-lg leading-8 text-muted">{copy.heroDescription}</p>
            </div>

            <div className="flex flex-wrap items-center gap-3">
              <DownloadButton label={copy.buttons.download} location="hero" />
              <GitHubButton label={copy.buttons.github} />
            </div>

            <div className="grid gap-3 sm:grid-cols-3">
              {copy.heroCards.map((card) => (
                <div
                  key={card.label}
                  className="rounded-2xl border border-border/70 bg-background/82 p-4 shadow-[0_18px_60px_rgba(15,23,42,0.06)] backdrop-blur"
                >
                  <div className="text-xs uppercase tracking-[0.18em] text-muted">{card.label}</div>
                  <div className="mt-2 text-base font-semibold">{card.title}</div>
                  <div className="mt-1 text-sm leading-6 text-muted">{card.body}</div>
                </div>
              ))}
            </div>
          </div>

          <div className="relative">
            <div className="absolute inset-0 -translate-x-6 translate-y-6 rounded-[32px] bg-[linear-gradient(135deg,rgba(37,99,235,0.22),rgba(249,115,22,0.14))] blur-3xl" />
            <div className="relative overflow-hidden rounded-[32px] border border-slate-200/80 bg-[linear-gradient(180deg,rgba(250,250,250,0.98),rgba(241,245,249,0.96))] p-5 shadow-[0_30px_120px_rgba(15,23,42,0.18)] dark:border-slate-800/80 dark:bg-[linear-gradient(180deg,rgba(15,23,42,0.96),rgba(8,12,22,0.98))]">
              <div className="mb-4 flex items-center justify-between border-b border-border/70 pb-4">
                <div className="flex items-center gap-2">
                  <span className="h-2.5 w-2.5 rounded-full bg-rose-400" />
                  <span className="h-2.5 w-2.5 rounded-full bg-amber-400" />
                  <span className="h-2.5 w-2.5 rounded-full bg-emerald-400" />
                </div>
                <div className="rounded-full border border-border/70 px-3 py-1 text-[11px] font-medium text-muted">
                  {copy.preview.workspace}
                </div>
              </div>

              <div className="grid gap-4 md:grid-cols-[148px_minmax(0,1fr)_170px]">
                <div className="space-y-3 rounded-3xl border border-border/70 bg-background/88 p-3 dark:bg-white/[0.03]">
                  <div className="text-[11px] font-semibold uppercase tracking-[0.18em] text-muted">{copy.preview.rail}</div>
                  {copy.preview.railItems.map((item) => (
                    <div key={item} className="rounded-2xl border border-border/60 px-3 py-2 text-sm text-foreground/90">
                      {item}
                    </div>
                  ))}
                </div>

                <div className="space-y-3 rounded-3xl border border-border/70 bg-slate-950 p-4 text-slate-200 shadow-inner">
                  <div className="flex items-center justify-between text-[11px] uppercase tracking-[0.18em] text-slate-400">
                    <span>{copy.preview.terminal}</span>
                    <span>{copy.preview.ready}</span>
                  </div>
                  <div className="space-y-2 font-mono text-[12px] leading-6">
                    {copy.preview.lines.map((line, index) => (
                      <div
                        key={`${index}-${line}`}
                        className={index % 2 === 1 ? "text-slate-400" : undefined}
                      >
                        {line}
                      </div>
                    ))}
                  </div>
                </div>

                <div className="space-y-3 rounded-3xl border border-border/70 bg-background/88 p-3 dark:bg-white/[0.03]">
                  <div className="text-[11px] font-semibold uppercase tracking-[0.18em] text-muted">{copy.preview.supervisor}</div>
                  <div className="rounded-2xl border border-emerald-500/25 bg-emerald-500/10 p-3">
                    <div className="text-xs uppercase tracking-[0.18em] text-emerald-600 dark:text-emerald-300">{copy.preview.status}</div>
                    <div className="mt-2 text-sm font-semibold">{copy.preview.statusReady}</div>
                    <div className="mt-1 text-sm leading-6 text-muted">{copy.preview.statusBody}</div>
                  </div>
                  <div className="rounded-2xl border border-border/60 p-3">
                    <div className="text-xs uppercase tracking-[0.18em] text-muted">{copy.preview.files}</div>
                    <div className="mt-2 text-sm leading-6 text-foreground/90">{copy.preview.filesBody}</div>
                  </div>
                  <div className="rounded-2xl border border-border/60 p-3">
                    <div className="text-xs uppercase tracking-[0.18em] text-muted">{copy.preview.remote}</div>
                    <div className="mt-2 text-sm leading-6 text-foreground/90">{copy.preview.remoteBody}</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        <section id="capabilities" className="space-y-6">
          <div className="max-w-2xl space-y-3">
            <div className="text-xs font-semibold uppercase tracking-[0.22em] text-muted">{copy.capabilities.eyebrow}</div>
            <h2 className="text-3xl font-semibold tracking-[-0.04em] text-foreground sm:text-4xl">
              {copy.capabilities.title}
            </h2>
            <p className="text-base leading-7 text-muted">{copy.capabilities.body}</p>
          </div>

          <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
            {copy.capabilities.items.map((capability) => (
              <article
                key={capability.title}
                className="rounded-[26px] border border-border/70 bg-background/84 p-6 shadow-[0_18px_60px_rgba(15,23,42,0.06)] backdrop-blur"
              >
                <h3 className="text-lg font-semibold tracking-tight text-foreground">{capability.title}</h3>
                <p className="mt-3 text-sm leading-7 text-muted">{capability.body}</p>
              </article>
            ))}
          </div>
        </section>

        <section className="grid gap-5 lg:grid-cols-[minmax(0,1.1fr)_minmax(0,0.9fr)]">
          <article className="rounded-[28px] border border-border/70 bg-[linear-gradient(135deg,rgba(37,99,235,0.08),rgba(249,115,22,0.08))] p-8 shadow-[0_20px_70px_rgba(15,23,42,0.08)]">
            <div className="text-xs font-semibold uppercase tracking-[0.22em] text-muted">{copy.why.eyebrow}</div>
            <h2 className="mt-4 max-w-xl text-3xl font-semibold tracking-[-0.04em] text-foreground">
              {copy.why.title}
            </h2>
            <div className="mt-6 grid gap-4 sm:grid-cols-2">
              {copy.why.items.map((item) => (
                <div key={item} className="rounded-2xl border border-border/60 bg-background/78 px-4 py-4 text-sm leading-7 text-foreground/90">
                  {item}
                </div>
              ))}
            </div>
          </article>

          <article className="rounded-[28px] border border-border/70 bg-background/84 p-8 shadow-[0_18px_60px_rgba(15,23,42,0.06)]">
            <div className="text-xs font-semibold uppercase tracking-[0.22em] text-muted">{copy.profile.eyebrow}</div>
            <div className="mt-6 space-y-5">
              {copy.profile.items.map((item) => (
                <div key={item.label} className="flex flex-col gap-1 border-b border-border/60 pb-4 last:border-b-0 last:pb-0">
                  <span className="text-xs uppercase tracking-[0.18em] text-muted">{item.label}</span>
                  <span className="text-sm leading-7 text-foreground/90">{item.value}</span>
                </div>
              ))}
            </div>
          </article>
        </section>

        <section id="workflow" className="space-y-6">
          <div className="max-w-2xl space-y-3">
            <div className="text-xs font-semibold uppercase tracking-[0.22em] text-muted">{copy.workflow.eyebrow}</div>
            <h2 className="text-3xl font-semibold tracking-[-0.04em] text-foreground sm:text-4xl">
              {copy.workflow.title}
            </h2>
            <p className="text-base leading-7 text-muted">{copy.workflow.body}</p>
          </div>

          <div className="grid gap-4 lg:grid-cols-4">
            {copy.workflow.items.map((item) => (
              <article
                key={item.step}
                className="rounded-[26px] border border-border/70 bg-background/84 p-6 shadow-[0_18px_60px_rgba(15,23,42,0.06)]"
              >
                <div className="text-xs font-semibold uppercase tracking-[0.22em] text-muted">{item.step}</div>
                <h3 className="mt-3 text-lg font-semibold tracking-tight text-foreground">{item.title}</h3>
                <p className="mt-3 text-sm leading-7 text-muted">{item.body}</p>
              </article>
            ))}
          </div>
        </section>

        <section className="space-y-6">
          <div className="max-w-2xl space-y-3">
            <div className="text-xs font-semibold uppercase tracking-[0.22em] text-muted">{productCopy.resources.eyebrow}</div>
            <h2 className="text-3xl font-semibold tracking-[-0.04em] text-foreground sm:text-4xl">
              {productCopy.resources.title}
            </h2>
            <p className="text-base leading-7 text-muted">{productCopy.resources.body}</p>
          </div>

          <div className="grid gap-4 lg:grid-cols-2">
            {[
              {
                href: guideHref,
                title: productCopy.resources.guide.title,
                body: productCopy.resources.guide.body,
                cta: productCopy.resources.guide.cta,
              },
              {
                href: changelogHref,
                title: productCopy.resources.changelog.title,
                body: productCopy.resources.changelog.body,
                cta: productCopy.resources.changelog.cta,
              },
            ].map((item) => (
              <a
                key={item.href}
                href={item.href}
                className="group rounded-[28px] border border-border/70 bg-background/84 p-7 shadow-[0_18px_60px_rgba(15,23,42,0.06)] transition-transform hover:-translate-y-0.5"
              >
                <div className="text-lg font-semibold tracking-tight text-foreground">{item.title}</div>
                <p className="mt-3 text-sm leading-7 text-muted">{item.body}</p>
                <div className="mt-5 inline-flex items-center gap-2 text-sm font-medium text-foreground">
                  {item.cta}
                  <span className="transition-transform group-hover:translate-x-1">→</span>
                </div>
              </a>
            ))}
          </div>
        </section>

        <section id="faq" className="space-y-6">
          <div className="max-w-2xl space-y-3">
            <div className="text-xs font-semibold uppercase tracking-[0.22em] text-muted">{copy.faq.eyebrow}</div>
            <h2 className="text-3xl font-semibold tracking-[-0.04em] text-foreground sm:text-4xl">
              {copy.faq.title}
            </h2>
            <p className="text-base leading-7 text-muted">{copy.faq.body}</p>
          </div>

          <div className="grid gap-4 lg:grid-cols-2">
            {copy.faq.items.map((faq) => (
              <article
                key={faq.q}
                className="rounded-[26px] border border-border/70 bg-background/84 p-6 shadow-[0_18px_60px_rgba(15,23,42,0.06)]"
              >
                <h3 className="text-lg font-semibold tracking-tight text-foreground">{faq.q}</h3>
                <p className="mt-3 text-sm leading-7 text-muted">{faq.a}</p>
              </article>
            ))}
          </div>
        </section>

        <section className="rounded-[32px] border border-border/70 bg-[linear-gradient(135deg,rgba(15,23,42,0.96),rgba(30,41,59,0.96))] px-8 py-10 text-slate-100 shadow-[0_30px_100px_rgba(15,23,42,0.24)]">
          <div className="grid gap-8 lg:grid-cols-[minmax(0,1fr)_auto] lg:items-end">
            <div className="space-y-4">
              <div className="text-xs font-semibold uppercase tracking-[0.22em] text-slate-400">{copy.cta.eyebrow}</div>
              <h2 className="max-w-2xl text-3xl font-semibold tracking-[-0.04em] text-white sm:text-4xl">
                {copy.cta.title}
              </h2>
              <p className="max-w-2xl text-base leading-7 text-slate-300">{copy.cta.body}</p>
            </div>

            <div className="flex flex-wrap items-center gap-3 lg:justify-end">
              <DownloadButton label={copy.buttons.download} location="bottom" />
              <GitHubButton label={copy.buttons.github} location="bottom" />
            </div>
          </div>
        </section>
      </main>

      <SiteFooter
        locale={locale}
        descriptor={copy.descriptor}
        labels={copy.footer}
        languageLabel={copy.header.language}
        exploreLinks={footerExploreLinks}
      />
    </div>
  );
}

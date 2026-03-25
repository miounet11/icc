import type { Metadata } from "next";
import { NextIntlClientProvider } from "next-intl";
import {
  getMessages,
  setRequestLocale,
} from "next-intl/server";
import { notFound } from "next/navigation";
import { routing } from "../../i18n/routing";
import { getLocalizedHomePath, getMarketingCopy, marketingLocales } from "../marketing-copy";
import { siteConfig } from "../site-config";

export async function generateMetadata({
  params,
}: {
  params: Promise<{ locale: string }>;
}): Promise<Metadata> {
  const { locale } = await params;
  const path = getLocalizedHomePath(locale);
  const url = path === "/" ? siteConfig.canonicalUrl : `${siteConfig.canonicalUrl}${path}`;
  const copy = getMarketingCopy(locale);
  const alternates = Object.fromEntries(
    marketingLocales.map((item) => [
      item,
      item === "en" ? siteConfig.canonicalUrl : `${siteConfig.canonicalUrl}/${item}`,
    ]),
  );
  return {
    title: copy.metaTitle,
    description: copy.metaDescription,
    keywords: [
      "icc",
      "AI command center",
      "macOS terminal",
      "Ghostty",
      "remote explorer",
      "SSH workspace",
      "file editor",
      "terminal automation",
      "AI execution workspace",
      "source control",
      "browser operator",
      "supervisor",
    ],
    alternates: {
      canonical: url,
      languages: {
        ...alternates,
        "x-default": siteConfig.canonicalUrl,
      },
    },
    openGraph: {
      title: copy.metaTitle,
      description: copy.metaDescription,
      url,
      siteName: siteConfig.name,
      type: "website",
    },
    twitter: {
      card: "summary_large_image",
      title: copy.metaTitle,
      description: copy.metaDescription,
    },
    metadataBase: new URL(siteConfig.canonicalUrl),
  };
}

export function generateStaticParams() {
  return routing.locales.map((locale) => ({ locale }));
}

export default async function LocaleLayout({
  children,
  params,
}: {
  children: React.ReactNode;
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;

  if (!routing.locales.includes(locale as typeof routing.locales[number])) {
    notFound();
  }

  setRequestLocale(locale);

  const messages = await getMessages();

  const dir = locale === "ar" ? "rtl" : "ltr";

  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "SoftwareApplication",
    name: siteConfig.name,
    operatingSystem: "macOS",
    applicationCategory: "DeveloperApplication",
    url: siteConfig.canonicalUrl,
    downloadUrl: siteConfig.downloadUrl,
    description: siteConfig.description,
    keywords:
      "icc, AI command center, macOS, Ghostty, terminal, SSH, source control, browser operator, supervisor",
    offers: { "@type": "Offer", price: "0", priceCurrency: "USD" },
  };

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />
      <NextIntlClientProvider messages={messages}>
        <div dir={dir} lang={locale}>
          {children}
        </div>
      </NextIntlClientProvider>
    </>
  );
}
